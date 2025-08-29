import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class PdfSecurityService {
  /// Pick a PDF and return a local File, handling both `path` and `bytes`.
  static Future<File?> _pickPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true, // try to get bytes if path is not available
    );
    if (result == null) return null;

    final file = result.files.single;
    // If the platform provides an absolute path, use it
    if (file.path != null && file.path!.isNotEmpty) {
      return File(file.path!);
    }

    // Otherwise, write bytes to a temporary file
    if (file.bytes != null) {
      final tmpDir = await getTemporaryDirectory();
      final tmpFile = File(p.join(
        tmpDir.path,
        '${DateTime.now().millisecondsSinceEpoch}_${file.name}',
      ));
      await tmpFile.writeAsBytes(file.bytes!, flush: true);
      return tmpFile;
    }

    return null;
  }

  /// Adds password protection (AES-256) to a selected PDF.
  /// Returns the saved secured PDF file or null on failure/cancel.
  static Future<File?> addPasswordToPdf({
    required String userPassword,
    String? ownerPassword,
    bool allowPrinting = false,
    bool allowCopy = false,
  }) async {
    try {
      final sourceFile = await _pickPdf();
      if (sourceFile == null) return null;

      final bytes = await sourceFile.readAsBytes();

      // Load the PDF document
      final PdfDocument document = PdfDocument(inputBytes: bytes);

      // Configure security
      final PdfSecurity security = document.security;
      security.algorithm = PdfEncryptionAlgorithm.aesx256Bit;

      // Set passwords
      security.userPassword = userPassword;
      security.ownerPassword =
          (ownerPassword != null && ownerPassword.trim().isNotEmpty)
              ? ownerPassword
              : userPassword;

      // Set permissions
      final PdfPermissions permissions = security.permissions;
      permissions.clear(); // remove defaults
      if (allowPrinting) {
        permissions.add(PdfPermissionsFlags.print);
      }
      if (allowCopy) {
        permissions.add(PdfPermissionsFlags.copyContent);
      }

      // Save file in app documents directory
      final dir = await getApplicationDocumentsDirectory();
      final outPath = p.join(
        dir.path,
        '${p.basenameWithoutExtension(sourceFile.path)}_secured_${DateTime.now().millisecondsSinceEpoch}.pdf',
      );
      final File outFile = File(outPath);
      final outBytes = await document.save();
      await outFile.writeAsBytes(outBytes, flush: true);

      document.dispose();

      // Optionally open
      await OpenFilex.open(outFile.path);

      return outFile;
    } catch (e) {
      print('Error securing PDF: $e');
      return null;
    }
  }

  /// Removes password protection from a selected encrypted PDF.
  static Future<File?> removePasswordFromPdf({
    required String currentPassword,
  }) async {
    try {
      final sourceFile = await _pickPdf();
      if (sourceFile == null) return null;

      final bytes = await sourceFile.readAsBytes();

      // Open encrypted PDF with supplied password
      final PdfDocument document = PdfDocument(
        inputBytes: bytes,
        password: currentPassword,
      );

      final PdfSecurity security = document.security;

      // Clear passwords and permissions
      security.userPassword = '';
      security.ownerPassword = '';
      security.permissions.clear();

      // Save unlocked PDF
      final dir = await getApplicationDocumentsDirectory();
      final outPath = p.join(
        dir.path,
        '${p.basenameWithoutExtension(sourceFile.path)}_unlocked_${DateTime.now().millisecondsSinceEpoch}.pdf',
      );
      final File outFile = File(outPath);
      final outBytes = await document.save();
      await outFile.writeAsBytes(outBytes, flush: true);

      document.dispose();

      await OpenFilex.open(outFile.path);
      return outFile;
    } on Exception catch (e) {
      // wrong password or corrupt PDF
      print('PDF password error: $e');
      return null;
    }
  }
}

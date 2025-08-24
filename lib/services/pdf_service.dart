import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';

class PDFService {
  /// Generate PDF from list of images with options
  static Future<File> generatePDF({
    required List<File> images,
    PdfPageFormat pageFormat = PdfPageFormat.a4,
    bool landscape = false,
  }) async {
    final pdf = pw.Document();

    for (var img in images) {
      final bytes = await img.readAsBytes();
      final image = pw.MemoryImage(bytes);

      pdf.addPage(
        pw.Page(
          pageFormat: landscape ? pageFormat.landscape : pageFormat,
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Image(image, fit: pw.BoxFit.contain),
            );
          },
        ),
      );
    }

    final dir = await getApplicationDocumentsDirectory();
    final file = File(
        "${dir.path}/image_to_pdf_${DateTime.now().millisecondsSinceEpoch}.pdf");

    await file.writeAsBytes(await pdf.save());
    return file;
  }
}

import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';

class PDFService {
  /// Generate PDF from list of image files
  static Future<File> generatePDF(List<File> images) async {
    final pdf = pw.Document();

    for (var img in images) {
      final image = pw.MemoryImage(img.readAsBytesSync());
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Image(image, fit: pw.BoxFit.contain),
            );
          },
        ),
      );
    }

    final dir = await getApplicationDocumentsDirectory();
    final file = File("${dir.path}/image_to_pdf_${DateTime.now().millisecondsSinceEpoch}.pdf");

    await file.writeAsBytes(await pdf.save());
    return file;
  }
}

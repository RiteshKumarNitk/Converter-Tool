import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
// import 'package:open_file/open_file.dart';

class MergePDFPage extends StatefulWidget {
  const MergePDFPage({super.key});

  @override
  State<MergePDFPage> createState() => _MergePDFPageState();
}

class _MergePDFPageState extends State<MergePDFPage> {
  File? firstPDF;
  File? secondPDF;

  void pickPDF(int fileNumber) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        if (fileNumber == 1) {
          firstPDF = File(result.files.single.path!);
        } else {
          secondPDF = File(result.files.single.path!);
        }
      });
    }
  }

  void mergePDFs() async {
    if (firstPDF == null || secondPDF == null) return;

    try {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Merging PDFs...')));

      // Load PDFs
      final PdfDocument document1 = PdfDocument(
        inputBytes: await firstPDF!.readAsBytes(),
      );
      final PdfDocument document2 = PdfDocument(
        inputBytes: await secondPDF!.readAsBytes(),
      );

      // Create new merged document
      final PdfDocument mergedDocument = PdfDocument();

      // Copy pages from first documenta
      for (int i = 0; i < document1.pages.count; i++) {
        final PdfPage page = document1.pages[i];
        final PdfTemplate template = page.createTemplate();
        mergedDocument.pages.add().graphics.drawPdfTemplate(
          template,
          Offset.zero,
        );
      }

      // Copy pages from second document
      for (int i = 0; i < document2.pages.count; i++) {
        final PdfPage page = document2.pages[i];
        final PdfTemplate template = page.createTemplate();
        mergedDocument.pages.add().graphics.drawPdfTemplate(
          template,
          Offset.zero,
        );
      }

      // Save merged PDF to bytes
      final List<int> mergedBytes = await mergedDocument.save();

      // Dispose all documents
      document1.dispose();
      document2.dispose();
      mergedDocument.dispose();

      // Save merged PDF file
      final dir = await getApplicationDocumentsDirectory();
      final outputPath = '${dir.path}/merged_output.pdf';
      final File outputFile = File(outputPath);
      await outputFile.writeAsBytes(mergedBytes);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('PDF saved to: $outputPath')));

      // Open merged PDF
      await OpenFilex.open(outputPath);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error merging PDFs: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isReadyToMerge = firstPDF != null && secondPDF != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('MergePDF'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Merge Two PDF Files',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => pickPDF(1),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 16,
                ),
              ),
              child: const Text('Pick First File'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => pickPDF(2),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 16,
                ),
              ),
              child: const Text('Pick Second File'),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: isReadyToMerge ? mergePDFs : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: isReadyToMerge ? Colors.blue : Colors.grey,
                padding: const EdgeInsets.symmetric(
                  horizontal: 50,
                  vertical: 16,
                ),
              ),
              child: const Text(
                'Merge Files',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

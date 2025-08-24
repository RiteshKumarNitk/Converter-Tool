import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:reorderables/reorderables.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart'; // Needed for PdfPageFormat
import '../../services/pdf_service.dart';

class ImageToPDFScreen extends StatefulWidget {
  @override
  _ImageToPDFScreenState createState() => _ImageToPDFScreenState();
}

class _ImageToPDFScreenState extends State<ImageToPDFScreen> {
  final ImagePicker _picker = ImagePicker();
  List<File> _images = [];
  String _pageSize = "A4";
  String _orientation = "Portrait";

  /// Pick multiple images
  Future<void> _pickImages() async {
    final picked = await _picker.pickMultiImage();
    if (picked.isNotEmpty) {
      setState(() {
        _images.addAll(picked.map((x) => File(x.path)));
      });
    }
  }

  /// Generate PDF
  Future<void> _generatePDF() async {
    if (_images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please add images first")),
      );
      return;
    }

    // ✅ Map dropdown to PdfPageFormat
    PdfPageFormat format =
        _pageSize == "A4" ? PdfPageFormat.a4 : PdfPageFormat.letter;
    bool landscape = _orientation == "Landscape";

    final pdfFile = await PDFService.generatePDF(
      images: _images, // ✅ FIXED here
      pageFormat: format,
      landscape: landscape,
    );

    /// Share PDF
    await Share.shareXFiles([XFile(pdfFile.path)], text: "Here’s your PDF!");
  }

  /// Reorder logic
  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      final item = _images.removeAt(oldIndex);
      _images.insert(newIndex, item);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Image → PDF"),
        actions: [
          IconButton(
            icon: Icon(Icons.picture_as_pdf),
            onPressed: _generatePDF,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickImages,
        child: Icon(Icons.add),
      ),
      body: Column(
        children: [
          /// Page options
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                DropdownButton<String>(
                  value: _pageSize,
                  items: ["A4", "Letter"].map((e) {
                    return DropdownMenuItem(value: e, child: Text("Size: $e"));
                  }).toList(),
                  onChanged: (val) => setState(() => _pageSize = val!),
                ),
                SizedBox(width: 16),
                DropdownButton<String>(
                  value: _orientation,
                  items: ["Portrait", "Landscape"].map((e) {
                    return DropdownMenuItem(
                        value: e, child: Text("Orientation: $e"));
                  }).toList(),
                  onChanged: (val) => setState(() => _orientation = val!),
                ),
              ],
            ),
          ),

          /// Reorderable list of images
          Expanded(
            child: _images.isEmpty
                ? Center(child: Text("No images added"))
                : ReorderableWrap(
                    spacing: 8,
                    runSpacing: 8,
                    onReorder: _onReorder,
                    children: _images.map((file) {
                      return Stack(
                        key: ValueKey(file),
                        children: [
                          Image.file(file,
                              width: 100, height: 120, fit: BoxFit.cover),
                          Positioned(
                            right: 0,
                            top: 0,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _images.remove(file);
                                });
                              },
                              child: Container(
                                color: Colors.black54,
                                child: Icon(Icons.close,
                                    color: Colors.white, size: 18),
                              ),
                            ),
                          )
                        ],
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }
}

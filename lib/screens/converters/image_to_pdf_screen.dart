import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:open_filex/open_filex.dart';
import '../../services/pdf_service.dart';

class ImageToPdfScreen extends StatefulWidget {
  const ImageToPdfScreen({Key? key}) : super(key: key);

  @override
  State<ImageToPdfScreen> createState() => _ImageToPdfScreenState();
}

class _ImageToPdfScreenState extends State<ImageToPdfScreen> {
  final List<File> _selectedImages = [];
  bool _isLoading = false;

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final picked = await picker.pickMultiImage();
    if (picked != null) {
      setState(() {
        _selectedImages.addAll(picked.map((x) => File(x.path)));
      });
    }
  }

  Future<void> _createPDF() async {
    if (_selectedImages.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final pdfFile = await PDFService.generatePDF(_selectedImages);
      await OpenFilex.open(pdfFile.path);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Image to PDF")),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: _pickImages,
              icon: const Icon(Icons.add_photo_alternate),
              label: const Text("Pick Images"),
            ),
            const SizedBox(height: 10),

            // Show selected images
            Expanded(
              child: _selectedImages.isEmpty
                  ? const Center(child: Text("No images selected"))
                  : GridView.builder(
                      itemCount: _selectedImages.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 5,
                        crossAxisSpacing: 5,
                      ),
                      itemBuilder: (_, i) => Stack(
                        children: [
                          Image.file(_selectedImages[i], fit: BoxFit.cover),
                          Positioned(
                            right: 0,
                            top: 0,
                            child: IconButton(
                              icon: const Icon(Icons.close, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  _selectedImages.removeAt(i);
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
            ),

            const SizedBox(height: 10),

            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton.icon(
                    onPressed: _createPDF,
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text("Convert to PDF"),
                  ),
          ],
        ),
      ),
    );
  }
}

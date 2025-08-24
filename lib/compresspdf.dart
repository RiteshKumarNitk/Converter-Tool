import 'package:flutter/material.dart';
import 'mergepdf.dart'; // Import the Merge PDF page

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: PDFToolsPage(),
    );
  }
}

class PDFToolsPage extends StatelessWidget {
  const PDFToolsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'PDF Tools',
          style: TextStyle(
            color: Colors.blue,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              'All-in-one PDF utility suite',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              padding: const EdgeInsets.all(16),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                PDFToolCard(
                  icon: Icons.help_outline,
                  title: 'Merge PDF',
                  description:
                      'Combine PDFs in the order you want with the easiest PDF merger available.',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MergePDFPage(),
                      ),
                    );
                  },
                ),
                const PDFToolCard(
                  icon: Icons.help_outline,
                  title: 'Split PDF',
                  description:
                      'Separate one page or a whole set for easy conversion into independent files.',
                ),
                const PDFToolCard(
                  icon: Icons.compress,
                  title: 'Compress PDF',
                  description:
                      'Reduce file size while optimizing for maximal PDF quality.',
                ),
                const PDFToolCard(
                  icon: Icons.text_snippet,
                  title: 'PDF to Word',
                  description:
                      'Easily convert your PDF files into editable Word documents.',
                ),
                const PDFToolCard(
                  icon: Icons.slideshow,
                  title: 'PDF to PowerPoint',
                  description:
                      'Turn your PDF files into editable PowerPoint slides.',
                ),
                const PDFToolCard(
                  icon: Icons.grid_on,
                  title: 'PDF to Excel',
                  description: 'Convert PDFs to Excel spreadsheets in seconds.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PDFToolCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback? onTap;

  const PDFToolCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: Colors.blue.shade100,
              radius: 30,
              child: Icon(icon, color: Colors.blue, size: 30),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

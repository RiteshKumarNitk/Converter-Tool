import 'package:flutter/material.dart';
import 'package:pdf_convertor/screens/converters/image_to_pdf_screen.dart';
import 'package:pdf_convertor/screens/converters/pdf_password_screen.dart';
import 'package:pdf_convertor/screens/converters/pdf_to_text_screen.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Categories
  final List<Map<String, dynamic>> categories = [
    {"name": "Image", "icon": Icons.image},
    {"name": "PDF", "icon": Icons.picture_as_pdf},
    {"name": "Video", "icon": Icons.videocam},
    {"name": "Audio", "icon": Icons.music_note},
    {"name": "Text", "icon": Icons.text_snippet},
  ];

  // Tools by category
  final Map<String, List<Map<String, dynamic>>> toolsByCategory = {
    "Image": [
      {
        "title": "Image to PDF",
        "subtitle": "Convert images into PDF",
        "icon": Icons.image,
      },
      {
        "title": "JPG to PNG",
        "subtitle": "Convert JPG to PNG",
        "icon": Icons.image,
      },
    ],
"PDF": [
  {
    "title": "PDF to Word",
    "subtitle": "Convert PDF to DOCX",
    "icon": Icons.picture_as_pdf,
  },
  {
    "title": "Compress PDF",
    "subtitle": "Reduce PDF file size",
    "icon": Icons.picture_as_pdf,
  },
  {
    "title": "Merge PDF",
    "subtitle": "Combine multiple PDFs",
    "icon": Icons.picture_as_pdf,
  },
  {
    "title": "Password Protect PDF",
    "subtitle": "Add or remove PDF password",
    "icon": Icons.lock,
  },
  {
    "title": "PDF to Text",
    "subtitle": "Extract text from PDF",
    "icon": Icons.text_snippet,
  }, // ✅ New tool
],
    "Video": [
      {
        "title": "Video to MP3",
        "subtitle": "Extract audio from video",
        "icon": Icons.videocam,
      },
      {
        "title": "MP4 to AVI",
        "subtitle": "Convert video format",
        "icon": Icons.videocam,
      },
    ],
    "Audio": [
      {
        "title": "MP3 to WAV",
        "subtitle": "Convert audio formats",
        "icon": Icons.music_note,
      },
      {
        "title": "Audio Cutter",
        "subtitle": "Trim your audio files",
        "icon": Icons.music_note,
      },
    ],
    "Text": [
      {
        "title": "Text to PDF",
        "subtitle": "Save text as PDF",
        "icon": Icons.text_snippet,
      },
      {
        "title": "Text to Speech",
        "subtitle": "Convert text to audio",
        "icon": Icons.text_snippet,
      },
    ],
  };

  String activeCategory = "Image"; // default selected category

  @override
  Widget build(BuildContext context) {
    final tools = toolsByCategory[activeCategory] ?? [];

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔎 Search bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: Colors.grey),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Search converters...",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 🏷️ Categories
            const Text(
              "Categories",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 60,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  var cat = categories[index];
                  bool isActive = cat["name"] == activeCategory;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        activeCategory = cat["name"];
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isActive ? Colors.orange : Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: Colors.orange.withOpacity(0.4),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            cat["icon"],
                            size: 20,
                            color: isActive ? Colors.white : Colors.orange,
                          ),
                          const SizedBox(width: 6),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                cat["name"],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: isActive ? Colors.white : Colors.black,
                                ),
                              ),
                              Text(
                                "${toolsByCategory[cat["name"]]?.length ?? 0} tools",
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isActive
                                      ? Colors.white70
                                      : Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // 🛠️ Tools grid
            Text(
              "$activeCategory Tools",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: tools.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemBuilder: (context, index) {
                var tool = tools[index];
                return InkWell(
                  onTap: () {
                    // Navigate based on tool title
                    if (tool["title"] == "Image to PDF") {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => ImageToPDFScreen()),
                      );
                    } else if (tool["title"] == "Password Protect PDF") {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PdfPasswordScreen(),
                        ), // ✅ navigate to new screen
                      );
                    }
                    else if (tool["title"] == "PDF to Text") {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const PdfToTextScreen()),
  );
}

                    // You can add other tools here similarly
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: Colors.black12, blurRadius: 4),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(tool["icon"], size: 28, color: Colors.blue),
                        const Spacer(),
                        Text(
                          tool["title"],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          tool["subtitle"],
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

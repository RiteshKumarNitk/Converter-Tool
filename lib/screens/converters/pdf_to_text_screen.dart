import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ExportFormat { txt, docx, html }

class PdfToTextScreen extends StatefulWidget {
  const PdfToTextScreen({super.key});

  @override
  State<PdfToTextScreen> createState() => _PdfToTextScreenState();
}

class _PdfToTextScreenState extends State<PdfToTextScreen> {
  String? _extractedText;
  bool _isLoading = false;
  String? _lastSavedTxtPath;
  List<String>? _multipleExtractedTexts;
  int _currentFileIndex = 0;
  
  // Formatting options
  bool _preserveFormatting = true;
  bool _includePageNumbers = false;
  bool _removeEmptyLines = false;
  bool _removeHeaderFooter = false;
  
  // Search functionality
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<Match> _searchResults = [];
  int _currentSearchIndex = -1;
  
  // Editing functionality
  final TextEditingController _textEditingController = TextEditingController();
  bool _isEditing = false;
  
  // File information
  String? _fileName;
  int? _fileSize;
  int? _pageCount;
  double _progress = 0.0;
  
  // Recent files
  List<String> _recentFiles = [];
  final SharedPreferences? _prefs = null;

  @override
  void initState() {
    super.initState();
    _loadRecentFiles();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _textEditingController.dispose();
    super.dispose();
  }

  Future<void> _loadRecentFiles() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _recentFiles = prefs.getStringList('recentFiles') ?? [];
    });
  }

  Future<void> _addToRecentFiles(String filePath) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _recentFiles.remove(filePath);
      _recentFiles.insert(0, filePath);
      if (_recentFiles.length > 10) _recentFiles.removeLast();
    });
    await prefs.setStringList('recentFiles', _recentFiles);
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
      if (_searchQuery.isNotEmpty && _extractedText != null) {
        _searchResults = _searchQuery.allMatches(_extractedText!).toList();
        _currentSearchIndex = -1;
      } else {
        _searchResults = [];
        _currentSearchIndex = -1;
      }
    });
  }

  void _navigateSearch(int direction) {
    if (_searchResults.isEmpty) return;
    
    setState(() {
      _currentSearchIndex = (_currentSearchIndex + direction) % _searchResults.length;
      if (_currentSearchIndex < 0) _currentSearchIndex = _searchResults.length - 1;
    });
  }

  Future<void> _pickAndExtractText() async {
    try {
      setState(() {
        _isLoading = true;
        _extractedText = null;
        _lastSavedTxtPath = null;
        _multipleExtractedTexts = null;
        _currentFileIndex = 0;
        _progress = 0.0;
        _searchQuery = '';
        _searchController.clear();
      });

      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: true,
      );

      if (result == null) {
        setState(() => _isLoading = false);
        return;
      }

      final file = result.files.single;
      await _extractTextFromFile(file);
      
    } catch (e) {
      setState(() {
        _extractedText = 'Error extracting text: $e';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickMultiplePdfs() async {
    try {
      setState(() {
        _isLoading = true;
        _multipleExtractedTexts = [];
        _currentFileIndex = 0;
        _progress = 0.0;
        _searchQuery = '';
        _searchController.clear();
      });

      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: true,
        withData: true,
      );

      if (result == null || result.files.isEmpty) {
        setState(() => _isLoading = false);
        return;
      }

      for (int i = 0; i < result.files.length; i++) {
        final file = result.files[i];
        final text = await _extractTextFromFile(file, isBatch: true);
        _multipleExtractedTexts!.add(text);
        
        setState(() {
          _progress = (i + 1) / result.files.length;
        });
      }

      setState(() {
        _extractedText = _multipleExtractedTexts!.first;
      });
    } catch (e) {
      setState(() {
        _extractedText = 'Error processing files: $e';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<String> _extractTextFromFile(PlatformFile file, {bool isBatch = false}) async {
    late final List<int> bytes;

    if (file.path != null && file.path!.isNotEmpty) {
      bytes = await File(file.path!).readAsBytes();
      _addToRecentFiles(file.path!);
    } else if (file.bytes != null) {
      bytes = file.bytes!;
    } else {
      throw Exception('Could not read the selected PDF.');
    }

    // Load document
    final PdfDocument document = PdfDocument(inputBytes: bytes);

    // Extract text from document
    final PdfTextExtractor extractor = PdfTextExtractor(document);
    String text = extractor.extractText();

    document.dispose();

    // Process text based on user preferences
    text = _processExtractedText(text);

    if (!isBatch) {
      setState(() {
        _extractedText = text.isNotEmpty ? text : 'No text found in the PDF.';
        _fileName = file.name;
        _fileSize = file.size;
        _pageCount = document.pages.count;
      });
    }

    return text;
  }

  String _processExtractedText(String text) {
    String processed = text;
    
    if (!_preserveFormatting) {
      processed = processed.replaceAll(RegExp(r'\s+'), ' ').trim();
    }
    
    if (_removeEmptyLines) {
      processed = processed.replaceAll(RegExp(r'\n\s*\n'), '\n');
    }
    
    if (_removeHeaderFooter && processed.contains('\n')) {
      final lines = processed.split('\n');
      if (lines.length > 6) {
        processed = lines.sublist(2, lines.length - 2).join('\n');
      }
    }
    
    return processed;
  }

List<TextSpan> _highlightSearchResults(String text, String query) {
  if (query.isEmpty) return [TextSpan(text: text, style: TextStyle(color: Colors.black))];
  
  final matches = query.allMatches(text).toList(); // Convert to List
  final spans = <TextSpan>[];
  int lastEnd = 0;

  for (final match in matches) {
    if (match.start > lastEnd) {
      spans.add(TextSpan(
        text: text.substring(lastEnd, match.start),
        style: TextStyle(color: Colors.black),
      ));
    }
    
    final isCurrent = matches.indexOf(match) == _currentSearchIndex;
    spans.add(TextSpan(
      text: text.substring(match.start, match.end),
      style: TextStyle(
        backgroundColor: isCurrent ? Colors.orange : Colors.yellow,
        color: Colors.black,
        fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
      ),
    ));
    
    lastEnd = match.end;
  }
  
  if (lastEnd < text.length) {
    spans.add(TextSpan(text: text.substring(lastEnd), style: TextStyle(color: Colors.black)));
  }
  
  return spans;
}

  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
      if (_isEditing) {
        _textEditingController.text = _extractedText ?? '';
      } else {
        _extractedText = _textEditingController.text;
      }
    });
  }

  Future<void> _saveEditedText() async {
    setState(() {
      _extractedText = _textEditingController.text;
      _isEditing = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Changes saved')),
    );
  }

  Future<void> _saveExtractedText() async {
    if (_extractedText == null || _extractedText!.trim().isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Nothing to save.')));
      return;
    }

    try {
      final dir = await getApplicationDocumentsDirectory();
      final filename =
          'extracted_${DateTime.now().millisecondsSinceEpoch}.txt';
      final path = p.join(dir.path, filename);
      final file = File(path);
      await file.writeAsString(_extractedText!, flush: true);
      setState(() => _lastSavedTxtPath = path);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Saved as .txt')));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to save: $e')));
    }
  }

  Future<void> _exportToDifferentFormats() async {
    if (_extractedText == null || _extractedText!.trim().isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Nothing to export.')));
      return;
    }

    final format = await showDialog<ExportFormat>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Export Format'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('Text File (.txt)'),
              onTap: () => Navigator.pop(context, ExportFormat.txt),
            ),
            ListTile(
              title: Text('Word Document (.docx)'),
              onTap: () => Navigator.pop(context, ExportFormat.docx),
            ),
            ListTile(
              title: Text('HTML Document (.html)'),
              onTap: () => Navigator.pop(context, ExportFormat.html),
            ),
          ],
        ),
      ),
    );

    switch (format) {
      case ExportFormat.docx:
        await _exportToDocx();
        break;
      case ExportFormat.html:
        await _exportToHtml();
        break;
      default:
        await _saveExtractedText();
    }
  }

  Future<void> _exportToDocx() async {
    // Placeholder for DOCX export - you'd need a DOCX library
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('DOCX export would be implemented here')),
    );
  }

  Future<void> _exportToHtml() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final filename = 'extracted_${DateTime.now().millisecondsSinceEpoch}.html';
      final path = p.join(dir.path, filename);
      final file = File(path);
      
      final htmlContent = '''
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Extracted Text</title>
    <style>
        body { font-family: Arial, sans-serif; line-height: 1.6; }
        .search-highlight { background-color: yellow; }
    </style>
</head>
<body>
    <pre>${_extractedText!.replaceAll('&', '&amp;').replaceAll('<', '&lt;').replaceAll('>', '&gt;')}</pre>
</body>
</html>
''';
      
      await file.writeAsString(htmlContent, flush: true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Exported as HTML')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to export HTML: $e')),
      );
    }
  }

  Future<void> _copyToClipboard() async {
    if (_extractedText != null && _extractedText!.isNotEmpty) {
      await Clipboard.setData(ClipboardData(text: _extractedText!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Copied to clipboard')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No text to copy')),
      );
    }
  }

  Future<void> _shareTxtFile() async {
    if (_lastSavedTxtPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Save the text first to share.')));
      return;
    }
    await Share.shareXFiles([XFile(_lastSavedTxtPath!)],
        text: 'Extracted text from PDF');
  }

  void _loadRecentFile(String filePath) async {
    try {
      setState(() {
        _isLoading = true;
        _progress = 0.0;
      });

      final file = File(filePath);
      final bytes = await file.readAsBytes();
      final platformFile = PlatformFile(
        name: p.basename(filePath),
        path: filePath,
        size: bytes.length,
        bytes: bytes,
      );

      await _extractTextFromFile(platformFile);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading file: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildFileInfo() {
    if (_fileName == null) return SizedBox();
    
    return Card(
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('File Information', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(height: 8),
            Text('Name: $_fileName', overflow: TextOverflow.ellipsis),
            if (_fileSize != null) Text('Size: ${(_fileSize! / 1024).toStringAsFixed(1)} KB'),
            if (_pageCount != null) Text('Pages: $_pageCount'),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentFiles() {
    if (_recentFiles.isEmpty) return SizedBox();
    
    return ExpansionTile(
      title: Text('Recent Files (${_recentFiles.length})'),
      children: [
        for (final filePath in _recentFiles.take(5))
          ListTile(
            leading: Icon(Icons.description),
            title: Text(p.basename(filePath), overflow: TextOverflow.ellipsis),
            onTap: () => _loadRecentFile(filePath),
            trailing: IconButton(
              icon: Icon(Icons.close, size: 18),
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                setState(() {
                  _recentFiles.remove(filePath);
                });
                await prefs.setStringList('recentFiles', _recentFiles);
              },
            ),
          ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search in text',
                prefixIcon: Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty ? IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                      _searchResults = [];
                      _currentSearchIndex = -1;
                    });
                  },
                ) : null,
              ),
            ),
            if (_searchResults.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    Text('${_searchResults.length} results found'),
                    Spacer(),
                    IconButton(
                      icon: Icon(Icons.arrow_upward),
                      onPressed: () => _navigateSearch(-1),
                      tooltip: 'Previous result',
                    ),
                    IconButton(
                      icon: Icon(Icons.arrow_downward),
                      onPressed: () => _navigateSearch(1),
                      tooltip: 'Next result',
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormattingOptions() {
    return ExpansionTile(
      title: Text('Text Processing Options'),
      children: [
        SwitchListTile(
          title: Text('Preserve Formatting'),
          value: _preserveFormatting,
          onChanged: (value) => setState(() => _preserveFormatting = value),
        ),
        SwitchListTile(
          title: Text('Include Page Numbers'),
          value: _includePageNumbers,
          onChanged: (value) => setState(() => _includePageNumbers = value),
        ),
        SwitchListTile(
          title: Text('Remove Empty Lines'),
          value: _removeEmptyLines,
          onChanged: (value) => setState(() => _removeEmptyLines = value),
        ),
        SwitchListTile(
          title: Text('Remove Headers/Footers'),
          value: _removeHeaderFooter,
          onChanged: (value) => setState(() => _removeHeaderFooter = value),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF → Text Extractor'),
        actions: [
          if (_multipleExtractedTexts != null && _multipleExtractedTexts!.length > 1)
            IconButton(
              icon: Icon(Icons.navigate_before),
              onPressed: _currentFileIndex > 0 ? () {
                setState(() {
                  _currentFileIndex--;
                  _extractedText = _multipleExtractedTexts![_currentFileIndex];
                });
              } : null,
            ),
          if (_multipleExtractedTexts != null && _multipleExtractedTexts!.length > 1)
            Text('${_currentFileIndex + 1}/${_multipleExtractedTexts!.length}'),
          if (_multipleExtractedTexts != null && _multipleExtractedTexts!.length > 1)
            IconButton(
              icon: Icon(Icons.navigate_next),
              onPressed: _currentFileIndex < _multipleExtractedTexts!.length - 1 ? () {
                setState(() {
                  _currentFileIndex++;
                  _extractedText = _multipleExtractedTexts![_currentFileIndex];
                });
              } : null,
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // File selection buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Single PDF'),
                    onPressed: _isLoading ? null : _pickAndExtractText,
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Multiple PDFs'),
                    onPressed: _isLoading ? null : _pickMultiplePdfs,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Progress indicator
            if (_isLoading) LinearProgressIndicator(value: _progress),
            const SizedBox(height: 12),

            // Recent files
            _buildRecentFiles(),

            // File information
            _buildFileInfo(),

            // Search bar
            _buildSearchBar(),

            // Formatting options
            _buildFormattingOptions(),

            // Extracted text area
            Expanded(
              child: _extractedText == null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.description, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('No text extracted yet.\nSelect a PDF file to begin.', 
                               textAlign: TextAlign.center,
                               style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    )
                  : Column(
                      children: [
                        if (_searchResults.isNotEmpty)
                          Padding(
                            padding: EdgeInsets.all(8),
                            child: Text('${_searchResults.length} matches found',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        Expanded(
                          child: Scrollbar(
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.all(8),
                              child: _isEditing
                                  ? TextField(
                                      controller: _textEditingController,
                                      maxLines: null,
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(),
                                        hintText: 'Edit extracted text...'
                                      ),
                                    )
                                  : SelectableText.rich(
                                      TextSpan(
                                        children: _highlightSearchResults(
                                          _extractedText ?? '', 
                                          _searchQuery
                                        ),
                                      ),
                                      style: TextStyle(fontSize: 15),
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
            ),

            const SizedBox(height: 12),

            // Action buttons
            Row(
              children: [
                if (_isEditing) ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.save),
                      label: Text('Save Changes'),
                      onPressed: _saveEditedText,
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.cancel),
                      label: Text('Cancel'),
                      onPressed: _toggleEditMode,
                    ),
                  ),
                ] else ...[
                  IconButton(
                    tooltip: 'Edit Text',
                    icon: Icon(Icons.edit),
                    onPressed: (_extractedText == null || _isLoading)
                        ? null
                        : _toggleEditMode,
                  ),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.copy_all),
                      label: Text('Copy'),
                      onPressed: (_extractedText == null || _isLoading)
                          ? null
                          : _copyToClipboard,
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.save_alt),
                      label: Text('Export'),
                      onPressed: (_extractedText == null || _isLoading)
                          ? null
                          : _exportToDifferentFormats,
                    ),
                  ),
                  SizedBox(width: 8),
                  IconButton(
                    tooltip: 'Share File',
                    icon: Icon(Icons.share),
                    onPressed: (_lastSavedTxtPath == null) ? null : _shareTxtFile,
                  ),
                ],
              ],
            ),

            if (_lastSavedTxtPath != null) ...[
              const SizedBox(height: 8),
              Text(
                'Last saved: ${p.basename(_lastSavedTxtPath!)}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              )
            ]
          ],
        ),
      ),
    );
  }
}
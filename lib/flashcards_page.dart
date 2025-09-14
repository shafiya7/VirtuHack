import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'dart:io';
import '../services/gemini_service.dart';

class FlashcardsPage extends StatefulWidget {
  const FlashcardsPage({super.key});

  @override
  State<FlashcardsPage> createState() => _FlashcardsPageState();
}

class _FlashcardsPageState extends State<FlashcardsPage> {
  final _gemini = GeminiService();
  PlatformFile? _picked;
  List<String> _flashcards = [];
  String? _error;
  bool _busy = false;
  int _currentIndex = 0;

  Future<void> _pickPdf() async {
    setState(() {
      _error = null;
      _flashcards = [];
      _picked = null;
    });

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (!mounted) return;
    if (result != null && result.files.isNotEmpty) {
      setState(() => _picked = result.files.single);
    }
  }

  Future<void> _generateFlashcards() async {
    if (_picked == null) return;
    setState(() {
      _error = null;
      _flashcards = [];
      _busy = true;
    });

    try {
      
      final bytes = File(_picked!.path!).readAsBytesSync();
      final pdf = PdfDocument(inputBytes: bytes);

      String text = '';
      for (int i = 0; i < (pdf.pages.count > 5 ? 5 : pdf.pages.count); i++) {
        final pageText = PdfTextExtractor(pdf)
            .extractText(startPageIndex: i, endPageIndex: i);
        text += "$pageText\n";
      }
      pdf.dispose();


      if (text.length > 4000) {
        text = text.substring(0, 4000);
      }


      final response = await _gemini.generateSummary(
        "Extract 10-15 flashcards from this document. "
        "Each flashcard should be concise and cover an important concept, "
        "formatted as either 'Q: ... → A: ...' or '• Key point ...'. "
        "Return one flashcard per line, no numbering, no extra explanation.\n\n$text",
      );

      setState(() {
        _flashcards = response
            .split("\n")
            .where((line) => line.trim().isNotEmpty)
            .toList();
        _currentIndex = 0;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _busy = false);
    }
  }

  void _nextCard() {
    if (_flashcards.isEmpty) return;
    setState(() {
      _currentIndex = (_currentIndex + 1) % _flashcards.length;
    });
  }

  void _prevCard() {
    if (_flashcards.isEmpty) return;
    setState(() {
      _currentIndex = (_currentIndex - 1 + _flashcards.length) % _flashcards.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Flashcards Generator")),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_picked == null) ...[
                FilledButton.icon(
                  onPressed: _busy ? null : _pickPdf,
                  icon: const Icon(Icons.upload_file),
                  label: const Text("Choose PDF"),
                ),
              ] else if (_flashcards.isEmpty && !_busy) ...[
                Text("Selected: ${_picked!.name}"),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: _generateFlashcards,
                  child: const Text("Generate Flashcards"),
                ),
              ] else if (_busy) ...[
                const CircularProgressIndicator(),
              ] else if (_error != null) ...[
                Text("Error: $_error",
                    style: const TextStyle(color: Colors.red)),
              ] else ...[
                Card(
                  margin: const EdgeInsets.all(20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    width: double.infinity,
                    height: 250,
                    alignment: Alignment.center,
                    child: Text(
                      _flashcards[_currentIndex],
                      style: const TextStyle(fontSize: 20),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "Card ${_currentIndex + 1} of ${_flashcards.length}",
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _prevCard,
                      icon: const Icon(Icons.arrow_back),
                      label: const Text("Prev"),
                    ),
                    const SizedBox(width: 20),
                    ElevatedButton.icon(
                      onPressed: _nextCard,
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text("Next"),
                    ),
                  ],
                )
              ],
            ],
          ),
        ),
      ),
    );
  }
}

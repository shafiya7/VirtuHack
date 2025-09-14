import 'dart:typed_data'; 
import 'package:Doculearn/services/gemini_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class PdfSummarizerPage extends StatefulWidget {
  const PdfSummarizerPage({super.key});

  @override
  State<PdfSummarizerPage> createState() => _PdfSummarizerPageState();
}

class _PdfSummarizerPageState extends State<PdfSummarizerPage> {
  final _gemini = GeminiService(); // NOTE: don’t hardcode API keys in prod web builds
  PlatformFile? _picked;
  String? _summary;
  String? _error;
  bool _busy = false;

  Future<void> _pickPdf() async {
    setState(() {
      _error = null;
      _summary = null;
      _picked = null;
    });

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf'],
      withData: true, // ✅ REQUIRED so we get PlatformFile.bytes on web
    );

    if (!mounted) return;
    if (result != null && result.files.isNotEmpty) {
      setState(() => _picked = result.files.single);
    }
  }

  Future<void> _summarize() async {
    if (_picked == null) return;
    setState(() {
      _error = null;
      _summary = null;
      _busy = true;
    });

    try {
      // ✅ BYTES-FIRST (works on web & iOS)
      late final Uint8List bytes;
      if (_picked!.bytes != null) {
        bytes = _picked!.bytes!;
      } else {
         throw Exception(
          'No bytes available. Make sure FilePicker was called with withData: true.',
        );
      }
      final document = PdfDocument(inputBytes: bytes);
      final extractor = PdfTextExtractor(document);
      final pageCount = document.pages.count;
      final maxPages = pageCount > 3 ? 3 : pageCount;

      final buf = StringBuffer();
      for (var i = 0; i < maxPages; i++) {
        buf.write(extractor.extractText(startPageIndex: i, endPageIndex: i));
        buf.write('\n');
      }
      document.dispose();

      var text = buf.toString().trim();
      if (text.isEmpty) {
        throw Exception('Could not extract text from the selected PDF.');
      }
      if (text.length > 3000) {
        text = text.substring(0, 3000);
      }

      final summary = await _gemini.generateSummary(
        "Summarize this PDF:\n"
        "- 4–6 sentence executive summary\n"
        "- Key bullet points\n\n"
        "$text",
      );

      if (!mounted) return;
      setState(() => _summary = summary);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (!mounted) return;
      setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PDF Summarizer')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 820),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Upload and Summarize',
                        style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 8),
                    Text(
                      'Choose a PDF to generate an executive summary + key points.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 20),

                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      alignment: WrapAlignment.center,
                      children: [
                        FilledButton.icon(
                          onPressed: _busy ? null : _pickPdf,
                          icon: const Icon(Icons.upload_file),
                          label: const Text('Choose PDF'),
                        ),
                        FilledButton(
                          onPressed: (_picked != null && !_busy) ? _summarize : null,
                          child: _busy
                              ? const SizedBox(
                                  width: 18, height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('Summarize'),
                        ),
                        OutlinedButton.icon(
                          onPressed: (_picked == null && _summary == null && _error == null)
                              ? null
                              : () => setState(() {
                                    _picked = null;
                                    _summary = null;
                                    _error = null;
                                  }),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Reset'),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    if (_picked != null)
                      Text('Selected: ${_picked!.name}',
                          style: Theme.of(context).textTheme.bodySmall),

                    const SizedBox(height: 16),

                    if (_error != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.red.withOpacity(.4)),
                        ),
                        child: Text(_error!, style: const TextStyle(color: Colors.red)),
                      ),

                    if (_summary != null) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Text('Summary',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  )),
                          const Spacer(),
                          IconButton(
                            tooltip: 'Copy',
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: _summary!));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Summary copied')),
                              );
                            },
                            icon: const Icon(Icons.copy_outlined),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: SelectableText(_summary!),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

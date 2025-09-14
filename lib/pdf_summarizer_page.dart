import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/openai_service.dart';

class PdfSummarizerPage extends StatefulWidget {
  const PdfSummarizerPage({super.key});

  @override
  State<PdfSummarizerPage> createState() => _PdfSummarizerPageState();
}

class _PdfSummarizerPageState extends State<PdfSummarizerPage> {
  final _svc = OpenAIService(); // reads API key from --dart-define
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
      withData: true, // ✅ REQUIRED for web (provides PlatformFile.bytes)
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
      final text = await _svc.summarizePdfFile(_picked!);
      if (!mounted) return;
      setState(() => _summary = text);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (!mounted) return;
      setState(() => _busy = false);
    }
  }

  static String _formatBytes(int? bytes) {
    if (bytes == null) return '';
    const units = ['B', 'KB', 'MB', 'GB'];
    var size = bytes.toDouble();
    var i = 0;
    while (size >= 1024 && i < units.length - 1) {
      size /= 1024;
      i++;
    }
    return '${size.toStringAsFixed(1)} ${units[i]}';
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
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Upload and Summarize',
                        style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 8),
                    Text(
                      'Pick a PDF and get an executive summary + key bullets.',
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

                    const SizedBox(height: 10),

                    if (_picked != null)
                      Text(
                        'Selected: ${_picked!.name}'
                        '${_picked!.size > 0 ? ' · ${_formatBytes(_picked!.size)}' : ''}',
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),

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
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text('Summary',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
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
                        constraints: const BoxConstraints(minHeight: 120),
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

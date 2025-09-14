import 'dart:convert';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class OpenAIService {
  OpenAIService({String? apiKey})
      : _apiKey = apiKey ??
            const String.fromEnvironment(
              'OPENAI_API_KEY',
              defaultValue: 'KEY', // for local testing only
            );

  final String _base = 'https://api.openai.com/v1';
  final String _apiKey;

  /// Upload a PDF to the Files API. On web we MUST use bytes (no .path).
  Future<String> uploadPdf(PlatformFile f) async {
    final uri = Uri.parse('$_base/files');
    final req = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $_apiKey'
      ..fields['purpose'] = 'user_data';

    // ✅ Prefer bytes everywhere; on web .path is not available.
    http.MultipartFile part;
    if (f.bytes != null) {
      part = http.MultipartFile.fromBytes(
        'file',
        f.bytes as Uint8List,
        filename: f.name,
        contentType: MediaType('application', 'pdf'),
      );
    } else if (!kIsWeb && f.path != null) {
      // Native fallback when bytes aren't provided (mobile/desktop)
      part = await http.MultipartFile.fromPath(
        'file',
        f.path!,
        filename: f.name,
        contentType: MediaType('application', 'pdf'),
      );
    } else {
      throw Exception(
        'On web, PlatformFile.bytes must be available. Set withData: true in FilePicker.',
      );
    }

    req.files.add(part);

    final streamed = await req.send();
    final res = await http.Response.fromStream(streamed);
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Upload failed: ${res.statusCode} ${res.body}');
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final fileId = data['id'] as String?;
    if (fileId == null || fileId.isEmpty) {
      throw Exception('Upload succeeded but no file_id returned.');
    }
    return fileId;
  }

  /// Ask the Responses API to summarize the uploaded file.
  Future<String> summarizeFileId({
    required String fileId,
    String model = 'gpt-4o-mini',
    String? prompt,
  }) async {
    final uri = Uri.parse('$_base/responses');
    final body = {
      'model': model,
      'input': [
        {
          'role': 'user',
          'content': [
            {
              'type': 'input_text',
              'text': prompt ??
                  'Summarize the attached PDF with:\n'
                      '• A 4–6 sentence executive summary\n'
                      '• 6–10 bullet points of key sections, main claims, and data-backed results\n'
                      '• Any limitations/assumptions\n'
                      'Keep it concise and faithful to the source.'
            },
            {'type': 'input_file', 'file_id': fileId},
          ],
        },
      ],
    };

    final res = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Summarize failed: ${res.statusCode} ${res.body}');
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final outputText = data['output_text'];
    if (outputText is String && outputText.trim().isNotEmpty) return outputText;

    final output = data['output'];
    if (output is List && output.isNotEmpty) {
      final first = output.first;
      if (first is Map && first['content'] is List) {
        final content = first['content'] as List;
        if (content.isNotEmpty && content.first is Map) {
          final text = content.first['text'];
          if (text is String && text.trim().isNotEmpty) return text;
        }
      }
    }

    // Fallback for schema variants
    return 'Received response but could not parse summary.\n\n'
        '${const JsonEncoder.withIndent("  ").convert(data)}';
  }

  Future<String> summarizePdfFile(PlatformFile file,
      {String model = 'gpt-4o-mini', String? prompt}) async {
    final id = await uploadPdf(file);
    return summarizeFileId(fileId: id, model: model, prompt: prompt);
  }
}

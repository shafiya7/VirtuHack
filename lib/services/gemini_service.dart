import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  final _apiKey = 'AIzaSyDBxtaLaVMW2qfSdMLrquy79-i6xsX_VTA';
  late final GenerativeModel _model;

  GeminiService() {
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: _apiKey,
    );
  }

  Future<String> generateSummary(String prompt) async {
    final response = await _model.generateContent([Content.text(prompt)]);
    return response.text ?? "No summary generated.";
  }
}

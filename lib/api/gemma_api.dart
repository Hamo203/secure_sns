// gemma_api.dart
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GemmaApi {
  Future<List<String>> sendText(String inputText) async {
    final url = Uri.parse(dotenv.env['GEMMA_API_URL']!);
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode({"text": inputText}),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> decodedResponse = jsonDecode(utf8.decode(response.bodyBytes));
      final List<dynamic> responses = decodedResponse["responses"];
      return responses.map((e) => e.toString()).toList();
    } else {
      return ['Error: Failed to fetch suggestions (${response.statusCode})'];
    }
  }
}

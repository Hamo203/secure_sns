import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NaturalLanguageService {
  final String _apiKey = dotenv.env['API_KEY']!; // Google Cloud APIキーを設定

  Future<Map<String, double>?> analyzeSentiment(String text) async {
    final url = Uri.parse(
        'https://language.googleapis.com/v1/documents:analyzeSentiment?key=$_apiKey');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'document': {
          'type': 'PLAIN_TEXT',
          'content': text,
        },
        'encodingType': 'UTF8',
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final sentiment = data['documentSentiment'];

      double score = sentiment['score'].toDouble();
      double magnitude = sentiment['magnitude'].toDouble();


      return {'score': score, 'magnitude': magnitude};
    } else {
      print('Error: ${response.body}');
      return null;
    }
  }
}

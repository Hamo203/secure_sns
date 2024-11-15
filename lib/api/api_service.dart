import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiService{
  final String baseUrl;

  ApiService({required this.baseUrl});

  Future<Map<String, String>> classifyText(String text) async {
    final url = Uri.parse('$baseUrl/classify');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'text': text}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return {
        'non_offensive': data['non_offensive'].toString(),
        'gray_zone': data['gray_zone'].toString(),
        'offensive': data['offensive'].toString(),
      };
    } else {
      throw Exception('Failed to classify text');
    }
  }
}
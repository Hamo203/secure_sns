import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GemmaApi extends StatefulWidget {
  @override
  _GemmaApiState createState() => _GemmaApiState();
}

class _GemmaApiState extends State<GemmaApi> {
  final TextEditingController _controller = TextEditingController();
  List<String> displayResponses = [];

  Future<void> sendText(String inputText) async {
    final url = Uri.parse('http://172.27.167.202:8001/docs/classify');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode({"text": inputText}),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> decodedResponse = jsonDecode(utf8.decode(response.bodyBytes));
      final List<dynamic> responses = decodedResponse["responses"];

      setState(() {
        displayResponses = responses.map((e) => e.toString()).toList();
      });
    } else {
      setState(() {
        displayResponses = ['Error: ${response.statusCode}'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("テキスト入力")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: "メッセージを入力してください",
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                sendText(_controller.text);
              },
              child: Text("送信"),
            ),
            SizedBox(height: 20),
            Text("サーバーからの応答:"),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,  // 必要なスペースのみ使うよう設定
                itemCount: displayResponses.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(displayResponses[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

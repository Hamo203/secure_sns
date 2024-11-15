// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'api_service.dart';
import 'gemma_api.dart';

Future<void> main() async {
  // Flutterのバインディングを初期化
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final ApiService apiService = ApiService(baseUrl: dotenv.env['BASE_URL']!);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      //title: 'テキスト分類アプリ',
      home: TextClassificationPage(apiService: apiService),
    );
  }
}

//攻撃性判定を行う場所
class TextClassificationPage extends StatefulWidget {
  final ApiService apiService;

  TextClassificationPage({required this.apiService});

  @override
  _TextClassificationPageState createState() => _TextClassificationPageState();
}

class _TextClassificationPageState extends State<TextClassificationPage> {
  final TextEditingController _controller = TextEditingController();
  String _resultText = '';

  void _classifyText() async {
    String text = _controller.text;
    try {
      Map<String, String> result = await widget.apiService.classifyText(text);
      setState(() {
        _resultText = '''
        攻撃的でない発言: ${result['non_offensive']}
        グレーゾーンの発言: ${result['gray_zone']}
        攻撃的な発言: ${result['offensive']}
        ''';
      });
    } catch (e) {
      setState(() {
        _resultText = 'エラーが発生しました: $e';
      });
    }
  }

  void _changeText() async{
    String text = _controller.text;

    try{
      setState(() {
        _resultText = '''
        
        ''';
      });
    }catch(e){
      setState(() {
        _resultText = 'エラーが発生しました: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('テキスト分類アプリ'),
        ),
        body: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _controller,
                decoration: InputDecoration(labelText: 'テキストを入力してください'),
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _classifyText,
                child: Text('分類'),
              ),
              SizedBox(height: 16.0),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    _resultText,
                    style: TextStyle(fontSize: 16.0),
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}

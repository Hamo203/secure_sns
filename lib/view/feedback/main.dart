// main.dart

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'nvc_feedback_page.dart'; // NVCFeedbackPage のファイルをインポート

Future<void> main() async {
  // Flutterのバインディングを初期化
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");
  runApp(MyDebugApp());
}

class MyDebugApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("他のページ")),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NvcFeedbackPage(
                  originalContent: "ばーか",
                ),
              ),
            );
          },
          child: Text("NVC フィードバックページを開く"),
        ),
      ),
    );
  }
}

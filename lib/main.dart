import 'package:flutter/material.dart';
import 'package:secure_sns/view/account/accountpage.dart';
import 'package:secure_sns/view/talk/chat.dart';
import 'package:secure_sns/view/timeline/postpage.dart';
import 'package:secure_sns/view/timeline/timeline.dart';

import 'navigation.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: ChatPage()
    );
  }
}

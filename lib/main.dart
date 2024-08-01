import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:secure_sns/view/account/accountpage.dart';
import 'package:secure_sns/view/startup/login.dart';
import 'package:secure_sns/view/startup/registerpage.dart';
import 'package:secure_sns/view/talk/chat.dart';
import 'package:secure_sns/view/talk/roomlist.dart';
import 'package:secure_sns/view/test.dart';
import 'package:secure_sns/view/timeline/postpage.dart';
import 'package:secure_sns/view/timeline/timeline.dart';

import 'navigation.dart';

Future<void> main()  async{
  //Firebaseのパッケージを使用する際に絶対いる
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
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
      home: Login()
    );
  }
}

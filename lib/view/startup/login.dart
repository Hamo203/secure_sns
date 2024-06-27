import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ようこそ!"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding:EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                children: [
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'ユーザーID',
                      filled: true,
                      fillColor: Colors.grey.shade200,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      counterText: '10/20',
                    ),
                  ),
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'メールアドレス',
                      filled: true,
                      fillColor: Colors.grey.shade200,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),

                    ),
                  ),
                  SizedBox(height: 30,),
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'パスワード',
                      filled: true,
                      fillColor: Colors.grey.shade200,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      errorText: '半角英字は含めないでください',
                      counterText: '10/20',
                    ),
                  ),

                ],
              ),
              ElevatedButton(
                  onPressed: (){},
                  child: Text("次へ")
              )
            ],
          ),
        ),

      ),

    );
  }
}

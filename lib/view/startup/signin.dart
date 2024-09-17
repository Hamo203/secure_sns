import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:secure_sns/navigation.dart';
import 'package:secure_sns/view/startup/login.dart';
import 'package:secure_sns/view/startup/registerpage2.dart';

import '../account/user_auth.dart';

class Signin extends StatefulWidget {
  const Signin({super.key});

  @override
  State<Signin> createState() => _SigninState();
}

class _SigninState extends State<Signin> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String email = "";
  String password = "";
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  Future<void> _createUser(BuildContext context, String email, String password) async {
    try {
      await userAuth.createUserWithEmailAndPassword(email: email, password: password);
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => Registerpage2()));
    } catch (e) {
      print(e);
      Fluttertoast.showToast(msg: "Firebaseの登録に失敗しました");
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              Container(
                width: screenWidth , // 画面幅
                height: screenHeight , // 画面高さ
                clipBehavior: Clip.antiAlias,
                decoration: ShapeDecoration(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      //装飾の〇 下の部分
                      left: screenWidth * 0.7, // 画面幅の70%
                      top: screenHeight * 0.8, // 画面高さの80%
                      child: Container(
                        width: screenWidth * 0.5, // 画面幅の50%
                        height: screenHeight * 0.3, // 画面高さの30%
                        decoration: ShapeDecoration(
                          color: Color(0xFFF9E4C8),
                          shape: OvalBorder(),
                        ),
                      ),
                    ),
                    Positioned(
                      //装飾の〇 上の部分
                      left: screenWidth * -0.1, // 画面幅の-10%
                      top: screenHeight * -0.05, // 画面高さの-5%
                      child: Container(
                        width: screenWidth * 0.4, // 画面幅の40%
                        height: screenHeight * 0.2, // 画面高さの20%
                        decoration: ShapeDecoration(
                          color: Color(0xFFC5D8E7),
                          shape: OvalBorder(),
                        ),
                      ),
                    ),
                    Positioned(
                      //アプリ名
                      left: screenWidth * 0.23, // 画面幅の20%
                      top: screenHeight * 0.25, // 画面高さの20%
                      child: SizedBox(
                        width: screenWidth * 0.8, // 画面幅の60%
                        height: screenHeight * 0.5, // 画面高さの10%
                        child: Text(
                          'Pals Place',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: screenWidth * 0.1, // 画面幅の10%
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w300,
                            height: 1,
                          ),
                        ),
                      ),
                    ),
        
                    Positioned(
                      left: screenWidth * 0.15, // 画面幅の15%
                      top: screenHeight * 0.37, // 画面高さの37%
                      child: Container(
                        width: screenWidth * 0.7, // 画面幅の70%
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _emailController,
                                decoration: InputDecoration(
                                  labelText: 'メールアドレスを入力',
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: BorderSide.none,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: BorderSide(
                                      color: Color(0xFFF6CBD1),
                                      width: 3,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: BorderSide(
                                      color: Color(0xFFF6CBD1),
                                      width: 3,
                                    ),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: BorderSide(
                                      color: Colors.red,
                                      width: 3,
                                    ),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: BorderSide(
                                      color: Colors.red,
                                      width: 3,
                                    ),
                                  ),
                                ),
                                onSaved: (String? value) {
                                  email = value!;
                                },
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'メールアドレスは必須項目です';
                                  } else if (value.length < 6) {
                                    return 'メールアドレスが短すぎます';
                                  } else {
                                    return null;
                                  }
                                },
                              ),
                              SizedBox(height: screenHeight * 0.05),
                              TextFormField(
                                controller: _passwordController,
                                decoration: InputDecoration(
                                  labelText: 'パスワードを入力',
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: BorderSide.none,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: BorderSide(
                                      color: Color(0xFFC5D8E7),
                                      width: 3,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: BorderSide(
                                      color: Color(0xFFC5D8E7),
                                      width: 3,
                                    ),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: BorderSide(
                                      color: Colors.red,
                                      width: 3,
                                    ),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: BorderSide(
                                      color: Colors.red,
                                      width: 3,
                                    ),
                                  ),
                                ),
                                onSaved: (String? value) {
                                  password = value!;
                                },
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'パスワードは必須項目です';
                                  } else if (value.length < 6) {
                                    return 'パスワードは6桁以上です';
                                  } else {
                                    return null;
                                  }
                                },
                              ),
                              SizedBox(height: screenHeight * 0.05),
                              Container(
                                width: screenWidth * 0.7, // 画面幅の70%
                                height: screenHeight * 0.07, // 画面高さの7%
                                child: Stack(
                                  children: [
                                    Positioned(
                                      left: 0,
                                      top: 0,
                                      child: TextButton(
                                        style: TextButton.styleFrom(
                                          backgroundColor: Color(0xFFF2D3B5),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(15),
                                          ),
                                          minimumSize: Size(screenWidth * 0.7, screenHeight * 0.07), // 画面幅の70%, 画面高さの7%
                                        ),
                                        onPressed: () async {
                                          if (_formKey.currentState!.validate()) {
                                            _formKey.currentState!.save();
                                            await _createUser(context, email, password);
                                          }
                                        },
                                        child: const Center(
                                          child: Text(
                                            'メールアドレスで登録',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w400,
                                              height: 0,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
        
                    Positioned(
                      left: screenWidth * 0.22, // 画面幅の25%
                      top: screenHeight * 0.87, // 画面高さの87%
                      child: GestureDetector(
                        onTap: (){
                          Navigator.push(
                              context, MaterialPageRoute(builder: (context) => Login()));
                        },
                        child: SizedBox(
                          width: screenWidth * 0.7, // 画面幅の50%
                          height: screenHeight * 0.03, // 画面高さの3%
                          child: Text(
                            'すでに登録済みの場合はこちら',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: screenWidth * 0.04, // 画面幅の3%
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w400,
                              height: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../navigation.dart';
import '../account/user_auth.dart';

class Registerpage2 extends StatefulWidget {
  const Registerpage2({super.key});

  @override
  State<Registerpage2> createState() => _Registerpage2State();
}

class _Registerpage2State extends State<Registerpage2> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String email = "";
  String password = "";
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  Future<void> _createUser(BuildContext context, String email, String password) async {
    try {
      await userAuth.createUserWithEmailAndPassword(email: email, password: password);
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => Navigation()));
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
                  width: screenWidth,
                  height: screenHeight,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(color: Colors.white),
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
                        left: screenWidth * 0.2, // 画面幅の20%
                        top: screenHeight * 0.25, // 画面高さの25%
                        child: Text(
                          'はじめまして！',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: screenWidth * 0.08,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w400,
                            height: 1,
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
                                        color: Color(0xFFF9E4C8),
                                        width: 3,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: BorderSide(
                                        color: Color(0xFFF9E4C8),
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
                                GestureDetector(
                                  onTap: () async {
                                    if (_formKey.currentState!.validate()) {
                                      _formKey.currentState!.save();
                                      await _createUser(context, email, password);
                                    }
                                  },
                                  child: Container(
                                    width: screenWidth * 0.7, // 画面幅の70%
                                    height: screenHeight * 0.07, // 画面高さの7%
                                    child: Stack(
                                      children: [
                                        Positioned(
                                          left: screenWidth * 0.14,
                                          top: 0,
                                          child: TextButton(
                                            style: TextButton.styleFrom(
                                              backgroundColor: Color(0xFFF6CBD1),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(15),
                                              ),
                                              minimumSize: Size(screenWidth * 0.4, screenHeight * 0.07), // 画面幅の70%, 画面高さの7%
                                            ),
                                            onPressed: () async {
                                              if (_formKey.currentState!.validate()) {
                                                _formKey.currentState!.save();
                                                await _createUser(context, email, password);
                                              }
                                            },
                                            child: const Center(
                                              child: Text(
                                                '登録',
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
                                ),
                              ],
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
        ));
  }
}

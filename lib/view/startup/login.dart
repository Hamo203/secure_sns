import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:secure_sns/view/startup/registerpage.dart';
import 'package:secure_sns/view/startup/signin.dart';

import '../../navigation.dart';
import '../account/user_auth.dart';

class Login extends StatefulWidget {
  const Login({super.key});
  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool _isObscure = true;
  final GlobalKey<FormState> _formKey= GlobalKey<FormState>();
  String email="";
  String password="";

  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  Future<void> _signIn(BuildContext context,String email,String password) async{
    try{
      await userAuth.signInWithEmailAndPassword(email: email, password: password);
      Navigator.pushAndRemoveUntil(
          context, MaterialPageRoute(builder: (context) => Navigation()),(_) => false);
    }catch(e){
      print(e);
      Fluttertoast.showToast(msg: "Firebaseのログインに失敗しました");
    }
  }
  //Regeister画面へ遷移
  void _RegisterPage(){
    Navigator.pushAndRemoveUntil(
        context, MaterialPageRoute(builder: (context) => Signin()),(_) => false);
  }

  //borderの型
  OutlineInputBorder _buildOutlineInputBorder({required Color color, required double width}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: BorderSide(
        color: color,
        width: width,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
        body:SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: screenWidth,
                height: screenHeight,
                decoration: BoxDecoration(color: Colors.white),
                child: Stack(
                  children: [
                    // 青い丸 (左上)
                    Align(
                      alignment: Alignment(-1.2, -1.1),
                      child: Container(
                        width: screenWidth * 0.4, // 画面幅の40%
                        height: screenHeight * 0.2, // 画面高さの20%
                        decoration: ShapeDecoration(
                          color: Color(0xFFC5D8E7),
                          shape: OvalBorder(),
                        ),
                      ),
                    ),
                    // オレンジの丸 (右下)
                    Align(
                      alignment: Alignment(1.5, 1.5),
                      child: Container(
                        width: screenWidth * 0.5, // 画面幅の50%
                        height: screenHeight * 0.3, // 画面高さの30%
                        decoration: ShapeDecoration(
                          color: Color(0xFFF9E4C8),
                          shape: OvalBorder(),
                        ),
                      ),
                    ),
                    // コンテンツ (タイトル, メアド, パスワード, ログインボタン, 登録リンク)
                    Center(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // タイトル
                            Text(
                              'Palceでログイン',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: screenWidth * 0.07,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w400,
                                height: 1,
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.05), // スペース
                            // メールアドレス入力
                            Container(
                              width: screenWidth * 0.7, // 画面幅の70%
                              child: TextFormField(
                                controller: _emailController,
                                decoration: InputDecoration(
                                  labelText: 'メールアドレスを入力',
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: _buildOutlineInputBorder(color: Colors.transparent, width: 0), // default border
                                  enabledBorder: _buildOutlineInputBorder(color: Color(0xFFF9E4C8), width: 3), // enabled border
                                  focusedBorder: _buildOutlineInputBorder(color: Color(0xFFF9E4C8), width: 3), // focused border
                                  errorBorder: _buildOutlineInputBorder(color: Colors.red, width: 3), // error border
                                  focusedErrorBorder: _buildOutlineInputBorder(color: Colors.red, width: 3), // focused error border
                                ),
                                onSaved: (String? value) {
                                  email = value!;
                                },
                                validator: (value) {
                                  if (value!.isEmpty) return 'メールアドレスは必須項目です';
                                  String emailPattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
                                  RegExp regex = RegExp(emailPattern);
                                  if (!regex.hasMatch(value.trim())) {
                                    return '正しいメールアドレスを入力してください';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.05), // スペース
                            // パスワード入力
                            Container(
                              width: screenWidth * 0.7, // 画面幅の70%
                              child: TextFormField(
                                obscureText: _isObscure,
                                controller: _passwordController,
                                decoration: InputDecoration(
                                  labelText: 'パスワードを入力',
                                  filled: true,
                                  fillColor: Colors.white,
                                  suffixIcon: IconButton(
                                    icon: Icon(_isObscure ? Icons.visibility_off : Icons.visibility),
                                    onPressed: () {
                                      setState(() {
                                        _isObscure = !_isObscure;
                                      });
                                    },
                                  ),
                                  border: _buildOutlineInputBorder(color: Colors.transparent, width: 0), // default border
                                  enabledBorder: _buildOutlineInputBorder(color: Color(0xFFC5D8E7), width: 3), // enabled border
                                  focusedBorder: _buildOutlineInputBorder(color: Color(0xFFC5D8E7), width: 3), // focused border
                                  errorBorder: _buildOutlineInputBorder(color: Colors.red, width: 3), // error border
                                  focusedErrorBorder: _buildOutlineInputBorder(color: Colors.red, width: 3), // focused error border
                                ),
                                onSaved: (String? value) {
                                  password = value!;
                                },
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'パスワードは必須項目です';
                                  } else if (value.length < 6) return "パスワードは6桁以上です";
                                  return null;
                                },
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.05), // スペース
                            // ログインボタン
                            Container(
                              width: screenWidth * 0.7, // 画面幅の70%
                              child: TextButton(
                                style: TextButton.styleFrom(
                                  backgroundColor: Color(0xFFF6CBD1),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  minimumSize: Size(screenWidth * 0.4, screenHeight * 0.07), // 画面幅の40%, 画面高さの7%
                                ),
                                onPressed: () async {

                                  if (_formKey.currentState!.validate()) {
                                    _formKey.currentState!.save();
                                    print("email:$email,password:$password");
                                    await _signIn(context, email, password);
                                  }
                                },
                                child: Center(
                                  child: Text(
                                    'ログイン',
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
                            SizedBox(height: screenHeight * 0.05), // スペース
                            // 新規登録リンク
                            GestureDetector(
                              onTap: _RegisterPage,
                              child: Text(
                                '新規登録の場合はこちら',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: screenWidth * 0.04, // 画面幅の3%
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w400,
                                  height: 1,
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
            ],
          ),
        )
    );
  }
}



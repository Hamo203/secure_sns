import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    void _RegisterPage(){
      print("Registerへ");
    }

    return Scaffold(
        body:SingleChildScrollView(
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
                        top: screenHeight * 0.25, // 画面高さの20%
                        child: Text(
                          'おかえりなさい！',
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
                        //メアド入力
                        left: screenWidth * 0.15, // 画面幅の15%
                        top: screenHeight * 0.37, // 画面高さの37%
                        child: Container(
                          width: screenWidth * 0.7, // 画面幅の70%
                          child: TextField(
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
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: screenWidth * 0.15, // 画面幅の15%
                        top: screenHeight * 0.5, // 画面高さの50%
                        child: Container(
                          width: screenWidth * 0.7, // 画面幅の70%
                          child: TextField(
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
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: screenWidth * 0.3,
                        top: screenHeight * 0.63,
                        child: Container(
                          width: screenWidth * 0.7, // 画面幅の70%
                          height: screenHeight * 0.07, // 画面高さの7%
                          child: Stack(
                            children: [
                              Positioned(
                                left: 0,
                                top: 0,
                                child: Container(
                                  width: screenWidth * 0.4, // 画面幅の70%
                                  height: screenHeight * 0.07, // 画面高さの7%
                                  decoration: ShapeDecoration(
                                    color: Color(0xFFF6CBD1),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
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
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        left: screenWidth * 0.28, // 画面幅の25%
                        top: screenHeight * 0.77, // 画面高さの87%
                        child: GestureDetector(
                          onTap: _RegisterPage,
                          child: SizedBox(
                            width: screenWidth * 0.5, // 画面幅の50%
                            height: screenHeight * 0.03, // 画面高さの3%
                            child: Text(
                              'ログインの場合はこちら',
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
        )
    );
  }
}



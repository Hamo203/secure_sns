import 'package:flutter/material.dart';
import 'package:secure_sns/view/startup/login.dart';
import 'package:secure_sns/view/startup/registerpage2.dart';

class Registerpage extends StatefulWidget {
  const Registerpage({super.key});

  @override
  State<Registerpage> createState() => _RegisterpageState();
}

class _RegisterpageState extends State<Registerpage> {
  @override
  Widget build(BuildContext context) {
    // 画面のサイズを取得
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    void _registerWithEmail() {
      // メールアドレスで登録のロジックをここに追加
      print("メールアドレスで登録");
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => Registerpage2()));

    }
    void _registerWithGoogle() {
      // メールアドレスで登録のロジックをここに追加
      print("Googleで登録");
    }
    void _registerWithTwitter() {
      // メールアドレスで登録のロジックをここに追加
      print("Twitterで登録");
    }
    void _registerWithGithub() {
      // メールアドレスで登録のロジックをここに追加
      print("Githubで登録");
    }

    void _loginPage(){
      print("Loginへ");
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => Login()));
    }

    return Scaffold(
      body: Center(
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
                    left: screenWidth * 0.25, // 画面幅の20%
                    top: screenHeight * 0.25, // 画面高さの20%
                    child: SizedBox(
                      width: screenWidth * 0.6, // 画面幅の60%
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
                    //メアドで登録
                    left: screenWidth * 0.15, // 画面幅の15%
                    top: screenHeight * 0.37, // 画面高さの37%
                    child: TextButton(
                      style: TextButton.styleFrom(
                          backgroundColor:Color(0xFFF2D3B5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        minimumSize: Size(screenWidth * 0.7, screenHeight * 0.07),
                      ),
                      onPressed: (){
                        print("メールアドレス登録");
                        _registerWithEmail();
                      },
                      child: Center(
                        child: Text(
                          'メールアドレスで登録',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: screenWidth * 0.04, // 画面幅の3%
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: screenWidth * 0.15, // 画面幅の15%
                    top: screenHeight * 0.5, // 画面高さの50%
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor:Color(0xFFF7F7F7),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        minimumSize: Size(screenWidth * 0.7, screenHeight * 0.07),
                      ),
                      onPressed: _registerWithGoogle,
                      child: Center(
                        child: Text(
                          'Google で登録',
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
                  Positioned(
                    //Twitterで登録
                    left: screenWidth * 0.15, // 画面幅の15%
                    top: screenHeight * 0.62, // 画面高さの62%
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor:Color(0xFFC5D8E7),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        minimumSize: Size(screenWidth * 0.7, screenHeight * 0.07),
                      ),
                      onPressed: _registerWithTwitter,
                      child: Center(
                        child: Text(
                          'Twitter で登録',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: screenWidth * 0.04, // 画面幅の3%
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w400,
                            height: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: screenWidth * 0.15, // 画面幅の15%
                    top: screenHeight * 0.74, // 画面高さの74%
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor:Color(0xFFA5BACF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        minimumSize: Size(screenWidth * 0.7, screenHeight * 0.07),
                      ),
                      onPressed: _registerWithGithub,
                      child: Center(
                        child: Text(
                          'Github で登録',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: screenWidth * 0.04, // 画面幅の3%
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w400,
                            height: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: screenWidth * 0.22, // 画面幅の25%
                    top: screenHeight * 0.87, // 画面高さの87%
                    child: GestureDetector(
                      onTap: _loginPage,
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
    );
  }
}

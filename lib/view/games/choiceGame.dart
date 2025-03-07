import 'package:flutter/material.dart';
import 'package:secure_sns/view/games/emotionDiary.dart';
import 'package:secure_sns/view/games/quizScreen.dart';

class Choicegame extends StatefulWidget {
  const Choicegame({super.key});

  @override
  State<Choicegame> createState() => _ChoicegameState();
}

class _ChoicegameState extends State<Choicegame> {
  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          width: screenWidth,
          height: screenHeight,
          decoration: BoxDecoration(color: Colors.white),
          child: Stack(
            children: [
              // 青い丸 (左上)
              Align(
                alignment: Alignment(-1.5, -1.1),
                child: Container(
                  width: screenWidth * 0.4,
                  height: screenHeight * 0.2,
                  decoration: ShapeDecoration(
                    color: Color(0xFFC5D8E7),
                    shape: OvalBorder(),
                  ),
                ),
              ),
              // オレンジの丸 (右下)
              Align(
                alignment: Alignment(1.5, 1.8),
                child: Container(
                  width: screenWidth * 0.5,
                  height: screenHeight * 0.3,
                  decoration: ShapeDecoration(
                    color: Color(0xFFF9E4C8),
                    shape: OvalBorder(),
                  ),
                ),
              ),
              // 各ステップのコンテンツ
              _gamrChoiceStep(),
            ],
          ),
        ),
      ),
    );
  }
  Widget _gamrChoiceStep() {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: screenHeight * 0.1),
          Text(
            'ゲームをえらぼう!',
            style: TextStyle(
              color: Colors.black,
              fontSize: screenWidth * 0.1,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w400,
              height: 1,
            ),
          ),
          SizedBox(height: 19,),
          //書いてみるボタン
          Container(
            width: screenWidth * 0.7,
            child: TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Color(0xFFF6CBD1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                minimumSize: Size(screenWidth * 0.4, screenHeight * 0.07),
              ),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => QuizScreen()));

              },
              child: Center(
                child: Text(
                  'NVCクイズ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: screenWidth * 0.1,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    height: 0,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: screenHeight*0.02,),
          //読んでみるボタン
          Container(
            width: screenWidth * 0.7,
            child: TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Color(0xFFC5D8E7),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                minimumSize: Size(screenWidth * 0.4, screenHeight * 0.07),
              ),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => Emotiondiary()));

              },
              child: Center(
                child: Text(
                  '感情にっき',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: screenWidth * 0.1,
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
    );
  }
}

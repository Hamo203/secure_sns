import 'dart:async';

import 'package:floating_bubbles/floating_bubbles.dart';
import 'package:flutter/material.dart';

class NvcFeedbackPage extends StatefulWidget {
  final String originalContent;
  const NvcFeedbackPage({
    required this.originalContent,
    Key? key,
  }):super(key: key);

  @override
  State<NvcFeedbackPage> createState() => _NvcFeedbackPageState();
}

class _NvcFeedbackPageState extends State<NvcFeedbackPage> {
  // 1 -> 大丈夫かな？　2-> 言い換え提示　3-> ありがとう!
  int _currentStep = 1;
  late String _revisedContent;
  Timer? _timer;


  void initState(){
    super.initState();
    _revisedContent=widget.originalContent;
    if (_currentStep == 1) {
      _startTimer(); // 最初のステップでタイマーを開始
    }
  }

  void _startTimer() {
    _timer = Timer(Duration(seconds: 5), () {
      if (mounted && _currentStep == 1) {
        _nextStep();
      }
    });
  }

  void _nextStep() {
    setState(() {
      //次のページへ
      _currentStep++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:Padding(
        padding: const EdgeInsets.all(16.0),
        child: _buildStepContent(),
      )
    );
  }

  Widget _buildStepContent(){
    switch (_currentStep){
      case 1:
        return _buildFirstStep();
      case 2:
        return _buildSecondStep();
      case 3:
        return _buildThirdStep();

      default:
        return Container();

    }
  }

  Widget _buildFirstStep() {
    Size screenSize = MediaQuery.of(context).size;
    return Stack(
      children: [
        // 背景色を設定するコンテナ
        Positioned.fill(
          child: Container(
            color: Colors.white, // 必要に応じて色を変更してください
          ),
        ),
        // 浮かぶバブルを表示
        Positioned.fill(
          child: FloatingBubbles.alwaysRepeating(
            noOfBubbles: 25,
            colorsOfBubbles: [
              //背景の色
              Colors.blueAccent.withAlpha(30),
            ],
            sizeFactor: 0.16,
            opacity: 30,
            paintingStyle: PaintingStyle.fill,
            shape: BubbleShape.circle, //bubbleの形
            speed: BubbleSpeed.normal,
          ),
        ),
        // 既存のコンテンツを表示
        Center(
          child: Container(
            padding: EdgeInsets.all(screenSize.width * 0.2),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'images/face/cry.png',
                  width: screenSize.width * 0.6,
                  height: screenSize.width * 0.6,
                ),
                SizedBox(height: 40),
                Text(
                  "そのことば\n大丈夫かな？",
                  style: TextStyle(fontSize: 24),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSecondStep() {
    final suggestions = [
      'もう少し優しい表現にしてみましょう。',
      '別の言い方を考えてみてください。',
      'その言葉を使わずに伝えてみましょう。',
      '他人の気持ちを考えてみましょう。',
      'ポジティブな表現に変えてみましょう。',
    ];
    Size screenSize = MediaQuery.sizeOf(context);
    return Center(
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'images/face/cry.png',
              width: screenSize.width * 0.4,
              height: screenSize.width * 0.4,
            ),
            SizedBox(height: 20),
            Text(
              "非常に攻撃的です!\n相手を傷つけてしまうかも?",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 15),
            Text(
              "言い換えてみませんか？",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 15),
            Container(
              height: screenSize.height * 0.2,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: <Widget>[
                  Container(
                    width: screenSize.width * 0.8,
                    margin: EdgeInsets.symmetric(horizontal: 8.0),
                    color: Colors.grey.shade200,
                    child: Center(child: Text(suggestions[0])),
                  ),
                  Container(
                    width: screenSize.width * 0.8,
                    margin: EdgeInsets.symmetric(horizontal: 8.0),
                    color: Colors.grey.shade300,
                    child: Center(child: Text(suggestions[1])),
                  ),
                  Container(
                    width: screenSize.width * 0.8,
                    margin: EdgeInsets.symmetric(horizontal: 8.0),
                    color: Colors.grey.shade400,
                    child: Center(child: Text(suggestions[2])),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _nextStep();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink.shade100,
              ),
              child: Text('送信'),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildThirdStep() {
    Size screenSize = MediaQuery.of(context).size;
    return Stack(
      children: [
        // 背景色を設定するコンテナ
        Positioned.fill(
          child: Container(
            color: Colors.white, // 必要に応じて色を変更してください
          ),
        ),
        // 浮かぶバブルを表示
        Positioned.fill(
          child: FloatingBubbles.alwaysRepeating(
            noOfBubbles: 25,
            colorsOfBubbles: [
              //背景の色
              Colors.red.withAlpha(30),
            ],
            sizeFactor: 0.16,
            opacity: 30,
            paintingStyle: PaintingStyle.fill,
            shape: BubbleShape.circle, //bubbleの形
            speed: BubbleSpeed.normal,
          ),
        ),
        // 既存のコンテンツを表示
        Center(
          child: Container(
            padding: EdgeInsets.all(screenSize.width * 0.2),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'images/face/kirakira.png',
                  width: screenSize.width * 0.6,
                  height: screenSize.width * 0.6,
                ),
                SizedBox(height: 40),
                Text(
                  "考えてくれて\nありがとう！",
                  style: TextStyle(fontSize: 24),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

}

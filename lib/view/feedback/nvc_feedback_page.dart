import 'dart:async';

import 'package:floating_bubbles/floating_bubbles.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

import '../../api/gemma_api.dart';

class NvcFeedbackPage extends StatefulWidget {
  //ユーザが最初に入力したことば
  final String originalContent;
  final double nonOffensivePercentage;
  final double offensivePercentage;
  final double grayZonePercentage;

  const NvcFeedbackPage({
    required this.originalContent,
    required this.nonOffensivePercentage,
    required this.offensivePercentage,
    required this.grayZonePercentage,
    Key? key,
  }):super(key: key);

  @override
  State<NvcFeedbackPage> createState() => _NvcFeedbackPageState();
}

class _NvcFeedbackPageState extends State<NvcFeedbackPage> {
  // 1 -> 大丈夫かな？　2-> 言い換え提示　3-> ありがとう!
  int _currentStep = 1;

  List<String> suggestions = ["サーバーからの応答を取得しています..."];
  final GemmaApi gemmaApi = GemmaApi();

  String? _selectedSuggestion;
  double badscore=0;

  void initState(){
    super.initState();
    _fetchSuggestions();
  }

  Future<void> _fetchSuggestions() async {
    try {
      final responses = await gemmaApi.sendText(widget.originalContent);

      // 不要な番号や記号を削除
      final cleanedResponses = responses.map((response) {
        return response.replaceAll(RegExp(r'^\d+\.\s*'), '')
            .replaceAll(RegExp(r'[「」]'), '').trim(); // "1. "の形式を削除
      }).toList();

      setState(() {
        suggestions = cleanedResponses;
        suggestions.add(widget.originalContent);
        _currentStep = 2;
      });
    } catch (error) {
      setState(() {
        suggestions = ['エラー: サーバーからの応答を取得できませんでした'];
        _currentStep = 2;
      });
    }
  }

  void _proceedToThankYou() {
    setState(() {
      _currentStep = 3; // ありがとうステップへ移行
    });

    // 5秒後に自動的に前の画面に戻り、結果を返す
    Timer(Duration(seconds: 5), () {
      Navigator.pop(context, {
        'isConfirmed': _selectedSuggestion != null,
        'rewrittenContent': _selectedSuggestion, // 選択された提案文
      });
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
    String text="そのことば\n大丈夫かな？";
    if(widget.grayZonePercentage>55) text ="ちょっと言い方\nかえてみない？";
    //攻撃的割合が大きいとき
    if(widget.offensivePercentage>widget.grayZonePercentage)
      badscore=(widget.grayZonePercentage*0.1+widget.offensivePercentage*0.7);

    //グレーゾーンの割合が大きいとき
    else if(widget.offensivePercentage<widget.grayZonePercentage)
      badscore=(widget.grayZonePercentage*0.5+widget.offensivePercentage*0.1);


    return Stack(
      children: [
        // 背景色を設定するコンテナ
        Positioned.fill(
          child: Container(
            color: Colors.white, // 必要に応じて色を変更
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
        // コンテンツ
        SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: screenSize.height, // 画面全体を確保
            ),
            child: IntrinsicHeight(
              child: Center(
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
                      //注意喚起用テキスト
                      text,
                      style: TextStyle(fontSize: 24),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 40),
                    Text(
                      "こうげきてき スコア",
                      style: TextStyle(fontSize: 24),
                      textAlign: TextAlign.center,
                    ),
                    SfLinearGauge(
                      minimum: 0,
                      maximum: 100,
                      orientation: LinearGaugeOrientation.horizontal,
                      barPointers: [LinearBarPointer(value: badscore)],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSecondStep() {
    Size screenSize = MediaQuery.sizeOf(context);

    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: screenSize.height, // 画面全体を確保
        ),
        child: IntrinsicHeight(
          child: Center(
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
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: suggestions.length,
                    itemBuilder: (context, index) {
                      final suggestion = suggestions[index];
                      final isSelected = suggestion == _selectedSuggestion;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedSuggestion = suggestion;
                          });
                        },
                        child: Container(
                          width: screenSize.width * 0.8,
                          margin: EdgeInsets.symmetric(horizontal: 8.0),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            border: Border.all(
                              color: isSelected ? Color(0xFFA5BACF) : Colors.transparent,
                              width: isSelected ? 2.0 : 1.0, // 選択時に枠線を太くする
                            ),
                            borderRadius: BorderRadius.circular(8.0), // 角を丸める（オプション）
                          ),
                          child: Center(
                            child: Text(
                              suggestion,
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                color: isSelected ? Colors.blue : Colors.black,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _selectedSuggestion != null ? _proceedToThankYou : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink.shade100,
                  ),
                  child: Text('送信'),
                ),
              ],
            ),
          ),
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

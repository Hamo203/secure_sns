// lib/services/offensive_classifier.dart

import 'package:flutter/material.dart';
import '../api/api_service.dart';

class OffensiveClassifier {
  final ApiService apiService;
  final BuildContext context;

  OffensiveClassifier({required this.apiService, required this.context});

  // '%' を除去してから double に変換するヘルパーメソッド
  double _parsePercentage(String? value) {
    if (value == null) return 0.0;
    String sanitized = value.replaceAll('%', '').trim();
    return double.tryParse(sanitized) ?? 0.0;
  }

  // 投稿内容を分析するメソッド
  Future<bool> analyzeText(String message, Function(String) updateResult) async {
    if (message.isEmpty) {
      updateResult('テキストを入力してください');
      return false;
    }

    try {
      // テキストを分類
      Map<String, String> analysisResult = await apiService.classifyText(message);

      // '%' を除去してから double に変換
      double offensivePercentage = _parsePercentage(analysisResult['offensive']);
      double grayZonePercentage = _parsePercentage(analysisResult['gray_zone']);

      // 結果を更新
      updateResult('''
        攻撃的でない発言: ${analysisResult['non_offensive']}%
        グレーゾーンの発言: ${grayZonePercentage}%
        攻撃的な発言: ${offensivePercentage}%
        ''');

      print("結果: $analysisResult"); // デバッグ用

      // 攻撃的な発言が55%以上、またはグレーゾーンの発言が55%以上の場合
      if (offensivePercentage > 55 || grayZonePercentage > 55) {
        bool userConfirmed = await _showAlertDialog(offensivePercentage, grayZonePercentage);
        return userConfirmed;
      } else {
        // 問題なければtrue
        return true;
      }
    } catch (e) {
      print('テキスト分類中にエラーが発生しました: $e');
      updateResult('エラーが発生しました: $e');
      return false;
    }
  }

  // 分析結果が問題な場合にダイアログを表示
  Future<bool> _showAlertDialog(double offensive, double grayZone) {
    print("攻撃的: $offensive, グレーゾーン: $grayZone");
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min, // コンテンツに合わせて高さを調整
              children: [
                // コンテンツ部分
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16.0),
                  decoration: const BoxDecoration(
                    color: Color(0xFFf7f7f7),
                    border: Border(
                      bottom: BorderSide(
                        width: 0.5,
                        color: Color.fromRGBO(0, 0, 0, 0.4),
                      ),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text("本当に送信しても大丈夫ですか？"),
                      const SizedBox(height: 16.0),
                      Image.asset(
                        'images/face/bully.png',
                        width: 150,
                        height: 150,
                      ),
                      const SizedBox(height: 16.0),
                      Text(
                        '攻撃的: ${offensive.toStringAsFixed(2)}%\nグレーゾーン: ${grayZone.toStringAsFixed(2)}%',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                // ボタン部分
                Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFf7f7f7),
                  ),
                  width: double.infinity,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // キャンセルボタン
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(false);
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.black,
                            backgroundColor: const Color(0xFFf9e4c8),
                          ),
                          child: const Text("キャンセル"),
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: Colors.grey,
                      ),
                      // 送信ボタン
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(true);
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.black,
                            backgroundColor: const Color(0xFFc5d8e7),
                          ),
                          child: const Text("送信"),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ).then((value) => value ?? false);
  }
}

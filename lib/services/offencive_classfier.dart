// lib/services/offensive_classifier.dart

import 'package:flutter/material.dart';
import '../api/api_service.dart';
import '../view/feedback/nvc_feedback_page.dart';

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
        bool userConfirmed = await _showNVCFeedBack(offensivePercentage, grayZonePercentage, message);
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

  Future<bool> _showNVCFeedBack(double offensive, double grayZone, String originalContent) async {
    print("攻撃的: $offensive, グレーゾーン: $grayZone");
    final bool? result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NvcFeedbackPage(originalContent: originalContent),
      ),
    );

    if (result != null && result) {
      // ユーザーが変更を確認した場合
      return true;
    } else {
      // ユーザーがキャンセルした場合
      return false;
    }

  }
}

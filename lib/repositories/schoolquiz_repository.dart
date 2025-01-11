// repositories/schoolquiz_repository.dart
import 'dart:convert';
import 'package:flutter/services.dart';

import '../model/quiz.dart';

class SchoolquizRepository {
  // quizzes.json からデータを読み込み、Quizリストを返す
  Future<List<Quiz>> fetchQuizzes() async {
    // assets/quizzes.json を文字列として読み込み
    final jsonString = await rootBundle.loadString('assets/quizzes/nvc_school.json');

    // 文字列を JSON (Map) に変換
    final Map<String, dynamic> jsonMap = json.decode(jsonString);

    // "quizzes"キーの配列を取り出し、Quizのリストに変換
    final List<dynamic> quizzesJson = jsonMap['quizzes'];
    final quizzes = quizzesJson.map((q) => Quiz.fromJson(q)).toList();

    // List<Quiz> を返す
    return quizzes;
  }
}


class Quiz {
  final int id;
  final String scenario;
  final String question;
  final List<QuizOption> options;
  final String explanation;

  // 画面上で使うロックフラグや選択されたOptionを持たせる場合
  bool isLocked;
  QuizOption? selectedOption;

  Quiz({
    required this.id,
    required this.scenario,
    required this.question,
    required this.options,
    required this.explanation,
    this.isLocked = false,
    this.selectedOption,
  });

  // JSON から Quiz インスタンスを生成するためのファクトリコンストラクタ
  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      id: json['id'],
      scenario: json['scenario'],
      question: json['question'],
      explanation: json['explanation'],
      options: (json['options'] as List<dynamic>)
          .map((optionJson) => QuizOption.fromJson(optionJson))
          .toList(),
    );
  }
}

class QuizOption {
  final String id;       // A, B, C ...
  final String text;     // "楽しい", "悲しい" ...
  final bool isCorrect;  // true or false

  const QuizOption({
    required this.id,
    required this.text,
    required this.isCorrect,
  });

  factory QuizOption.fromJson(Map<String, dynamic> json) {
    return QuizOption(
      id: json['id'],
      text: json['text'],
      isCorrect: json['isCorrect'],
    );
  }
}

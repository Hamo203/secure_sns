class Quiz {
  final int id;
  final String scenario;
  final String question;
  final List<QuizOption> options;
  final String? explanation;
  bool isLocked;
  QuizOption? selectedOption;

  Quiz({
    required this.id,
    required this.scenario,
    required this.question,
    required this.options,
    this.explanation,
    this.isLocked = false,
    this.selectedOption,
  });

  factory Quiz.fromJson(Map<String, dynamic> json) {
    var optionsJson = json['options'] as List<dynamic>? ?? []; // 存在しない場合は空リスト
    List<QuizOption> options =
    optionsJson.map((o) => QuizOption.fromJson(o)).toList();

    return Quiz(
      id: json['id'] != null ? int.tryParse(json['id'].toString()) ?? 0 : 0,
      scenario: json['scenario']?.toString() ?? '',
      question: json['question']?.toString() ?? '',
      options: options,
      explanation: json['explanation']?.toString(),
    );
  }

  // isCorrect があったら多肢選択と見なす
  bool get isMultipleChoice {
    return options.any((option) => option.isCorrect != null);
  }
}

class QuizOption {
  final String id;
  final String text;
  final bool? isCorrect;
  final String? feedback;

  QuizOption({
    required this.id,
    required this.text,
    this.isCorrect,
    this.feedback,
  });

  factory QuizOption.fromJson(Map<String, dynamic> json) {
    return QuizOption(
      id: json['id']?.toString() ?? '',
      text: json['text']?.toString() ?? '',
      isCorrect: json['isCorrect'] as bool?,
      feedback: json['feedback']?.toString(),  // 存在しなければ null
    );
  }
}



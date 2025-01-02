class Question {
  final String text;
  final List<Option> options; //選択肢のリスト
  late bool isLocked;
  Option? selectedOption;

  Question({
    required this.text,
    required this.options,
    this.isLocked = false,
    this.selectedOption,
  });

}

class Option{
  //選択肢
  final String text;
  final bool isCorrect; //正誤
  const Option({
    required this.text,
    required this.isCorrect
  });
}

final questions=[
  Question(text: 'What is actually electricity?',
      options: [
        const Option(text: 'A flow of water', isCorrect: false),
        const Option(text: 'A flow of air', isCorrect: false),
        const Option(text: 'A flow of electrons', isCorrect: true),
        const Option(text: 'A flow of atom', isCorrect: false),
      ]
  ),
  Question(text: 'which of the foernational organisation?',
      options: [
        const Option(text: 'Fifa', isCorrect: false),
        const Option(text: 'nato', isCorrect: false),
        const Option(text: 'asean', isCorrect: false),
        const Option(text: 'akb', isCorrect: true),
      ]
  ),
];
import 'package:flutter/material.dart';
import 'package:secure_sns/repositories/textComquiz_repository.dart';
import 'package:secure_sns/repositories/feelquiz_repository.dart';
import 'package:secure_sns/repositories/schoolquiz_repository.dart';

import '../../model/quiz.dart';
// Quiz/QuizOptionモデル

class QuizScreen extends StatefulWidget {
  const QuizScreen({Key? key}) : super(key: key);

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  // 各カテゴリーのクイズリスト
  final _schoolquizRepository = SchoolquizRepository();
  List<Quiz> _schoolquizzes = [];

  final _textquizRepository = TextcomquizRepository();
  List<Quiz> _textquizzes = [];

  final _feelquizRepository = FeelquizRepository();
  List<Quiz> _feelquizzes = [];

  // 現在選択されている（＝アクティブな）クイズリスト
  List<Quiz> _activeQuizzes = [];

  // PageView用コントローラ
  late PageController _pageController;

  // 現在のページのインデックス（0が開始画面）
  int _currentPageIndex = 0;

  // スコア（正解数）
  int _score = 0;

  // 選択したらロック（Nextボタンを出す）
  bool _isLocked = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _loadQuizzes();
  }

  /// 各カテゴリーのクイズをすべて読み込む
  Future<void> _loadQuizzes() async {
    final schoolquizzes = await _schoolquizRepository.fetchQuizzes();
    final textquizzes = await _textquizRepository.fetchQuizzes();
    final feelquizzes = await _feelquizRepository.fetchQuizzes();
    setState(() {
      _schoolquizzes = schoolquizzes;
      _textquizzes = textquizzes;
      _feelquizzes = feelquizzes;
      // 初期状態ではまだカテゴリーを選択していないので、_activeQuizzesは空のまま
    });
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    // すべてのカテゴリーが読み込まれるまで待つ
    if (_schoolquizzes.isEmpty || _textquizzes.isEmpty || _feelquizzes.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          // 背景の青い丸（左上）
          Align(
            alignment: const Alignment(-1.5, -1.1),
            child: Container(
              width: screenWidth * 0.4,
              height: screenHeight * 0.2,
              decoration: const ShapeDecoration(
                color: Color(0xFFC5D8E7),
                shape: OvalBorder(),
              ),
            ),
          ),
          // 背景のオレンジの丸（右下）
          Align(
            alignment: const Alignment(1.5, 1.8),
            child: Container(
              width: screenWidth * 0.5,
              height: screenHeight * 0.3,
              decoration: const ShapeDecoration(
                color: Color(0xFFF9E4C8),
                shape: OvalBorder(),
              ),
            ),
          ),
          // 全体はStackで重ねつつ、PageViewなどを配置
          Column(
            children: [
              SizedBox(height: screenHeight * 0.1),
              // 現在のページ番号 / 全ページ数（開始画面以降のみ表示）
              _currentPageIndex == 0
                  ? const SizedBox.shrink()
                  : Text(
                'Question $_currentPageIndex/${_activeQuizzes.length}',
                style: const TextStyle(fontSize: 16),
              ),
              const Divider(thickness: 1, color: Colors.grey),
              Expanded(
                // PageView: 開始画面＋クイズ問題
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: (_activeQuizzes.isNotEmpty ? _activeQuizzes.length : 0) + 1,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (index) {
                    setState(() {
                      _currentPageIndex = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return _buildStartPage();
                    } else {
                      // _activeQuizzesがまだ設定されていれば表示
                      final quiz = _activeQuizzes[index - 1];
                      return _buildQuizPage(quiz);
                    }
                  },
                ),
              ),
              // ボタン表示（クイズページで解答済みならNextボタンを表示）
              _currentPageIndex != 0 && _isLocked
                  ? _buildNextButton()
                  : const SizedBox.shrink(),
              const SizedBox(height: 20),
            ],
          )
        ],
      ),
    );
  }

  /// 開始画面のUI（複数のカテゴリー選択ボタンを含む）
  Widget _buildStartPage() {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'NVCクイズへようこそ！',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          const Text(
            'ともだちとの\nコミュニケーション方法をまなぼう！',
            style: TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: screenHeight * 0.06),
          // 各カテゴリーに対応するスタートボタン
          Container(
            width: screenWidth * 0.7,
            height: screenHeight * 0.08,
            child: TextButton(
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFFF6CBD1),
              ),
              onPressed: () {
                // 「かんじょう」クイズを選択
                setState(() {
                  _activeQuizzes = _feelquizzes;
                });
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeIn,
                );
                setState(() {
                  _currentPageIndex = 1;
                });
              },
              child: Text(
                'かんじょうをせいりしよう！',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: screenWidth * 0.04),
              ),
            ),
          ),
          SizedBox(height: screenHeight * 0.04),
          Container(
            width: screenWidth * 0.7,
            height: screenHeight * 0.08,
            child: TextButton(
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFFF9E4C8),
              ),
              onPressed: () {
                // 「日常でのコミュニケーション」クイズを選択
                setState(() {
                  _activeQuizzes = _schoolquizzes;
                });
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeIn,
                );
                setState(() {
                  _currentPageIndex = 1;
                });
              },
              child: Text(
                '日常での\nコミュニケーションをまなぼう！',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: screenWidth * 0.04),
              ),
            ),
          ),
          SizedBox(height: screenHeight * 0.04),
          Container(
            width: screenWidth * 0.7,
            height: screenHeight * 0.08,
            child: TextButton(
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFFC5D8E7),
              ),
              onPressed: () {
                // 「テキストコミュニケーション」クイズを選択
                setState(() {
                  _activeQuizzes = _textquizzes;
                });
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeIn,
                );
                setState(() {
                  _currentPageIndex = 1;
                });
              },
              child: Text(
                'テキストコミュニケーションを\nまなぼう！',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: screenWidth * 0.04),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// クイズページのUIを構築
  Widget _buildQuizPage(Quiz quiz) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // シナリオ
            Text(
              quiz.scenario,
              style: const TextStyle(fontSize: 20, color: Colors.blueGrey),
            ),
            const SizedBox(height: 16),
            // 問題文
            Text(
              quiz.question,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            // 選択肢一覧
            Column(
              children: quiz.options.map((option) {
                final color = _getColorForOption(option, quiz);
                return GestureDetector(
                  onTap: () {
                    if (quiz.isLocked) return;
                    setState(() {
                      quiz.isLocked = true;
                      quiz.selectedOption = option;
                      _isLocked = true;
                      // 正解の場合スコアを加算（isCorrectがnullの場合はfalseとする）
                      if (option.isCorrect ?? false) {
                        _score++;
                      }
                    });
                  },
                  child: Container(
                    height: 50,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      border: Border.all(color: color),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(option.text, style: const TextStyle(fontSize: 20)),
                        _getIconForOption(option, quiz),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            // 回答がロックされたら解説を表示
            if (quiz.isLocked)
              Text(
                "解説: ${quiz.explanation}",
                style: const TextStyle(fontSize: 16, color: Colors.blueGrey),
              ),
          ],
        ),
      ),
    );
  }

  /// Next/ResultボタンのUIを構築
  Widget _buildNextButton() {
    // 最後の問題かどうか（現在のページが最後のクイズのページの場合）
    final isLastQuestion = (_currentPageIndex == _activeQuizzes.length);
    return ElevatedButton(
      onPressed: () {
        if (!isLastQuestion) {
          _pageController.nextPage(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeIn,
          );
          setState(() {
            _isLocked = false;
          });
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => ResultPage(score: _score, total: _activeQuizzes.length),
            ),
          );
        }
      },
      child: Text(isLastQuestion ? '結果を見る' : '次へ'),
    );
  }

  /// 選択肢の枠線色を返す（正解の場合は緑、不正解の場合は赤）
  Color _getColorForOption(QuizOption option, Quiz quiz) {
    if (!quiz.isLocked) return Colors.grey.shade300;
    if (option == quiz.selectedOption) {
      return (option.isCorrect ?? false) ? Colors.green : Colors.red;
    } else if (option.isCorrect ?? false) {
      return Colors.green;
    }
    return Colors.grey.shade300;
  }

  /// 選択肢の右側アイコンのUIを構築（正解の場合はチェック、誤答ならキャンセルアイコン）
  Widget _getIconForOption(QuizOption option, Quiz quiz) {
    if (!quiz.isLocked) return const SizedBox.shrink();
    if (option == quiz.selectedOption) {
      return (option.isCorrect ?? false)
          ? const Icon(Icons.check_circle, color: Colors.green)
          : const Icon(Icons.cancel, color: Colors.red);
    } else if (option.isCorrect ?? false) {
      return const Icon(Icons.check_circle, color: Colors.green);
    }
    return const SizedBox.shrink();
  }
}

/// 結果画面
class ResultPage extends StatelessWidget {
  final int score;
  final int total;
  const ResultPage({Key? key, required this.score, required this.total})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('結果'),
      ),
      body: Center(
        child: Text(
          'あなたのスコアは $score/$total です！',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../model/quiz.dart';
import '../../repositories/quiz_repository.dart';
// Quiz/QuizOptionモデル

class QuizScreen extends StatefulWidget {
  const QuizScreen({Key? key}) : super(key: key);

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  // Repository (JSON読み込み担当)
  final _quizRepository = QuizRepository();
  // 取得したクイズリスト
  List<Quiz> _quizzes = [];

  // PageView 用コントローラ
  late PageController _pageController;

  // 現在のページのインデックス（0が開始画面）
  int _currentPageIndex = 0;

  // スコア(正解数)
  int _score = 0;

  // 選択肢ロックフラグ（選択後に「Next」ボタンを出す）
  bool _isLocked = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _loadQuizzes();
  }

  /// JSONからクイズを読み込む
  Future<void> _loadQuizzes() async {
    final quizzes = await _quizRepository.fetchQuizzes();
    setState(() {
      _quizzes = quizzes;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 読み込み中はインジケータを表示
    if (_quizzes.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // 読み込み後のクイズ画面
    return Scaffold(
      appBar: AppBar(title: const Text('クイズ')),
      body: Column(
        children: [
          const SizedBox(height: 10),
          // 現在のページ番号 / 全ページ数
          _currentPageIndex == 0
              ? Text('Welcome to the Quiz!')
              : Text('Question $_currentPageIndex/${_quizzes.length}'),
          const Divider(thickness: 1, color: Colors.grey),
          Expanded(
            // PageViewで複数問題をページ切り替え
            child: PageView.builder(
              controller: _pageController,
              itemCount: _quizzes.length + 1, // 開始画面を追加
              physics: const NeverScrollableScrollPhysics(), // スワイプ操作禁止
              onPageChanged: (index) {
                setState(() {
                  _currentPageIndex = index;
                });
              },
              itemBuilder: (context, index) {
                if (index == 0) {
                  // 開始画面
                  return _buildStartPage();
                } else {
                  // クイズページ
                  final quiz = _quizzes[index - 1];
                  return _buildQuizPage(quiz);
                }
              },
            ),
          ),
          // 選択肢をロックしたら次ボタンを表示
          _currentPageIndex != 0 && _isLocked
              ? _buildNextButton()
              : (_currentPageIndex == 0
              ? _buildStartButton()
              : const SizedBox.shrink()),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  /// 開始画面のUIを構築
  Widget _buildStartPage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'クイズへようこそ！',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            const Text(
              '友達とのコミュニケーションを学ぶクイズです。スタートボタンを押して始めましょう！',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeIn,
                );
                setState(() {
                  _currentPageIndex = 1;
                });
              },
              child: const Text('スタート'),
            ),
          ],
        ),
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
            // シナリオ (例: 「画像(雨の中...)」などの説明文)
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
                    // 既にロック済みなら何もしない
                    if (quiz.isLocked) return;

                    setState(() {
                      quiz.isLocked = true;
                      quiz.selectedOption = option;
                      _isLocked = true; // 「Next」ボタンを出す

                      // 正解の場合スコアを加算
                      if (option.isCorrect) {
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
                        // 選択肢のテキスト
                        Text(option.text, style: const TextStyle(fontSize: 20)),
                        // ○×アイコン
                        _getIconForOption(option, quiz),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),
            // 回答がロックされたら解説を表示（任意）
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

  /// 開始画面の「スタート」ボタン
  Widget _buildStartButton() {
    return ElevatedButton(
      onPressed: () {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeIn,
        );
        setState(() {
          _currentPageIndex = 1;
        });
      },
      child: const Text('スタート'),
    );
  }

  /// Next/Resultボタン
  Widget _buildNextButton() {
    // 最後の問題かどうか
    final isLastQuestion = (_currentPageIndex == _quizzes.length);
    return ElevatedButton(
      onPressed: () {
        if (!isLastQuestion) {
          // 次の問題へ
          _pageController.nextPage(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeIn,
          );
          // 次のページに移動したらロック解除
          setState(() {
            _isLocked = false;
          });
        } else {
          // 最終問題のあとは結果ページへ
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => ResultPage(score: _score, total: _quizzes.length),
            ),
          );
        }
      },
      child: Text(isLastQuestion ? '結果を見る' : '次へ'),
    );
  }

  /// 選択肢の枠線色を返す
  Color _getColorForOption(QuizOption option, Quiz quiz) {
    // 未選択(ロック前) → グレー
    if (!quiz.isLocked) {
      return Colors.grey.shade300;
    }
    // 回答ロック後
    if (option == quiz.selectedOption) {
      // 選ばれた選択肢が正解か不正解か
      return option.isCorrect ? Colors.green : Colors.red;
    } else if (option.isCorrect) {
      // 正解の選択肢があれば緑表示
      return Colors.green;
    }
    return Colors.grey.shade300;
  }

  /// 選択肢の右側アイコン (正解:○, 不正解:×, 未選択:何もなし)
  Widget _getIconForOption(QuizOption option, Quiz quiz) {
    if (!quiz.isLocked) return const SizedBox.shrink();
    if (option == quiz.selectedOption) {
      return option.isCorrect
          ? const Icon(Icons.check_circle, color: Colors.green)
          : const Icon(Icons.cancel, color: Colors.red);
    } else if (option.isCorrect) {
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

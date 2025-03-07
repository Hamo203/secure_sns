import 'package:floating_bubbles/floating_bubbles.dart';
import 'package:flutter/material.dart';
import 'package:secure_sns/navigation.dart';
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

  int flag =0;

  bool _hasShownDialog = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _loadQuizzes();
  }

  //クイズよみこみ
  Future<void> _loadQuizzes() async {
    final schoolquizzes = await _schoolquizRepository.fetchQuizzes();
    final textquizzes = await _textquizRepository.fetchQuizzes();
    final feelquizzes = await _feelquizRepository.fetchQuizzes();
    setState(() {
      _schoolquizzes = schoolquizzes;
      _textquizzes = textquizzes;
      _feelquizzes = feelquizzes;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    // クイズが読み込まれるまで表示
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
                  itemCount:
                  (_activeQuizzes.isNotEmpty ? _activeQuizzes.length : 0) +
                      1, // 開始画面1ページ＋問題数
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
                      final quiz = _activeQuizzes[index - 1];
                      return _buildQuizPage(quiz);
                    }
                  },
                ),
              ),

            ],
          )
        ],
      ),
    );
  }

  // 開始画面のUI
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
          // ランダムに5問取得
          Container(
            width: screenWidth * 0.7,
            height: screenHeight * 0.08,
            child: TextButton(
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFFF6CBD1),
              ),
              onPressed: () {
                setState(() {
                  flag=1;
                  _activeQuizzes = List<Quiz>.from(_feelquizzes)
                    ..shuffle(); // リストをシャッフル
                  _activeQuizzes = _activeQuizzes.take(5).toList(); // 先頭5問を取得
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
                // ランダムに5問取得
                setState(() {
                  flag=2;
                  _activeQuizzes = List<Quiz>.from(_schoolquizzes)
                    ..shuffle();
                  _activeQuizzes = _activeQuizzes.take(5).toList();
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
                // ランダムに5問取得
                setState(() {
                  flag=3;
                  _activeQuizzes = List<Quiz>.from(_textquizzes)
                    ..shuffle();
                  _activeQuizzes = _activeQuizzes.take(5).toList();
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


  Widget _buildFeedbackDialog(Quiz quiz) {
    final isLastQuestion = (_currentPageIndex == _activeQuizzes.length);
    _hasShownDialog = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('フィードバック'),
            content: Text(
              quiz.isMultipleChoice
                  ? (quiz.explanation ?? '解説がありません')
                  : (quiz.selectedOption?.feedback ?? 'フィードバックがありません'),
              style: const TextStyle(fontSize: 16, color: Colors.blueGrey),
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  // まずダイアログを閉じる
                  Navigator.pop(context);

                  // 次のページへ
                  if (!isLastQuestion) {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeIn,
                    );
                    setState(() {
                      _isLocked = false;
                      _hasShownDialog = false;
                    });
                  } else {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ResultPage(
                            score: _score, total: _activeQuizzes.length, flag: flag),
                      ),
                    );
                  }
                },
                child: Text(isLastQuestion ? '結果を見る' : '次へ'),
              )
            ],
          );
        },
      );
    });
    // ダイアログは後から表示するので、build上は何も表示しない
    return const SizedBox.shrink();
  }


  // クイズページのUIを構築
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
                  onTap: () async {
                    // 既に回答済みなら何もしない
                    if (quiz.isLocked) return;

                    // 回答選択後の処理とロックをかける
                    setState(() {
                      quiz.isLocked = true;
                      quiz.selectedOption = option;
                      if (option.isCorrect ?? false) {
                        _score++;
                      }
                    });

                    // ダイアログは各クイズごとに一度だけ表示する
                    if (!quiz.hasShownDialog) {
                      quiz.hasShownDialog = true;
                      final isLastQuestion = (_currentPageIndex == _activeQuizzes.length);

                      // ダイアログを表示（await で閉じるまで待つ）
                      await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          String titleText;
                          if (quiz.selectedOption?.feedback != null) {
                            titleText = '${quiz.selectedOption!.text} なんだね！';
                          } else if (quiz.selectedOption?.isCorrect ?? false) {
                            titleText = 'せいかい!';
                          } else {
                            titleText = 'ざんねん!';
                          }
                          return AlertDialog(
                            title: Text(titleText),
                            content: Text(
                              quiz.isMultipleChoice
                                  ? (quiz.explanation ?? '解説がありません')
                                  : (quiz.selectedOption?.feedback ?? 'フィードバックがありません'),
                              style: const TextStyle(fontSize: 16, color: Colors.blueGrey),
                            ),
                            actions: [
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context); // ダイアログを閉じる
                                },
                                child: Text(isLastQuestion ? '結果を見る' : '次へ'),
                              )
                            ],
                          );
                        },
                      );

                      // ダイアログが閉じたら次の処理へ
                      if (!isLastQuestion) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeIn,
                        );
                        // 次の問題に移るので、その問題用のフラグは false のままになる
                        setState(() {
                          // ロック状態は各問題ごとに管理されるので、
                          // 次ページでは新たに isLocked=false の状態になります
                        });
                      } else {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ResultPage(
                                score: _score, total: _activeQuizzes.length, flag: flag),
                          ),
                        );
                      }
                    }
                  },
                  child: Container(
                    height: 90,
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
                        Expanded(
                          child: Text(option.text, style: const TextStyle(fontSize: 20)),
                        ),
                        _getIconForOption(option, quiz),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }


  //選択肢の枠線色を返す（正解の場合は緑、不正解の場合は赤）
  Color _getColorForOption(QuizOption option, Quiz quiz) {
    if (!quiz.isLocked) return Colors.grey.shade300;
    // もし isCorrect が null かつ feedback が存在する場合は、色は変更しない
    if ((option.isCorrect == null) && (option.feedback != null)) {
      return Colors.grey.shade300;
    }
    if (option == quiz.selectedOption) {
      return (option.isCorrect ?? false) ? Colors.green : Colors.red;
    } else if (option.isCorrect ?? false) {
      return Colors.green;
    }
    return Colors.grey.shade300;
  }

  // 正解の場合はチェック 誤答ならキャンセル
  Widget _getIconForOption(QuizOption option, Quiz quiz) {
    if (!quiz.isLocked) return const SizedBox.shrink();
    // isCorrect がnull かつ feedback が存在 => アイコンは表示しない
    if ((option.isCorrect == null) && (option.feedback != null)) {
      return const SizedBox.shrink();
    }
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

// 結果画面
class ResultPage extends StatelessWidget {
  final int score;
  final int total;
  final int flag;
  const ResultPage({
    Key? key,
    required this.score,
    required this.total,
    required this.flag,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    if (flag != 1) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('結果'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.star,
                color: Colors.amber,
                size: 80, // 星アイコンで成功感を演出
              ),
              SizedBox(height: 20),
              Text(
                '$total問中… $score問 正解！',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.pinkAccent, // 明るいピンク色
                  fontFamily: 'MochiyPopOne', // 可愛いフォント（追加する場合）
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => QuizScreen()),
                  );
                },
                child: const Text('最初に戻る'),
              )

            ],
          ),
        ),
      );
    } else {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
              Image.asset(
                'images/face/kirakira.png',
                width: screenSize.width * 0.6,
                height: screenSize.width * 0.6,
              ),
              const Text(
                'かんじょうを言葉であらわせたね！',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => QuizScreen()),
                  );
                },
                child: const Text('最初に戻る'),
              )
            ],
          ),
        ),
      );
    }
  }
}


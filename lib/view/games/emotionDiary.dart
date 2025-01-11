import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:floating_bubbles/floating_bubbles.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:secure_sns/view/games/readingDiary.dart';

import '../../model/diary.dart';
import '../../model/emotionItem.dart';
import '../../navigation.dart';
import '../../services/image_service.dart';
import '../account/user_auth.dart';
import '../components/emotionlists.dart';

class Emotiondiary extends StatefulWidget {
  const Emotiondiary({super.key});

  @override
  State<Emotiondiary> createState() => _EmotiondiaryState();
}

class _EmotiondiaryState extends State<Emotiondiary> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final Diary _diary = Diary(createdDate: DateTime.now(), diaryAccount: userAuth.currentUser!.uid);
  late ImageService imageService; // ImageServiceのインスタンス
  // 日付入力用のコントローラ
  final textEditingController = TextEditingController();
  File? _image;
  final ImagePicker picker = ImagePicker();

  // ステップ：0->スタート画面, 1->感情選択, 2->日記入力, 3->保存完了画面
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    imageService = ImageService();
    textEditingController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  // 写真を撮る
  Future<void> captureImage() async {
    File? photo = await imageService.captureImage();
    if (photo != null) {
      setState(() {
        _image = photo;
      });
    }
  }

  // ギャラリーから写真を選ぶ
  Future<void> getImageFromGallery() async {
    File? image = await imageService.getImageFromGallery();
    if (image != null) {
      setState(() {
        _image = image;
      });
    }
  }

  // uploadする
  Future<void> _upload(DocumentReference _mainReference) async {
    if (_image == null) {
      print("Error: Image is null");
      return;
    }
    try {
      FirebaseStorage storage = FirebaseStorage.instance;
      String imageUrl;

      TaskSnapshot snapshot = await storage
          .ref("users/${userAuth.currentUser!.uid}/diaries/${_mainReference.id}.png")
          .putFile(_image!);

      imageUrl = await snapshot.ref.getDownloadURL();
      _formKey.currentState!.save();

      await _mainReference.set({
        'diaryAccount': _diary.diaryAccount,
        'createdTime': _diary.createdDate,
        'place': _diary.place,
        'description': _diary.description,
        'emotionItem.dart': _diary.emotion, // キーは必要に応じて 'emotion' に統一してください
        'emotionreason': _diary.emotionreason,
        'favoriteCount': _diary.favoriteCount,
        'imagePath': imageUrl,
      });
      print("保存が完了した");
    } catch (e) {
      print('アップロード中にエラーが発生しました: $e');
    }
  }

  // 日付設定
  Future _getDate(BuildContext context) async {
    final initialDate = DateTime.now();
    final newDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(DateTime.now().year - 3),
      lastDate: DateTime(DateTime.now().year + 3),
    );
    if (newDate != null) {
      textEditingController.text = DateFormat('yyyy-MM-dd').format(newDate);
    } else {
      return;
    }
  }

  Widget _diaryStepContent() {
    switch (_currentStep) {
      case 0:
        return _diaryZeroStep();
      case 1:
        return _diaryFirstStep();
      case 2:
        return _diarySecondStep();
      case 3:
        return DiaryLastStep(
          onComplete: () {
            setState(() {
              _currentStep = 0; // 5秒後に最初のステップに戻る
            });
          },
        );
      default:
        return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            width: screenWidth,
            height: screenHeight,
            decoration: BoxDecoration(color: Colors.white),
            child: Stack(
              children: [
                // 青い丸 (左上)
                Align(
                  alignment: Alignment(-1.5, -1.1),
                  child: Container(
                    width: screenWidth * 0.4,
                    height: screenHeight * 0.2,
                    decoration: ShapeDecoration(
                      color: Color(0xFFC5D8E7),
                      shape: OvalBorder(),
                    ),
                  ),
                ),
                // オレンジの丸 (右下)
                Align(
                  alignment: Alignment(1.5, 1.8),
                  child: Container(
                    width: screenWidth * 0.5,
                    height: screenHeight * 0.3,
                    decoration: ShapeDecoration(
                      color: Color(0xFFF9E4C8),
                      shape: OvalBorder(),
                    ),
                  ),
                ),
                // 各ステップのコンテンツ
                _diaryStepContent(),
              ],
            ),
          ),
        ),
      );
  }

  Widget _diaryZeroStep() {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: screenHeight * 0.1),
          Text(
            'きょうのにっき',
            style: TextStyle(
              color: Colors.black,
              fontSize: screenWidth * 0.1,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w400,
              height: 1,
            ),
          ),
          SizedBox(
            width: screenWidth * 0.8,
            height: screenHeight * 0.45,
            child: Image.asset(
              'images/diaryimage.jpg',
              fit: BoxFit.contain,
            ),
          ),
          //書いてみるボタン
          Container(
            width: screenWidth * 0.7,
            child: TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Color(0xFFF6CBD1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                minimumSize: Size(screenWidth * 0.4, screenHeight * 0.07),
              ),
              onPressed: () {
                setState(() {
                  _currentStep++;
                });
              },
              child: Center(
                child: Text(
                  'かいてみる',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: screenWidth * 0.1,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    height: 0,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: screenHeight*0.02,),
          //読んでみるボタン
          Container(
            width: screenWidth * 0.7,
            child: TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Color(0xFFC5D8E7),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                minimumSize: Size(screenWidth * 0.4, screenHeight * 0.07),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Readingdiary(userid: userAuth.currentUser!.uid),
                  ),
                );
              },
              child: Center(
                child: Text(
                  'にっきをよむ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: screenWidth * 0.1,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    height: 0,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _diaryFirstStep() {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;


    return Column(
      children: [
        SizedBox(height: screenHeight * 0.03),
        Center(
          child: Text(
            "きょうは\nどんなきもちだったかな？",
            style: TextStyle(
              color: Colors.black87,
              fontSize: screenWidth * 0.07,
              fontFamily: 'Poppins',
            ),
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 8.0,
              crossAxisSpacing: 8.0,
              childAspectRatio: 0.9,
            ),
            itemCount: emotionItems.length,
            itemBuilder: (context, index) {
              final item = emotionItems[index];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _diary.emotion = item.name;
                    _currentStep++;
                  });
                },
                child: Card(
                  color: Colors.white,
                  elevation: 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Image.asset(
                          item.imagePath,
                          fit: BoxFit.contain,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Text(
                          item.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        ElevatedButton(
          onPressed: () {
            setState(() {
              if (_currentStep > 0) {
                _currentStep--;
              }
            });
          },
          child: Text("もどる"),
        )
      ],
    );
  }

  Widget _diarySecondStep() {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    DocumentReference _mainReference = FirebaseFirestore.instance
        .collection('users')
        .doc(userAuth.currentUser!.uid)
        .collection('diaries')
        .doc();

    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: screenHeight * 0.07),
          Center(
            child: Text(
              "きょうのにっき",
              style: TextStyle(
                color: Colors.black87,
                fontSize: screenWidth * 0.06,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: screenHeight * 0.01),
          Builder(
            builder: (context) {
              return Container(
                margin: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Text(
                        "きぶん: ${_diary.emotion}",
                        style: TextStyle(
                          fontSize: screenWidth * 0.05,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      TextFormField(
                        controller: textEditingController,
                        onTap: () {
                          _getDate(context);
                        },
                        decoration: InputDecoration(
                          icon: Icon(Icons.calendar_today),
                          hintText: "いつ?",
                          labelText: 'ひづけ *',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'ひづけを入力してください';
                          }
                          return null;
                        },
                        onSaved: (String? value) {
                          _diary.createdDate = DateTime.parse(value!);
                        },
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: "場所 *",
                          icon: Icon(Icons.place),
                          hintText: "どこで?",
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '場所を入力してください';
                          }
                          return null;
                        },
                        onSaved: (String? value) {
                          _diary.place = value!;
                        },
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: "やったこと *",
                          icon: Icon(Icons.sports_gymnastics_outlined),
                          hintText: "どんな事をしたの？",
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'やったことを入力してください';
                          }
                          return null;
                        },
                        onSaved: (String? value) {
                          _diary.description = value!;
                        },
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: "なんでその気持ちになったのかな?",
                          hintText: "例)友だちと遊べてたのしかった ...",
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '理由を入力してください';
                          }
                          return null;
                        },
                        onSaved: (String? value) {
                          _diary.emotionreason = value!;
                        },
                      ),
                      SizedBox(height: 24.0),
                      _image == null
                          ? Text('')
                          : Container(
                        width: MediaQuery.of(context).size.width * 0.6,
                        child: Image.file(
                          _image!,
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: captureImage,
                            child: Icon(Icons.add_a_photo),
                          ),
                          SizedBox(width: 20),
                          ElevatedButton(
                            onPressed: getImageFromGallery,
                            child: Icon(Icons.photo_library),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      ElevatedButton.icon(
                        icon: const Icon(
                          Icons.tag_faces,
                          color: Colors.white,
                        ),
                        label: const Text('日記をほぞんする'),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Color(0xFFF33550),
                          backgroundColor: Colors.grey[300],
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.05,
                            vertical: screenHeight * 0.02,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        onPressed: () async {
                          print("保存ボタンを押した");
                          try {
                            if (_formKey.currentState!.validate()) {
                              _formKey.currentState!.save();
                              if (_image != null) {
                                await _upload(_mainReference);
                              } else {
                                await _mainReference.set({
                                  'diaryAccount': _diary.diaryAccount,
                                  'createdTime': _diary.createdDate,
                                  'place': _diary.place,
                                  'description': _diary.description,
                                  'emotion': _diary.emotion,
                                  'emotionreason': _diary.emotionreason,
                                  'favoriteCount': _diary.favoriteCount,
                                  'imagePath': 'imageurl',
                                });
                              }
                              setState(() {
                                _currentStep++; // ステップ3（保存完了）へ
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('日記が正常に保存されました！')),
                              );
                            }
                          } catch (e) {
                            print('保存に失敗しました: $e');
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('保存に失敗しました: $e')),
                            );
                          }
                        },
                      ),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            if (_currentStep > 0) {
                              _currentStep--;
                            }
                          });
                        },
                        child: Text("もどる"),
                      )
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class DiaryLastStep extends StatefulWidget {
  final VoidCallback onComplete;

  const DiaryLastStep({Key? key, required this.onComplete}) : super(key: key);

  @override
  _DiaryLastStepState createState() => _DiaryLastStepState();
}

class _DiaryLastStepState extends State<DiaryLastStep> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    //5s後に画面遷移
    _timer = Timer(Duration(seconds: 5), () {
      widget.onComplete();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return SingleChildScrollView(
      child: Stack(
        children: [
          // 浮かぶバブル
          Positioned.fill(
            child: FloatingBubbles.alwaysRepeating(
              noOfBubbles: 25,
              colorsOfBubbles: [
                Colors.red.withAlpha(30), // 背景の色
              ],
              sizeFactor: 0.16,
              opacity: 30,
              paintingStyle: PaintingStyle.fill,
              shape: BubbleShape.circle,
              speed: BubbleSpeed.normal,
            ),
          ),
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
                  SizedBox(height: screenSize.width * 0.06),
                  Container(
                    width: screenSize.width * 0.8, // Textの幅を80%に指定
                    child: Text(
                      "日記をほぞん\nできたよ！\n\nすてきな１日をおしえてくれてありがとう！",
                      style: TextStyle(fontSize: 24),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

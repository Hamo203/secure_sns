import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../model/diary.dart';
import '../../navigation.dart';
import '../../services/image_service.dart';
import '../account/user_auth.dart';

class Emotiondiary extends StatefulWidget {
  const Emotiondiary({super.key});

  @override
  State<Emotiondiary> createState() => _EmotiondiaryState();
}

class _EmotiondiaryState extends State<Emotiondiary> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final Diary _diary = Diary(createdDate: DateTime.now(),diaryAccount: userAuth.currentUser!.uid);
  late ImageService imageService; // ImageServiceのインスタンスを追加
  //日付入力用のコントローラ
  final textEditingController = TextEditingController();


  File? _image ;
  final ImagePicker picker = ImagePicker();
  String _result = '';

  @override
  void initState() {
    super.initState();
    imageService = ImageService(); // ImageServiceを初期化
    textEditingController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());//日付
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

  //uploadする
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
        'emotion':_diary.emotion,
        'emotionreason':_diary.emotionreason,

        'favoriteCount': _diary.favoriteCount,
        'imagePath': imageUrl,

      });
      print("保存が完了した");
    } catch (e) {
      print('アップロード中にエラーが発生しました: $e');
    }
  }

  //日付設定
  Future _getDate(BuildContext context) async {
    final initialDate = DateTime.now();

    final newDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(DateTime.now().year - 3),
      lastDate: DateTime(DateTime.now().year + 3),
    );

    if (newDate != null) {
    //選択した日付をTextFormFieldに設定
    textEditingController.text =  DateFormat('yyyy-MM-dd').format(newDate);
    } else {
    return;
    }
  }

  final List<Map<String, String>> emotions = [
    {"emoji": "😊", "label": "しあわせ"},
    {"emoji": "😢", "label": "悲しい"},
    {"emoji": "😡", "label": "怒ってる"},
    {"emoji": "😱", "label": "驚いた"},
    {"emoji": "😴", "label": "疲れた"},
  ];


  @override
  Widget build(BuildContext context) {
    DocumentReference _mainReference = FirebaseFirestore.instance
        .collection('users').doc(userAuth.currentUser!.uid)
        .collection('diaries')
        .doc();
    return Scaffold(
      appBar: AppBar(
        title:Text("今日の日記"),
        actions: <Widget>[
          IconButton(
            //snsにシェア用
              icon: Icon(Icons.send),
              onPressed: () async {
                print("保存ボタンを押した");
                try {
                  // フォームが有効か確認
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();

                    // 画像がある場合は画像をアップロードしてからデータを保存
                    if (_image != null) {
                      await _upload(_mainReference);  // 非同期でアップロードを待つ
                    } else {
                      // 画像がない場合はimagePathをデフォルト値で保存
                      await _mainReference.set({
                        'diaryAccount': _diary.diaryAccount,
                        'createdTime': _diary.createdDate,
                        'place': _diary.place,
                        'description': _diary.description,
                        'emotion':_diary.emotion,
                        'emotionreason':_diary.emotionreason,

                        'favoriteCount': _diary.favoriteCount,
                        'imagePath': 'imageurl',  // デフォルトのURL　-> imageurl
                      });
                    }

                    // 処理が完了したら画面遷移
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => Navigation()),(_) => false,
                    );
                  }
                } catch (e) {
                  print('保存に失敗しました: $e');
                }
              }
          ),
          IconButton(
            //日記投稿用
            icon: Icon(Icons.share),
            onPressed: (){
              print("日記を投稿しました!");
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 20,vertical: 5),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                //入力欄
                TextFormField(
                  controller: textEditingController,
                  onTap: () {
                    _getDate(context);
                  },
                  decoration: InputDecoration(
                    icon:Icon(Icons.calendar_today),
                    hintText:"いつ?",
                    labelText: '日付 *',
                  ),
                  onSaved: (String? value) {
                    _diary.createdDate = DateTime.parse(value!);
                  }
                ),
                SizedBox(height: 20,),

                // 場所の入力
                TextFormField(
                  decoration: InputDecoration(
                    labelText: "場所 *",
                    icon:Icon(Icons.place),
                    hintText:"どこで?",
                  ),
                  onSaved: (String? value) {
                    _diary.place = value!  ;
                  },
                ),
                SizedBox(height: 20,),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: "やったこと *",
                    icon:Icon(Icons.sports_gymnastics_outlined),
                    hintText:"どんな事をしたの？",
                  ),
                  onSaved: (String? value) {
                    _diary.description = value!  ;
                  },
                ),
                SizedBox(height: 20,),

                Text("どんな気持ちになった？", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                SizedBox(height: 8.0),
                Wrap(
                  spacing: 5.0,// ボタン間のスペース
                  children: emotions.map((emotion) {
                    // emotionsリストを1つずつ処理
                    return ChoiceChip(
                      label: Text(emotion["emoji"]! + " " + emotion["label"]!), // 絵文字とラベルを表示
                      selected: _diary.emotion == emotion["label"], // 現在選択されている感情か確認
                      onSelected: (bool selected) {
                        setState(() {
                          _diary.emotion = (selected ? emotion["label"] : null)!; // 選択状態を更新
                        });
                      },
                    );
                  }).toList(),
                ),
                SizedBox(height: 16.0),
                // 詳細の入力
                TextFormField(
                  decoration: InputDecoration(
                    labelText: "なんでその気持ちになったのかな?",
                    border: OutlineInputBorder(),
                  ),
                  onSaved: (String? value) {
                    _diary.emotionreason = value!  ;
                  },

                ),
                SizedBox(height: 24.0),

                _image==null
                    ? Text('')
                    :Container(
                  width: MediaQuery.of(context).size.width * 0.6, // 画面の60%の幅に設定
                  child: Image.file(
                    _image!,
                    fit: BoxFit.cover, // 画像のサイズを調整
                  ),
                ),
                SizedBox(height: 20,),
                //写真取る・選択する
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: captureImage,
                      child: Icon(Icons.add_a_photo),
                    ),
                    ElevatedButton(
                      onPressed: getImageFromGallery,
                      child: Icon(Icons.photo_library),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

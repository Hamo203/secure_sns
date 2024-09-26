import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../api/natural_language_service.dart';
import '../../model/post.dart';
import '../../navigation.dart';
import '../account/user_auth.dart';

class Postpage extends StatefulWidget {
  const Postpage({super.key});

  @override
  State<Postpage> createState() => _PostpageState();
}

class _PostpageState extends State<Postpage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final Post _post = Post(createdTime: DateTime.now(),postAccount: userAuth.currentUser!.uid);

  File? _image ;
  final ImagePicker picker = ImagePicker();
  String _result = '';

  Future captureImage() async {
    // Capture a photo.
    final XFile? photo = await picker.pickImage(source: ImageSource.camera);
    if (photo == null) {
      print('No image selected');
      return;
    }
    setState(() {
      _image = File(photo.path);
    });
  }

  Future getImageFromGallery() async{
    // Pick an image.
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) {
      print('No image selected');
      return;
    }

    setState(() {
      _image = File(image.path);
    });
  }

  Future<void> _upload(DocumentReference _mainReference) async {
    if (_image == null) {
      print("Error: Image is null");
      return;
    }
    try {
      FirebaseStorage storage = FirebaseStorage.instance;
      String imageUrl;

      TaskSnapshot snapshot = await storage
          .ref("users/${userAuth.currentUser!.uid}/posts/${_mainReference.id}.png")
          .putFile(_image!);

      imageUrl = await snapshot.ref.getDownloadURL();
      _formKey.currentState!.save();

      await _mainReference.set({
        'createdTime': _post.createdTime,
        'description': _post.description,
        'favoriteCount': _post.favoriteCount,
        'imagePath': imageUrl,
        'postAccount': _post.postAccount,
        'retweetCount': _post.retweetCount,
      });
      print("保存が完了した");
    } catch (e) {
      print('アップロード中にエラーが発生しました: $e');
    }
  }

  Future<bool> _analyzeText(String message) async {
    double score=1;
    double magnitude=1;
    bool result;

    // テキストが入力されていないとき
    if (message.isEmpty) {
      setState(() {
        _result = 'Please enter some text';
      });
      return false;
    }

    // Natural Language APIを呼び出して解析
    final analysisResult = await NaturalLanguageService().analyzeSentiment(message);
    if(analysisResult!=null){
      setState(() {
        score = analysisResult['score']!;
        magnitude = analysisResult['magnitude']!;
        _result='Score: $score, Magnitude: $magnitude';
      });
    }

    print("result: $_result");

    if(score<1 && magnitude < 1){
      return await _showAlertDialog(score, magnitude);
    }else{
      //点が高かったらtrue
      return true;
    }

  }

  Future<bool> _showAlertDialog(double score, double magnitude) {
    print("score:$score, magnitude:$magnitude");
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min, // 高さをコンテンツに合わせる
              children: [
                // コンテンツ部分
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16.0),
                  decoration: const BoxDecoration(
                    color: Color(0xFFf7f7f7),
                    border: Border(
                      bottom: BorderSide(
                        width: 0.5,
                        color: Color.fromRGBO(0, 0, 0, 0.4),
                      ),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text("本当に送ってもだいじょうぶですか？"),
                      const SizedBox(height: 16.0),
                      Image.asset(
                        'images/face/bully.png',
                        width: 150,
                        height: 150,
                      ),
                    ],
                  ),
                ),
                // ボタン部分
                Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFf7f7f7),
                  ),
                  width: double.infinity,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      //キャンセルボタン
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(false);
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.black, backgroundColor: Color(0xFFf9e4c8),
                          ),
                          child: const Text("キャンセル"),
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: Colors.grey,
                      ),
                      //送信ボタン
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(true);
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.black, backgroundColor: Color(0xFFc5d8e7),
                          ),
                          child: const Text("送信"),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ).then((value) => value ?? false);
  }

  @override
  Widget build(BuildContext context) {
    DocumentReference _mainReference = FirebaseFirestore.instance
        .collection('users').doc(userAuth.currentUser!.uid)
        .collection('posts')
        .doc();

    return Scaffold(
      appBar: AppBar(
        title: Text("新規投稿"),
        actions: <Widget>[
          IconButton(
            //snsにシェア用
            icon: Icon(Icons.save),
              onPressed: () async {
                print("保存ボタンを押した");
                try {
                  // フォームが有効か確認
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();

                    bool analysisPassed = await _analyzeText(_post.description);

                    if (!analysisPassed) {
                      print("analysis doesn't passed");
                      return;
                    }

                    // 画像がある場合は画像をアップロードしてからデータを保存
                    if (_image != null) {
                      await _upload(_mainReference);  // 非同期でアップロードを待つ
                    } else {
                      // 画像がない場合はimagePathをデフォルト値で保存
                      await _mainReference.set({
                        'createdTime': _post.createdTime,
                        'description': _post.description,
                        'favoriteCount': _post.favoriteCount,
                        'imagePath': 'imageurl',  // デフォルトのURL　-> imageurl
                        'postAccount': _post.postAccount,
                        'retweetCount': _post.retweetCount,
                      });
                    }

                    // 処理が完了したら画面遷移
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => Navigation()),
                          (_) => false,
                    );
                  }
                } catch (e) {
                  print('保存に失敗しました: $e');
                }
              }
          ),
          IconButton(
            //snsにシェア用
            icon: Icon(Icons.share),
              onPressed: (){
                print("シェアボタンを押しました。");
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
                TextFormField(
                  decoration: InputDecoration(
                    hintText: '入力して'
                  ),
                  onSaved: (String? value) {
                    _post.description = value!;
                  },
                  initialValue: _post.description,
                ),
                SizedBox(height: 20,),
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


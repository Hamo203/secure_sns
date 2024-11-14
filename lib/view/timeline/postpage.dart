import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';

import '../../api/api_service.dart';
import '../../api/natural_language_service.dart';
import '../../model/post.dart';
import '../../navigation.dart';
import '../../services/image_service.dart';
import '../../services/offencive_classfier.dart';
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

  //攻撃性判定用
  late ApiService apiService;
  late OffensiveClassifier offensiveClassifier;
  late ImageService imageService; // ImageServiceのインスタンスを追加


  @override
  void initState() {
    super.initState();
    apiService = ApiService(baseUrl: dotenv.env['BASE_URL']!);
    imageService = ImageService(); // ImageServiceを初期化
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    //OffensiveClassifier のインスタンス化
    offensiveClassifier = OffensiveClassifier(apiService: apiService, context: context);
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
    return await offensiveClassifier.analyzeText(message, (result) {
      setState(() {
        _result = result;
      });
    });
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
                //入力欄
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


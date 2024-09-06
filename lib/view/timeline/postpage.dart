import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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

                    // 画像がある場合は画像をアップロードしてからデータを保存
                    if (_image != null) {
                      print("写真あり");
                      await _upload(_mainReference);  // 非同期でアップロードを待つ
                    } else {
                      // 画像がない場合はimagePathをデフォルト値で保存
                      print("写真なし");
                      await _mainReference.set({
                        'createdTime': _post.createdTime,
                        'description': _post.description,
                        'favoriteCount': _post.favoriteCount,
                        'imagePath': 'imageurl',  // デフォルトのURLや空の値を入れる
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
                CircleAvatar(
                    radius:30
                ),
                TextFormField(
                  decoration: InputDecoration(
                    hintText: '入力して'
                  ),
                  onSaved: (String? value) {
                    _post.description = value!;
                  },
                  initialValue: _post.description,
                ),

                _image==null
                ? Text('')
                :Image.file(_image!),
                Row(
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


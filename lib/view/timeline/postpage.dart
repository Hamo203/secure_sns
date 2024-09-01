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
    setState(() {
      _image = File(photo!.path);
    });
  }

  Future getImageFromGallery() async{
    // Pick an image.
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = File(image!.path);
    });
  }

  void _upload(DocumentReference _mainReference) async {
    if (_image == null) return;
    // imagePickerで画像を選択する
    // upload
    XFile? pickerFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickerFile == null) return; // 画像が選択されなかった場合の処理
    File file = File(pickerFile.path);

    FirebaseStorage storage = FirebaseStorage.instance;
    String imageUrl;

    try {
      TaskSnapshot snapshot = await storage
          .ref("users/${userAuth.currentUser!.uid}/posts/${_mainReference.id}.png")
          .putFile(_image!);
      imageUrl = await snapshot.ref.getDownloadURL();
      _formKey.currentState!.save();
      _mainReference.set(
          {
            'createdTime':_post.createdTime,
            'description':_post.description,
            'favoriteCount':_post.favoriteCount,
            'imagePath':imageUrl,
            'postAccount':_post.postAccount,
            'retweetCount':_post.retweetCount,
          }
      );
      print("保存が完了した");

    } catch (e) {
      print(e);
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
          /*
          IconButton(
              onPressed: (
                  ){},
              icon: Image.asset('images/OIP.jpg'),
          ),*/
          IconButton(
            //snsにシェア用
            icon: Icon(Icons.save),
            onPressed: () async{
              print("保存ボタンを押した");
              try{
                if(_image!=null){
                  print("写真在り");
                  _upload(_mainReference);
                  Navigator.pushAndRemoveUntil(
                      context, MaterialPageRoute(builder: (context) => Navigation()),(_) => false);
                }else{
                  _formKey.currentState!.save();
                  _mainReference.set(
                      {
                        'createdTime':_post.createdTime,
                        'description':_post.description,
                        'favoriteCount':_post.favoriteCount,
                        'imagePath':'imageurl',
                        'postAccount':_post.postAccount,
                        'retweetCount':_post.retweetCount,
                      }
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


import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

import '../../model/account.dart';
import '../../navigation.dart';
import '../account/user_auth.dart';

class Registerpage2 extends StatefulWidget {
  const Registerpage2({super.key});

  @override
  State<Registerpage2> createState() => _Registerpage2State();
}

class _Registerpage2State extends State<Registerpage2> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String name = "";
  String username = "";
  String bio = "";

  TextEditingController _nameController = TextEditingController();
  TextEditingController _usernameController = TextEditingController();

  File? _image ;
  final ImagePicker picker = ImagePicker();
  //写真撮影用
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
  //写真をギャラリーから取得用
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

  final Account _newAccount = Account();
  Future<void> _setaccount(DocumentReference _mainReference) async {
    try {
      FirebaseStorage storage = FirebaseStorage.instance;
      String imageUrl;
      if(_image==null){
        print("image is null");
        imageUrl='imageurl';
      }
      else{
        print("image is not null");
        TaskSnapshot snapshot = await storage
            .ref("users/${userAuth.currentUser!.uid}/${_mainReference.id}.png")
            .putFile(_image!);
        imageUrl = await snapshot.ref.getDownloadURL();
      }
      _formKey.currentState!.save();
      await _mainReference.set({
        'name': _newAccount.name,
        'username': _newAccount.username,
        'profilePhotoUrl':imageUrl,
        'followers': [],
      });
      Fluttertoast.showToast(msg: "保存に成功しました");
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => Navigation()),
            (_) => false,
      );
    } catch (e) {
      print(e);
      Fluttertoast.showToast(msg: "保存に失敗しました:");
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    //読み込みたいドキュメントを取得
    DocumentReference _mainReference = FirebaseFirestore.instance
        .collection('users')
        .doc(userAuth.currentUser!.uid);

    return Scaffold(
      body:SingleChildScrollView(
        child: Center(
          child: Form(
            key: _formKey,
            child: Container(
                margin: EdgeInsets.all(50),
                child:Column(
                children: [
                  SizedBox(height:10),
                  //title
                  Text("ユーザ情報を登録しましょう!",
                      style:TextStyle(
                        fontSize:20,
                      )),
                  SizedBox(height:20),
                  //ニックネーム入力欄
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'ニックネームを入力',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(
                          color: Color(0xFFF9E4C8),
                          width: 3,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(
                          color: Color(0xFFF9E4C8),
                          width: 3,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(
                          color: Colors.red,
                          width: 3,
                        ),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(
                          color: Colors.red,
                          width: 3,
                        ),
                      ),

                    ),
                    onSaved: (String? value){
                      _newAccount.name=value!;
                    },
                    validator: (value){
                      if(value!.isEmpty){
                        return 'ニックネームは必須項目です';
                      }else {
                        return null;
                      }
                    },
                  ),
                  SizedBox(height: screenHeight * 0.05),
                  //ユーザネーム入力欄
                  TextFormField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: 'ユーザ名を入力',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(
                          color: Color(0xFFF9E4C8),
                          width: 3,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(
                          color: Color(0xFFF9E4C8),
                          width: 3,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(
                          color: Colors.red,
                          width: 3,
                        ),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(
                          color: Colors.red,
                          width: 3,
                        ),
                      ),

                    ),
                    onSaved: (String? value){
                      _newAccount.username=value!;
                    },
                    validator: (value){
                      if(value!.isEmpty){
                        return 'ユーザネームは必須項目です';
                      }else {
                        return null;
                      }
                    },
                  ),
                  SizedBox(height: screenHeight * 0.05),
                  Text("プロフィール画像を入力"),
                  _image==null
                  //nullだったら初期アイコンを表示
                  ? Image.asset("images/kkrn_icon_user_14.png")
                  :Image.file(_image!),
                  Row(
                    mainAxisAlignment:MainAxisAlignment.spaceBetween,
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
                  IconButton(
                    //変更保存用
                      icon: Icon(Icons.save),
                      onPressed: () async {
                        print("保存ボタンを押した");
                        try {
                          // フォームが有効か確認
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            await _setaccount(_mainReference);
                            // 処理が完了したら画面遷移
                          }
                        } catch (e) {
                          print('保存に失敗しました: $e');
                        }
                      }
                  ),
                ],
              )
            ),
          ),
        ),
      )
    );
  }
}

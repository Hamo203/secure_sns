import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:secure_sns/view/account/user_auth.dart';

import '../../model/account.dart';

class AccountSetting extends StatefulWidget {
  const AccountSetting({super.key});

  @override
  State<AccountSetting> createState() => _AccountSettingState();
}

class _AccountSettingState extends State<AccountSetting> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final Account _account = Account();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchAccount();
  }

  //accountの取得 -> Account Pageの上の部分
  Future<void> fetchAccount() async {
    print("fetchAccount");
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('users').doc(userAuth.currentUser!.uid)
          .get();
      if (snapshot.exists) {
        setState(() {
          _account.name = snapshot.get('name');
          _account.username = snapshot.get('username');
          _account.profilePhotoUrl = snapshot.get('profilePhotoUrl');
          _account.bio = snapshot.get('description');

          // コントローラーに値を反映
          _nameController.text = _account.name;
          _usernameController.text = _account.username;
          _descriptionController.text = _account.bio;
        });
      } else {
        print('No account data found for this user.');
      }
    } catch (e) {
      print('Failed to fetch account data: $e');
    }
  }
  Future<void> _setaccount(DocumentReference _mainReference) async {
    try {
      _formKey.currentState!.save();
      await _mainReference.set({
        'name': _account.name,
        'username': _account.username,
        'profilePhotoUrl':_account.profilePhotoUrl,
        'description': _account.bio,
      });
      Fluttertoast.showToast(msg: "保存に成功しました");
    } catch (e) {
      print(e);
      Fluttertoast.showToast(msg: "保存に失敗しました");
    }
  }

  @override
  Widget build(BuildContext context) {
    //読み込みたいドキュメントを取得
    DocumentReference _mainReference = FirebaseFirestore.instance
        .collection('users')
        .doc(userAuth.currentUser!.uid);
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          margin:EdgeInsets.all(10),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Container(
                  width: screenWidth,
                  height: screenHeight,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(color: Colors.white),
                  child: Column(
                    children: [
                      SizedBox(height: screenHeight * 0.05),
                      ElevatedButton(
                        style:ElevatedButton.styleFrom(
                            shape: CircleBorder(),
                            padding: EdgeInsets.all(7)
                        ),
                        onPressed: () {
                          setState(() {
                            //_account.profilePhotoUrl = newPhotoUrl; // 新しいURLをセット
                          });
                          //アイコンが押された->写真変更
                          //print(_account.profilePhotoUrl);
                        },
                        child:  ClipOval(
                          child: _account.profilePhotoUrl == "imageurl" || _account.profilePhotoUrl.isEmpty
                              ? Image.asset(
                            'images/kkrn_icon_user_14.png',  // デフォルトのアイコン
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          )
                              : Image.network(
                            _account.profilePhotoUrl,  // ストレージの画像
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.05),
                      TextFormField(
                        controller: _nameController,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(50),
                        ],
                        decoration: InputDecoration(
                          counterText: '${_nameController.text.length}/50',
                          labelText: '名前を入力',
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
                        onSaved: (String? value) {
                          _account.name = value!;
                        },

                        validator: (value) {
                          if (value!.isEmpty) {
                            return '名前は必須項目です';
                          } else {
                            return null;
                          }
                        },
                      ),
                      TextFormField(
                        controller: _usernameController,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(15),
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[a-zA-Z0-9]'),
                          ),
                        ],
                        decoration: InputDecoration(
                          counterText: '${_usernameController.text.length}/15',
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
                              color: Color(0xFFC5D8E7),
                              width: 3,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(
                              color: Color(0xFFC5D8E7),
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
                        onSaved: (String? value) {
                          _account.username = value!;
                        },

                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'ユーザ名は必須項目です';
                          } else {
                            return null;
                          }
                        },
                      ),
                      TextFormField(
                        maxLines: null,
                        controller: _descriptionController,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(160),
                        ],
                        decoration: InputDecoration(
                          counterText:
                          '${_descriptionController.text.length}/160',
                          labelText: '自己紹介を入力',
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
                        onSaved: (String? value) {
                          _account.bio = value!;
                        },
                        validator: (value) {
                          if (value!.isEmpty) {
                            return '自己紹介は必須項目です';
                          } else {
                            return null;
                          }
                        },
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: Color(0xFFF6CBD1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          minimumSize: Size(screenWidth * 0.4,
                              screenHeight * 0.07), // 画面幅の40%, 画面高さの7%
                        ),
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            print("done");
                          }
                          await _setaccount(_mainReference);
                        },
                        child: Center(
                          child: Text(
                            '保存',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                              height: 0,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


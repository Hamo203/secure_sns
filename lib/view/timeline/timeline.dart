import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:secure_sns/view/account/accountpage.dart';

import '../../model/account.dart';
import '../../model/post.dart';
import 'package:like_button/like_button.dart';

import '../account/user_auth.dart';
import '../startup/login.dart';

class Timeline extends StatefulWidget {
  const Timeline({super.key});

  @override
  State<Timeline> createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
  //読み込んだPostをリスト形式で保存するためのもの
  List<Post> postlist= [];

  File? _image ;
  final ImagePicker picker = ImagePicker();
  final Post _comment = Post(createdTime: DateTime.now(),postAccount: userAuth.currentUser!.uid);
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    fetchPosts();
  }

  //postの取得
  Future<void> fetchPosts() async{
    List<Post> loadedPosts = [];

    //followしている人の投稿をTLに流す
    List<dynamic> followingId;
    try{
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('users').doc(userAuth.currentUser!.uid).get();
      if (snapshot.exists) {
        followingId =snapshot.get('followers');
        try{
          //firebaseからPostの情報を取得する
          for(var value in followingId){
            print('firebaseからPostの情報を取得する');
            QuerySnapshot snapshot = await FirebaseFirestore.instance
                .collection('users').doc(value)
                .collection('posts')
                .get();
            snapshot.docs.forEach((doc){
              Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
              loadedPosts.add( Post(
                postid: doc.id,
                description: data['description'],
                createdTime: (data['createdTime'] as Timestamp).toDate(),
                postAccount: data['postAccount'],
                buttonPush: data['buttonPush'] ?? false,
                favoriteCount: data['favoriteCount'] ?? 0,
                retweetCount: data['retweetCount'] ?? 0,
                imagePath:data['imagePath'],
              ));
            });
            print('Loaded post: ${loadedPosts[0].postAccount}');
          }
          setState(() {
            postlist = loadedPosts;
          });

        } catch (e) {
          print('Failed to fetch posts: $e');
        }
      }
    }catch(e){
      print("error :$e");
    }
  }

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
          .ref("users/${userAuth.currentUser!.uid}/posts/{post-id}/comments/${_mainReference.id}.png")
          .putFile(_image!);

      imageUrl = await snapshot.ref.getDownloadURL();
      _formKey.currentState!.save();

      await _mainReference.set({
        'createdTime': _comment.createdTime,
        'description': _comment.description,
        'favoriteCount': _comment.favoriteCount,
        'imagePath': imageUrl,
        'postAccount': _comment.postAccount,
        'retweetCount': _comment.retweetCount,
      });
      print("保存が完了した");
    } catch (e) {
      print('アップロード中にエラーが発生しました: $e');
    }
  }


  //postに必要なアカウント情報を取得
  Future<Map<String, String>> fetchAccountData(String userid) async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('users').doc(userid)
          .get();
      if (snapshot.exists) {
        // username と nameを返す
        return {
          'name':snapshot.get('name')+' @'+snapshot.get('username'),
          'profilePhotoUrl': snapshot.get('profilePhotoUrl'),
        };
      } else {
        print('can not get username ');
        return {
          'name': '',
          'profilePhotoUrl': '',
        };
      }
    } catch (e) {
      print('Failed to fetch account data: $e');
      return {
        'name': '',
        'profilePhotoUrl': '',
      };
    }
  }

  //Postを削除
  Future<void> _deletePost(String postId, int index) async {
    try {
      // Firestoreから削除
      await FirebaseFirestore.instance.collection('users')
          .doc(userAuth.currentUser!.uid).collection('posts')
          .doc(postId).delete();

      // ローカルリストから削除
      setState(() {
        postlist.removeAt(index);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("投稿が削除されました")),
      );
    } catch (e) {
      print('Failed to delete post: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("投稿の削除に失敗しました")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("タイムライン"),
        centerTitle: true,
      ),
      //設定用のdrawer
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            const SizedBox(
              height: 80,
              child: DrawerHeader(
                child: Text('設定とアクティビティ'),
                decoration: BoxDecoration(
                  color:  Color(0xFFC5D8E7),
                ),
              ),
            ),

            ListTile(
              title: Text('アカウント情報'),
              onTap: () {
                // Do something
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('ログアウト'),
              onTap: () async {
                // Do something
                bool? confirm = await showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text("ログアウト"),
                    content:
                    Text("ログアウトしてもよろしいですか？"),
                    actions: [
                      TextButton(
                        child: Text("キャンセル"),
                        onPressed: () {
                          Navigator.of(context).pop(
                              false); // キャンセルを返す
                        },
                      ),
                      TextButton(
                        child: Text("はい"),
                        onPressed: () {
                          Navigator.of(context).pop(
                              true); // 削除を返す
                        },
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  FirebaseAuth.instance.signOut();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => Login()),
                        (_) => false,
                  );
                }
              },
            ),
          ],
        ),
      ),

      //タイムラインのリスト
      body: Center(
        child: ListView.builder(
            itemCount: postlist.length,
            itemBuilder: (BuildContext context,int index){
              return FutureBuilder<Map<String, String>>(
                future: fetchAccountData(postlist[index].postAccount),
                builder: (context ,snapshot){
                  //読み込み終わってなかったらぐるぐる
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text("Error");
                  }else{
                    final String name = snapshot.data!['name'] ?? '';
                    final String profilePhotoUrl = snapshot.data!['profilePhotoUrl'] ?? '';

                    DocumentReference _mainReference = FirebaseFirestore.instance
                        .collection('users').doc(postlist[index].postAccount)
                        .collection('posts').doc(postlist[index].postid).collection('comments')
                        .doc();

                    return Container(
                      color: Colors.white,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 5,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    //アイコンとユーザネーム
                                    Row(
                                      children: [
                                        //アイコンボタン
                                        ElevatedButton(
                                          style:ElevatedButton.styleFrom(
                                            shape: CircleBorder(),
                                            padding: EdgeInsets.all(7)
                                          ),
                                          onPressed: () {
                                            //アイコンが押された人のAccountPageに飛ぶ
                                            Navigator.of(context).push(MaterialPageRoute(
                                              builder: (context) => Accountpage(
                                                userid: postlist[index].postAccount, // フォロワーのIDを渡す
                                              ),
                                            ));
                                          },
                                          child: ClipOval(
                                            //写真を保存していない、またはerrorでempty状態になっている時
                                            child: profilePhotoUrl == "imageurl" ||profilePhotoUrl.isEmpty
                                                ? Image.asset(
                                              'images/kkrn_icon_user_14.png', // デフォルトのアイコン
                                              width: 40,
                                              height: 40,
                                              fit: BoxFit.cover,
                                            )
                                                : Image.network(
                                              profilePhotoUrl,
                                              width: 40,
                                              height: 40,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 10),
                                        // username と nameを表示
                                        Text(name),
                                        SizedBox(width: 10),
                                      ],
                                    ),
                                    //投稿削除用のボタン
                                    IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () async {
                                        // 確認ダイアログを表示
                                        bool? confirm = await showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: Text("投稿の削除"),
                                            content:
                                            Text("本当にこの投稿を削除しますか？"),
                                            actions: [
                                              TextButton(
                                                child: Text("キャンセル"),
                                                onPressed: () {
                                                  Navigator.of(context).pop(
                                                      false); // キャンセルを返す
                                                },
                                              ),
                                              TextButton(
                                                child: Text("削除"),
                                                onPressed: () {
                                                  Navigator.of(context).pop(
                                                      true); // 削除を返す
                                                },
                                              ),
                                            ],
                                          ),
                                        );

                                        if (confirm == true) {
                                          _deletePost(postlist[index].postid!, index);
                                        }
                                      },
                                    ),
                                  ],
                                ),
                                //投稿内容
                                ListTile(
                                    title:Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children:[
                                          //投稿内容
                                          Text(postlist[index].description),
                                          // 画像が存在する場合のみ表示
                                          if (postlist[index].imagePath!="imageurl")
                                            Image.network(postlist[index].imagePath),
                                        ]
                                    ),
                                    onTap:(){
                                      print("押された");
                                    }
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    //時間、いいね、コメント
                                    Row(
                                      children: [
                                        // 時間の表示
                                        Text(DateFormat('yyyy/M/dd h:mm').format(
                                            postlist[index].createdTime!)),
                                        SizedBox(width: 10),
                                        LikeButton(
                                          size: 30,
                                          likeCount: postlist[index].favoriteCount,
                                          isLiked: postlist[index].buttonPush,
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.comment),
                                          onPressed: () async{
                                            // 確認ダイアログを表示
                                            bool? confirm = await showDialog(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                title: Text("返信コメント"),
                                                content:
                                                SingleChildScrollView(
                                                  child: Column(
                                                    children: [
                                                      Form(
                                                        key:_formKey,
                                                        child: TextFormField(
                                                          decoration: InputDecoration(
                                                              hintText: '入力して'
                                                          ),
                                                          onSaved: (String? value) {
                                                            _comment.description = value! ?? '';
                                                          },
                                                          initialValue: _comment.description,
                                                        ),
                                                      ),
                                                      if (_image != null)
                                                        Container(
                                                          // AlertDialogの幅の80%
                                                          width: MediaQuery.of(context).size.width * 0.8,
                                                          child: Image.file(
                                                            _image!,
                                                            // 画像を幅に合わせて拡縮
                                                            fit: BoxFit.cover,
                                                          ),
                                                        ),
                                                      //写真入力用ボタン
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
                                                actions: [
                                                  TextButton(
                                                    child: Text("キャンセル"),
                                                    onPressed: () {
                                                      Navigator.of(context).pop(
                                                          false); // キャンセルを返す
                                                    },
                                                  ),
                                                  TextButton(
                                                    child: Text("投稿"),
                                                    onPressed: () {
                                                      Navigator.of(context).pop(
                                                          true); // 削除を返す
                                                    },
                                                  ),
                                                ],
                                              ),
                                            );
                                            if (confirm == true) {
                                             print("投稿");
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
                                                     'createdTime': _comment.createdTime,
                                                     'description': _comment.description,
                                                     'favoriteCount': _comment.favoriteCount,
                                                     'imagePath': 'imageurl',  // デフォルトのURL　-> imageurl
                                                     'postAccount': _comment.postAccount,
                                                     'retweetCount': _comment.retweetCount,
                                                   });
                                                 }
                                                 print('保存に成功しました: ');

                                               }
                                             } catch (e) {
                                               print('保存に失敗しました: $e');
                                             }
                                            }
                                            //ダイアログが閉じられたらリセット
                                            setState(() {
                                              _image=null;
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Divider(),
                        ],
                      ),
                    );
                  }
                },

              );
            }
        ),
      ),
    );
  }
}

/*
* Container(
                  child:Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children:[
                            Row(
                              children: [
                                CircleAvatar(
                                  radius:30
                                ),
                                SizedBox(width: 10,),
                                Text(account.name),
                              ],

                            ),
                            OutlinedButton(
                                onPressed: (){},
                                child: Text("フォロー"),
                            )

                          ]
                        ),
                      ),
                      Image.asset('images/testcat.jpg'),
                      LikeButton(
                          size: 40,
                          likeCount: 0,
                          isLiked: postlist[index].buttonPush),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 20,vertical: 5),
                          color: Colors.white,
                          child: Column(
                            children: [
                              Text(DateFormat('yyyy/M/dd h:mm').format(postlist[index].createdTime!)),
                              Text(postlist[index].description,),
                            ],
                          )
                      ),
                      SizedBox(height: 10,)
                    ],

                  ),
              )
* */
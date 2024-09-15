import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:secure_sns/view/account/account_setting.dart';
import 'package:secure_sns/view/account/user_auth.dart';
import '../../model/account.dart';
import '../../model/post.dart';
import 'package:like_button/like_button.dart';

class Accountpage extends StatefulWidget {
  final String userid;

  const Accountpage({
    required this.userid,
    Key? key,
  }): super(key: key);

  @override
  State<Accountpage> createState() => _AccountpageState();
}

class _AccountpageState extends State<Accountpage> {
  List<Post> postlist=[];
  Account account = new Account(
      name:"",
      username:"",
      bio:""
  );

  //postの取得
  Future<void> fetchPosts() async{
    try{
      //firebaseからPostの情報を取得する
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users').doc(widget.userid)
          .collection('posts')
          .get();
      List<Post> loadedPosts = [];
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
      setState(() {
        postlist = loadedPosts;
      });
    } catch (e) {
      print('Failed to fetch posts: $e');
    }
  }

  //accountの取得 -> Account Pageの上の部分
  Future<void> fetchAccount() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('users').doc(widget.userid)
          .get();
      if (snapshot.exists) {
        setState(() {
          account.name = snapshot.get('name');
          account.username = snapshot.get('username');
          account.bio = snapshot.get('description');
        });
      } else {
        print('No account data found for this user.');
      }
    } catch (e) {
      print('Failed to fetch account data: $e');
    }
  }

  //Post消す
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
  void initState() {
    super.initState();
    fetchPosts();
    fetchAccount();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              ElevatedButton(
                style:ElevatedButton.styleFrom(
                    shape: CircleBorder(),
                    padding: EdgeInsets.all(7)
                ),
                onPressed: () {  },
                child: ClipOval(
                    child: Image(
                      width: 80,
                      image: AssetImage('images/testcat.jpg'),
                      fit: BoxFit.contain,
                    )
                ),
              ),
              Container(
                padding: EdgeInsets.all(20),
                margin: EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Color(0xFFF9E4C8)),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Stack(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                account.name,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontFamily: 'Inria Sans',
                                  color: Colors.black87,
                                ),
                              ),
                              Text(
                                '@'+account.username,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'Inria Sans',
                                  color: Colors.black54,
                                ),
                              ),
                              Text(
                                account.bio,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontFamily: 'Inria Sans',
                                  color: Colors.black54,
                                ),
                              ),
                              SizedBox(height: 10,),
                              Row(
                                children: [
                                  Text(
                                    "63",
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontFamily: 'Inria Sans',
                                      color: Colors.black,
                                    ),
                                  ),
                                  Text(
                                    "フォロー中",
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontFamily: 'Inria Sans',
                                      color: Colors.black87,
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    "23",
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontFamily: 'Inria Sans',
                                      color: Colors.black,
                                    ),
                                  ),
                                  Text(
                                    "フォロワー",
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontFamily: 'Inria Sans',
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                    Positioned(
                      //アカウント設定
                      top: 0,
                      right: 0,
                      child: OutlinedButton(
                        onPressed: () async{
                          await showModalBottomSheet<void>(
                            context: context,
                            backgroundColor: Colors.transparent,
                            isScrollControlled: false,
                            enableDrag: true,
                            barrierColor: Colors.black.withOpacity(0.5),
                            builder:(context){
                            return AccountSetting();}
                          );
                          },

                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Color(0xFFC5D8E7)),
                        ),
                        child: Text(
                          '編集',
                          style: TextStyle(
                              color: Colors.grey,
                            fontFamily: 'Inria Sans'),
                        ),

                      ),
                    ),
                  ],
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: postlist.length,
                itemBuilder: (BuildContext context, int index) {
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
                                  Row(
                                    children: [
                                      // アイコンの表示
                                      ElevatedButton(
                                        style:ElevatedButton.styleFrom(
                                            shape: CircleBorder(),
                                            padding: EdgeInsets.all(7)
                                        ),
                                        onPressed: () {  },
                                        child: ClipOval(
                                            child: Image(
                                              width: 40,
                                              image: AssetImage('images/testcat.jpg'),
                                              fit: BoxFit.contain,
                                            )
                                        ),
                                      ),
                                      SizedBox(width: 10), // 時間とアイコンの間のスペース
                                      Text(account.name+' @'+account.username),
                                      SizedBox(width: 10), // 時間とアイコンの間のスペース
                                    ],
                                  ),
                                  IconButton(
                                    //投稿削除用のボタン
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
                              ListTile(
                                //投稿内容
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
                                children: [
                                  Text(DateFormat('yyyy/M/dd h:mm').format(
                                      postlist[index].createdTime!)),
                                  SizedBox(width: 10),
                                  LikeButton(
                                    size: 30,
                                    likeCount: postlist[index].favoriteCount,
                                    isLiked: postlist[index].buttonPush,
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
                },
              ),
            ],
          ),
        ),
      ),
    );

  }
}

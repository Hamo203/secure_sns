import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:secure_sns/view/talk/chat.dart'; // FirestoreChatPage が定義されたファイルをインポート

import '../account/accountpage.dart';
import '../account/user_auth.dart';

class Chatroom extends StatefulWidget {
  const Chatroom({super.key});

  @override
  State<Chatroom> createState() => _ChatroomState();
}

class _ChatroomState extends State<Chatroom> {
  List followers = [];

  // Firebaseからfollowerのリストを取得する
  Future<void> fetchFollowers() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userAuth.currentUser!.uid)
          .get();
      if (snapshot.exists) {
        setState(() {
          followers = List<String>.from(snapshot.get('followers'));
        });
      } else {
        print("No followers data found.");
      }
    } catch (e) {
      print("Error fetching followers: $e");
    }
  }

  // フォロワーの名前とアイコンを Firestore から取得
  Future<Map<String,String>> _fetchFollowerData(String followerId) async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(followerId)
          .get();
      if (snapshot.exists) {
        return{
          'name':snapshot.get('name'),
          'profilePhotoUrl': snapshot.get('profilePhotoUrl'),
        };  // 'name' フィールドを取得
      } else {
        return{
          'name':'Unknown User',
          'profilePhotoUrl':'',
        };
        // ユーザが存在しない場合のデフォルト名
      }
    } catch (e) {
      print("Error fetching follower name: $e");
      return{
        'name':'Error User',
        'profilePhotoUrl':'',
      }; // エラー時のデフォルト名
    }
  }
  //最後にした会話の文を取得
  Future<String> _fetchChats(String chatId) async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('chats')
          .doc(chatId)
          .get();
      if (snapshot.exists) {
        String lastMessage = snapshot.get('lastMessage');
        return lastMessage;
      } else {
        // まだ会話が始まっていない場合
        return '';
      }
    } catch (e) {
      print("Error: $e");
      return 'エラーが発生しました';
    }
  }

  //chatroomのwidget
  Widget _buildChatTile(String followerId) {
    String chatId = _getChatId(userAuth.currentUser!.uid, followerId); // チャットIDを生成

    return FutureBuilder<Map<String, String>>(
      future: _fetchFollowerData(followerId), // フォロワーの名前とアイコンを取得
      builder: (context, snapshot) {
        //非同期処理
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const ListTile(
            title: Text('読み込み中...'),
          );
        } else if (snapshot.hasError) {
          return ListTile(
            title: Text('エラーが発生しました: ${snapshot.error}'),
          );
        } else {
          String followerName = snapshot.data!['name'] ?? 'Unknown User'; // フォロワーの名前
          final String profilePhotoUrl = snapshot.data!['profilePhotoUrl'] ?? '';

          return FutureBuilder<String>(
            future: _fetchChats(chatId),
            builder: (context, chatSnapshot) {
              if (chatSnapshot.connectionState == ConnectionState.waiting) {
                return const ListTile(
                  title: Text('読み込み中...'),
                );
              } else if (chatSnapshot.hasError) {
                return ListTile(
                  title: Text('エラーが発生しました: ${chatSnapshot.error}'),
                );
              } else {
                // 最後のメッセージ
                String lastMessage = chatSnapshot.data ?? '';
                return InkWell(
                  //room画面遷移
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => FirestoreChatPage(
                        chatId: chatId, // 生成されたチャットIDを渡す
                        partnerId: followerId, // フォロワーのIDを渡す
                      ),
                    ));
                  },
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: ListTile(
                          // ユーザアイコン
                          leading: ElevatedButton(
                            style:ElevatedButton.styleFrom(
                                shape: CircleBorder(),
                                padding: EdgeInsets.all(7)
                            ),
                            onPressed: () {
                              //アイコンが押された人のAccountPageに飛ぶ
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => Accountpage(
                                  userid: followerId, // フォロワーのIDを渡す
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
                          title: Text(
                            followerName, // フォロワーの名前をタイトルとして表示
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.normal),
                          ),
                          subtitle: Text(lastMessage), // 最後のメッセージを表示
                        ),
                      ),
                    ],
                  ),
                );
              }
            },
          );
        }
      },
    );
  }

  @override
  void initState() {
    super.initState();
    fetchFollowers();
  }

  // チャットIDを生成
  String _getChatId(String userId, String followerId) {
    return userId.compareTo(followerId) > 0
        ? '$userId-$followerId'
        : '$followerId-$userId';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'メッセージ',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontFamily: 'Inria Sans',
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Container(
        color: Colors.white,
        child: SafeArea(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: followers.length,
            itemBuilder: (BuildContext context, int index) {
              String followerId = followers[index];
              return _buildChatTile(followerId); // タイルをビルド
            },
          ),
        ),
      ),
    );
  }
}

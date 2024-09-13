import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:secure_sns/view/talk/chat.dart'; // FirestoreChatPage が定義されたファイルをインポート

import '../account/user_auth.dart';

class Chatroom extends StatefulWidget {
  const Chatroom({super.key});

  @override
  State<Chatroom> createState() => _ChatroomState();
}

class _ChatroomState extends State<Chatroom> {
  List followers = [];

  Future<void> fetchFollowers() async {
    try {
      // Firebaseからfollowerのリストを取得する
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

  // フォロワーの名前を Firestore から取得
  Future<String> _fetchFollowerName(String followerId) async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(followerId)
          .get();
      if (snapshot.exists) {
        return snapshot.get('name'); // 'name' フィールドを取得
      } else {
        return 'Unknown User'; // ユーザが存在しない場合のデフォルト名
      }
    } catch (e) {
      print("Error fetching follower name: $e");
      return 'Error User'; // エラー時のデフォルト名
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

    return FutureBuilder<String>(
      future: _fetchFollowerName(followerId), // フォロワーの名前を取得
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
          String followerName = snapshot.data ?? 'Unknown User'; // フォロワーの名前
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
                String lastMessage = chatSnapshot.data ?? ''; // 最後のメッセージ
                return InkWell(
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
                          leading: CircleAvatar(radius: 30), // ユーザアイコン
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

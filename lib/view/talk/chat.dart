import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:uuid/uuid.dart';

class FirestoreChatPage extends StatefulWidget {
  final String chatId; // チャットルームID
  final String partnerId; // チャット相手のID

  const FirestoreChatPage({
    //引数指定
    required this.chatId,
    required this.partnerId,
    Key? key,
  }) : super(key: key);

  @override
  State<FirestoreChatPage> createState() => _FirestoreChatPageState();
}

class _FirestoreChatPageState extends State<FirestoreChatPage> {
  List<types.Message> _messages = [];
  late String _userId; // ログインしているユーザーID
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _loadUserId();
    _loadMessagesFromFirestore();
  }

  // FirebaseAuth からユーザーIDを取得
  void _loadUserId() {
    final user = _auth.currentUser;
    if (user != null) {
      setState(() {
        _userId = user.uid;
      });
    } else {
      print("User not logged in");
    }
  }

  // Firestoreからメッセージ履歴を取得

  void _loadMessagesFromFirestore() {
    FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        // メッセージの配列を取得、なければ空のリストを設定
        List<dynamic> messageList = snapshot.data() != null && snapshot.get('messages') != null
            ? snapshot.get('messages') as List<dynamic>
            : [];

        // メッセージリストを変換して表示できる形式にする
        List<types.Message> loadedMessages = messageList.map((messageData) {

          //flutter-chat-uiの使用通り
          return types.TextMessage(
            author: types.User(id: messageData['senderId']),
            createdAt: (messageData['createdAt'] as Timestamp).millisecondsSinceEpoch,
            id: const Uuid().v4(),
            text: messageData['text'],
          );
        }).toList();

        loadedMessages.sort((a, b) => b.createdAt!.compareTo(a.createdAt!));


        setState(() {
          _messages = loadedMessages;
        });
      }
    });
  }

  // メッセージを送信する処理
  void _handleSendPressed(types.PartialText message) async {
    if (_userId.isEmpty) return;

    final textMessage = types.TextMessage(
      author: types.User(id: _userId), // 現在のユーザーIDを設定
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: const Uuid().v4(),
      text: message.text,
    );

    _addMessage(textMessage);

    // 新しいメッセージデータを作成
    Map<String, dynamic> newMessageData = {
      'text': message.text,
      'senderId': _userId,
      'createdAt': Timestamp.now(),
    };

    try {
      // Firestoreの既存のメッセージ配列を取得し、新しいメッセージを追加
      DocumentReference chatDocRef = FirebaseFirestore.instance.collection('chats').doc(widget.chatId);
      DocumentSnapshot snapshot = await chatDocRef.get();

      if (snapshot.exists && snapshot.data() != null) {
        // 既存のメッセージ配列を取得　なければ空のリストを初期化
        List<dynamic> messageList = snapshot.get('messages') ?? [];

        // 新しいメッセージをリストに追加
        messageList.add(newMessageData);

        // Firestoreにメッセージリストを更新
        await chatDocRef.set({
          'messages': messageList,
          'lastMessage': message.text, // 最後のメッセージを保存
          'lastMessageTime': Timestamp.now(), // 最後のメッセージ時間を保存
        }, SetOptions(merge: true));
      } else {
        // snapshotのデータがないときに自動で新しく作る
        await chatDocRef.set({
          'messages': [newMessageData], // メッセージ配列を追加
          'participants': [widget.partnerId, _userId], // 参加者情報
          'lastMessage': message.text,
          'lastMessageTime': Timestamp.now(), // 最後のメッセージ時間を保存
        });
      }
    } catch (e) {
      print("Error saving message: $e");
    }
  }

  // 新しいメッセージをメッセージリストに追加
  void _addMessage(types.Message message) {
    setState(() {
      _messages.insert(0, message); // 新しいメッセージをリストの先頭に追加
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('チャット'),
    ),
    body: _userId.isNotEmpty
        ? Chat(
      messages: _messages,
      onSendPressed: _handleSendPressed, // メッセージ送信時に実行される関数
      showUserAvatars: true,
      showUserNames: true,
      user: types.User(id: _userId), // 現在のユーザー情報を設定
    )
        : const Center(child: CircularProgressIndicator()), // ユーザーIDが取得されるまでローディングを表示
  );
}

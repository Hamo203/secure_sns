import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

import '../../api/natural_language_service.dart';

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

  String _result = '';

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

  // Firestoreからメッセージを取得->配列へ
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

    bool result= await _analyzeText(textMessage);
    if(result){
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

          // Firestoreのメッセージリストを更新
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

  }

  // 新しいメッセージをメッセージリストに追加
  void _addMessage(types.Message message) {
    setState(() {
      _messages.insert(0, message); // 新しいメッセージをリストの先頭に追加
    });
  }

  //messageを押したときの処理
  void _handleMessageTap(BuildContext _, types.Message message) async {
    if (message is types.TextMessage) {
      // ここでタップしたメッセージに対してアクションを実行
      print('Message tapped: ${message.text}');
    }
    //messageがファイルだったらダウンロード
    if (message is types.FileMessage) {
      var localPath = message.uri;
      if (message.uri.startsWith('http')) {
        try {
          final index =
          _messages.indexWhere((element) => element.id == message.id);
          final updatedMessage =
          (_messages[index] as types.FileMessage).copyWith(
            isLoading: true,
          );

          setState(() {
            _messages[index] = updatedMessage;
          });

          final client = http.Client();
          final request = await client.get(Uri.parse(message.uri));
          final bytes = request.bodyBytes;
          final documentsDir = (await getApplicationDocumentsDirectory()).path;
          localPath = '$documentsDir/${message.name}';

          if (!File(localPath).existsSync()) {
            final file = File(localPath);
            await file.writeAsBytes(bytes);
          }
        } finally {
          final index =
          _messages.indexWhere((element) => element.id == message.id);
          final updatedMessage =
          (_messages[index] as types.FileMessage).copyWith(
            isLoading: null,
          );

          setState(() {
            _messages[index] = updatedMessage;
          });
        }
      }

      await OpenFilex.open(localPath);
    }
  }

  Future<bool> _analyzeText(types.Message message) async {
    double score=1;
    double magnitude=1;
    bool result;

    if (message is types.TextMessage) {
      String text = message.text;

      // テキストが入力されていないとき
      if (text.isEmpty) {
        setState(() {
          _result = 'Please enter some text';
        });
        return false;
      }

      // Natural Language APIを呼び出して解析
      final analysisResult = await NaturalLanguageService().analyzeSentiment(text);
      if(analysisResult!=null){
        setState(() {
          score = analysisResult['score']!;
          magnitude = analysisResult['magnitude']!;
          _result='Score: $score, Magnitude: $magnitude';
        });
      }

      print("result: $_result");

      if(score<1 && magnitude < 1){
        return await _showAlertDialog(score, magnitude);
      }else{
        //点が高かったらtrue
        return true;
      }

    } else {
      // メッセージがテキストメッセージでない場合の処理
      setState(() {
        _result = 'Message is not a text message';
      });
      print("result: $_result");
      return true;
    }
  }

  Future<bool> _showAlertDialog(double score, double magnitude) {
    print("score:$score, magnitude:$magnitude");
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min, // 高さをコンテンツに合わせる
              children: [
                // コンテンツ部分
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16.0),
                  decoration: const BoxDecoration(
                    color: Color(0xFFf7f7f7),
                    border: Border(
                      bottom: BorderSide(
                        width: 0.5,
                        color: Color.fromRGBO(0, 0, 0, 0.4),
                      ),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text("本当に送ってもだいじょうぶですか？"),
                      const SizedBox(height: 16.0),
                      Image.asset(
                        'images/face/bully.png',
                        width: 150,
                        height: 150,
                      ),
                    ],
                  ),
                ),
                // ボタン部分
                Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFf7f7f7),
                  ),
                  width: double.infinity,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      //キャンセルボタン
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(false);
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.black, backgroundColor: Color(0xFFf9e4c8),
                          ),
                          child: const Text("キャンセル"),
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: Colors.grey,
                      ),
                      //送信ボタン
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(true);
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.black, backgroundColor: Color(0xFFc5d8e7),
                          ),
                          child: const Text("送信"),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ).then((value) => value ?? false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('チャット'),
    ),
    body: _userId.isNotEmpty
        ? Chat(
            messages: _messages,
            onMessageTap: _handleMessageTap,
            onSendPressed: _handleSendPressed, // メッセージ送信時に実行される関数
            showUserAvatars: true,
            showUserNames: true,
            user: types.User(id: _userId), // 現在のユーザー情報を設定
          )
        : const Center(child: CircularProgressIndicator()), // ユーザーIDが取得されるまでローディングを表示
  );
}

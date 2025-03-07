import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

import '../../api/api_service.dart';
import '../../api/natural_language_service.dart';
import '../../services/image_service.dart';
import '../../services/offencive_classfier.dart';
import '../components/offencivewordsList.dart';
import '../feedback/nvc_feedback_page.dart';

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

  //攻撃性判定用
  late ApiService apiService;
  late OffensiveClassifier offensiveClassifier;
  late ImageService imageService; // ImageServiceのインスタンスを追加

  //攻撃的またはグレーゾーンの値
  double nonOffensivePercentage=0.0;
  double offensivePercentage=0.0;
  double grayZonePercentage=0.0;

  String _result = '';

  @override
  void initState() {
    super.initState();
    _loadUserId();
    _loadMessagesFromFirestore();
    apiService = ApiService(baseUrl: dotenv.env['BASE_URL']!);
    imageService = ImageService(); // ImageServiceを初期化
  }

  bool containsOffensiveWord(String text) {
    //、大文字・小文字の違いを無視
    String lowerText = text.toLowerCase();
    for (String word in offensiveWordList) {
      if (lowerText.contains(word)) {
        print("攻撃的な言葉を含む");
        return true;
      }
    }
    return false;
  }


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    //OffensiveClassifier のインスタンス化
    offensiveClassifier = OffensiveClassifier(apiService: apiService, context: context);
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

    // 攻撃性の分析
    bool isSafe = await _analyzeText(message.text);
    bool hasOffensiveWord = containsOffensiveWord(message.text);

    if (!isSafe|| hasOffensiveWord) {
      print("攻撃性またはグレーゾーンが高い フィードバックを実行");

      bool feedbackResult = await _showNVCFeedBack(message.text,nonOffensivePercentage,offensivePercentage,grayZonePercentage);

      if (!feedbackResult) {
        print("フィードバックをキャンセル");
        return; // 送信を中止
      }

      // 修正後の文章を反映
      message = types.PartialText(text: _result); // 修正案を反映
    }

    // 修正後またはそのままの文章を送信
    final textMessage = types.TextMessage(
      author: types.User(id: _userId),
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: const Uuid().v4(),
      text: message.text,
    );

    _addMessage(textMessage);

    Map<String, dynamic> newMessageData = {
      'text': message.text,
      'senderId': _userId,
      'createdAt': Timestamp.now(),
    };

    try {
      DocumentReference chatDocRef = FirebaseFirestore.instance.collection('chats').doc(widget.chatId);
      DocumentSnapshot snapshot = await chatDocRef.get();

      if (snapshot.exists && snapshot.data() != null) {
        List<dynamic> messageList = snapshot.get('messages') ?? [];
        messageList.add(newMessageData);

        await chatDocRef.set({
          'messages': messageList,
          'lastMessage': message.text,
          'lastMessageTime': Timestamp.now(),
        }, SetOptions(merge: true));
      } else {
        await chatDocRef.set({
          'messages': [newMessageData],
          'participants': [widget.partnerId, _userId],
          'lastMessage': message.text,
          'lastMessageTime': Timestamp.now(),
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

  Future<bool> _analyzeText(String message) async {
    if (message.isEmpty) {
      setState(() {
        _result = 'テキストを入力してください';
      });
      return true; // 空のメッセージは安全とみなす
    }

    try {
      // テキストを分類
      Map<String, String> analysisResult = await offensiveClassifier.apiService.classifyText(message);

      // '%' を除去してから double に変換
      nonOffensivePercentage=double.parse(analysisResult['non_offensive']!.replaceAll('%', '').trim());
      offensivePercentage = double.parse(analysisResult['offensive']!.replaceAll('%', '').trim());
      grayZonePercentage = double.parse(analysisResult['gray_zone']!.replaceAll('%', '').trim());

      // 結果を表示
      setState(() {
        _result = '''
      攻撃的でない発言: ${nonOffensivePercentage}%
      グレーゾーンの発言: ${grayZonePercentage}%
      攻撃的な発言: ${offensivePercentage}%
      ''';
      });

      print("分析結果: $analysisResult"); // デバッグ用

      // 攻撃的またはグレーゾーンが55%以上の場合はfalse
      return offensivePercentage < 55 && grayZonePercentage < 55;
    } catch (e) {
      print('分析中にエラーが発生しました: $e');
      setState(() {
        _result = 'エラーが発生しました: $e';
      });
      return true; // エラー時は安全とみなす
    }
  }

  Future<bool> _showNVCFeedBack(String originalContent,double nonOffensive,double offensive,double grayZone) async {
    final Map<String, dynamic>? result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NvcFeedbackPage(originalContent: originalContent,nonOffensivePercentage: nonOffensive, offensivePercentage: offensive,grayZonePercentage: grayZone),
      ),
    );

    if (result != null && result['isConfirmed'] == true) {
      setState(() {
        _result = result['rewrittenContent']; // 修正後の文章を保存
      });
      return true;
    } else {
      return false;
    }
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

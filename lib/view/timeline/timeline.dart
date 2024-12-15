import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:secure_sns/view/account/accountpage.dart';
import 'package:secure_sns/view/components/account_drawer.dart';

import '../../api/api_service.dart';
import '../../api/natural_language_service.dart';
import '../../model/account.dart';
import '../../model/post.dart';
import 'package:like_button/like_button.dart';

import '../../services/image_service.dart';
import '../../services/offencive_classfier.dart';
import '../account/user_auth.dart';
import '../feedback/nvc_feedback_page.dart';
import '../startup/login.dart';
import 'comment.dart';

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
  String _result = '';

  //タイムラインから入力できるコメントの攻撃性判定用
  late ApiService apiService;
  late OffensiveClassifier offensiveClassifier;

  late ImageService imageService; // ImageServiceのインスタンスを追加

  //攻撃性の割合を入れておく変数
  double _offensivePercentage = 0.0;
  double _grayZonePercentage = 0.0;


  @override
  void initState() {
    super.initState();
    fetchPosts();
    apiService = ApiService(baseUrl: dotenv.env['BASE_URL']!);
    imageService = ImageService(); // ImageServiceを初期化
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    //OffensiveClassifier のインスタンス化
    offensiveClassifier = OffensiveClassifier(apiService: apiService, context: context);
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

              Map<String, dynamic> likes = data['likes'] ?? {};
              bool isLiked = likes[userAuth.currentUser!.uid] ?? false;

              loadedPosts.add( Post(
                postid: doc.id,
                description: data['description'],
                createdTime: (data['createdTime'] as Timestamp).toDate(),
                postAccount: data['postAccount'],
                buttonPush: isLiked ?? false,
                favoriteCount: data['favoriteCount'] ?? 0,
                retweetCount: data['retweetCount'] ?? 0,
                imagePath:data['imagePath'],
              ));
              //いいね
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

  // 写真を撮る
  Future<void> captureImage() async {
    File? photo = await imageService.captureImage();
    if (photo != null) {
      setState(() {
        _image = photo;
      });
    }
  }

  // ギャラリーから写真を選ぶ
  Future<void> getImageFromGallery() async {
    File? image = await imageService.getImageFromGallery();
    if (image != null) {
      setState(() {
        _image = image;
      });
    }
  }

  //コメントを分析する
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
      double offensivePercentage = double.parse(analysisResult['offensive']!.replaceAll('%', '').trim());
      double grayZonePercentage = double.parse(analysisResult['gray_zone']!.replaceAll('%', '').trim());

      // 結果を表示
      setState(() {
        _grayZonePercentage = grayZonePercentage;
        _offensivePercentage = offensivePercentage;
        _result = '''
      攻撃的でない発言: ${analysisResult['non_offensive']}%
      グレーゾーンの発言: ${grayZonePercentage}%
      攻撃的な発言: ${offensivePercentage}%
      ''';
      });

      print("分析結果: $analysisResult"); // デバッグ用

      // 攻撃的またはグレーゾーンが60%以上の場合はfalse
      return offensivePercentage < 60 && grayZonePercentage < 60;
    } catch (e) {
      print('分析中にエラーが発生しました: $e');
      setState(() {
        _grayZonePercentage = 0.0;
        _offensivePercentage = 0.0;

        _result = 'エラーが発生しました: $e';
      });
      return true; // エラー時は安全とみなす
    }
  }

  Future<bool> _showNVCFeedBack(String originalContent,double offensivePercentage,double grayZonePercentage) async {
    final Map<String, dynamic>? result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NvcFeedbackPage(originalContent: originalContent,offensivePercentage: offensivePercentage,grayZonePercentage: grayZonePercentage),
      ),
    );

    if (result != null && result['isConfirmed'] == true) {
      setState(() {
        _comment.description = result['rewrittenContent']; // 言い換えた内容を保存
      });
      return true;
    } else {
      // ユーザーがキャンセルした場合
      return false;
    }
  }


  //コメントのuploadをおこなう
  Future<void> _upload(DocumentReference _mainReference ,String userid,String postid) async {
    try {
      FirebaseStorage storage = FirebaseStorage.instance;
      String imageUrl;

      if(_image!=null){
        TaskSnapshot snapshot = await storage
            .ref("users/${userid}/posts/${postid}/comments/${_mainReference.id}.png")
            .putFile(_image!);
        imageUrl = await snapshot.ref.getDownloadURL();
      }else{
        imageUrl="imageurl";
      }
      print("保存します");
      print(_formKey);
      // フォームの内容を保存
      if (_formKey.currentState != null) {
        _formKey.currentState!.save();

        bool isSafe = await _analyzeText(_comment.description);
        if (!isSafe) {
          print("攻撃的またはグレーゾーンが高い NVCフィードバックを表示");

          // _analyzeText内で攻撃性が高いと判断された場合
          bool feedbackResult = await _showNVCFeedBack(_comment.description,_offensivePercentage,_grayZonePercentage);

          if (!feedbackResult) {
            print("ユーザーがフィードバックをキャンセル");
            return;
          }
        }
        // Firestoreにデータを保存
        await _mainReference.set({
          'createdTime': _comment.createdTime,
          'description': _comment.description,
          'favoriteCount': _comment.favoriteCount,
          'imagePath': imageUrl,  // アップロードされた画像のURL
          'postAccount': _comment.postAccount,
          'retweetCount': _comment.retweetCount,
        });

        print("保存が完了しました");
      } else {
        print("Error: フォームの状態が無効です");
      }
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

  Future<bool> onLikeButtonTapped(String postAccount,String postId,bool isLiked) async{
    print("いいねが押された");
    try{
      // ユーザーのドキュメント参照
      DocumentReference userRef = FirebaseFirestore.instance
          .collection('users').doc(postAccount)
          .collection('posts').doc(postId);

      DocumentSnapshot docSnapshot = await userRef.get();
      if (!docSnapshot.exists) {
        return false;
      }
      Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;
      int currentFavoriteCount = data['favoriteCount'] ?? 0;

      if(isLiked){
        //いいねがはずされたらfalse返す
        userRef.update({
          'likes.${userAuth.currentUser!.uid}':false,
          'favoriteCount': currentFavoriteCount - 1,
        });
      }else{
        //いいねを押されたらlistにidを入れる
        userRef.update({
          'likes.${userAuth.currentUser!.uid}':true,
          'favoriteCount': currentFavoriteCount + 1,
        });
      }
      //新しい状態を返す
      return !isLiked;
    }catch(e){
      return false;
    }
  }

  //コメント用ダイアログ
  Future<bool> _showCommentDialog() async{
  return showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          title: Text("返信コメント"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                Form(
                  key: _formKey,
                  child: TextFormField(
                    decoration: InputDecoration(hintText: '入力して'),
                    onSaved: (String? value) {
                      _comment.description = value ?? '';
                    },
                    initialValue: _comment.description, // フォームの状態を保持
                  ),
                ),
                //フォーム中に写真が存在する場合
                if (_image != null)
                  Container(
                    // AlertDialogの幅の80%
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: Image.file( _image!,
                      // 画像を幅に合わせて拡縮
                      fit: BoxFit.cover,
                    ),
                  ),
                // ダイアログ中の写真入力用ボタン
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        await captureImage();
                        setState(() {}); // ダイアログ内の状態を更新するためにsetStateを呼び出す
                      },
                      child: Icon(Icons.add_a_photo),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        await getImageFromGallery();
                        setState(() {}); // ダイアログ内の状態を更新
                      },
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
                Navigator.of(context).pop(false);// キャンセルを返す
              },
            ),
            TextButton(
              child: Text("投稿"),
              onPressed: () {
                Navigator.of(context).pop(true); // 投稿を返す
              },
            ),
          ],
        );
      },
    ),
  ).then((value) => value ?? false);
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("タイムライン"),
        centerTitle: true,
      ),
      //設定用のdrawer
      drawer: CustomDrawer(),
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
                          padding: const EdgeInsets.symmetric(
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
                                          shape: CircleBorder(), padding: EdgeInsets.all(7)
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
                                                Navigator.of(context).pop(false); // キャンセルを返す
                                              },
                                            ),
                                            TextButton(
                                              child: Text("削除"),
                                              onPressed: () {
                                                Navigator.of(context).pop(true); // 削除を返す
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
                                //投稿を押したらコメント欄に遷移する
                                onTap:(){
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => CommentPage(
                                        userid: postlist[index].postAccount,
                                        postid: postlist[index].postid!,
                                      ),
                                    ),
                                  );
                                }
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  //時間、いいね、コメント
                                  Row(
                                    children: [
                                      // 時間の表示
                                      Text(DateFormat('yyyy/M/dd h:mm').format(postlist[index].createdTime!)),
                                      SizedBox(width: 10),
                                      LikeButton(
                                        onTap: (isLiked) => onLikeButtonTapped(postlist[index].postAccount,postlist[index].postid!,isLiked),
                                        size: 30,
                                        likeCount: postlist[index].favoriteCount,
                                        isLiked: postlist[index].buttonPush, // 取得した「いいね」反映
                                      ),
                                      //コメント
                                      IconButton(
                                        icon: const Icon(Icons.comment),
                                        onPressed: () async {
                                          // コメントの入力フォームと画像をリセット
                                          setState(() {
                                            _comment.description = ''; // コメントの内容をリセット
                                            _image = null; // 画像をリセット
                                          });
                                          // コメント入力ダイアログを表示
                                          bool? confirm = await _showCommentDialog();
                                          if (confirm == true) {
                                            try {
                                              if (_formKey.currentState!.validate()) {
                                                _formKey.currentState!.save();
                                                await _upload(_mainReference, postlist[index].postAccount, postlist[index].postid); // 非同期でアップロードを待つ
                                                print('保存に成功しました');
                                              }
                                            } catch (e) {
                                              print('保存に失敗しました: $e');
                                            }
                                          }
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

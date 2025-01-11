import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:secure_sns/model/diary.dart';

import '../account/user_auth.dart';
import '../components/emotionlists.dart';

class Readingdiary extends StatefulWidget {
  final String userid;

  const Readingdiary({
    //このidの人の日記のみを表示する
    required this.userid,
    Key? key,
  }): super(key: key);

  @override
  State<Readingdiary> createState() => _ReadingdiaryState();
}

class _ReadingdiaryState extends State<Readingdiary> {
  List<Diary> diarylist= [];

  //日記を削除
  Future<void> _deleteDiary(String postId, int index) async {
    try {
      // Firestoreから削除
      await FirebaseFirestore.instance.collection('users')
          .doc(userAuth.currentUser!.uid).collection('posts')
          .doc(postId).delete();

      // ローカルリストから削除
      setState(() {
        diarylist.removeAt(index);
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

  Future<void> fetchDiaries() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userid)
          .collection('diaries')
          .get();

      List<Diary> loadedDiaries = [];

      snapshot.docs.forEach((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        loadedDiaries.add(
          Diary(
            diaryid: doc.id,
            diaryAccount: data['diaryAccount'] ?? '',
            description: data['description'] ?? '',
            createdDate: (data['createdTime'] as Timestamp).toDate(),
            emotion: data['emotion'] ?? '',
            emotionreason: data['emotionreason'] ?? '',
            imagePath: data['imagePath'] ?? '',
            place: data['place'] ?? '',

          ),
        );
      });
      setState(() {
        diarylist = loadedDiaries;
      });
    } catch (e) {
      print('Failed to fetch diaries: $e');
    }
  }

  // 感情に対応する imagePath を取得
  String? _getEmotionImagePath(String emotion) {
    try {
      final matchingItem = emotionItems.firstWhere((item) => item.name == emotion);
      return matchingItem.imagePath;
    } catch (e) {
      // 該当する感情が見つからなかった場合
      return null;
    }
  }


  @override
  void initState() {
    super.initState();
    fetchDiaries();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text("かんじょうにっき"),
        centerTitle: true,
      ),
      body: Center(
        child: ListView.builder(
            itemCount: diarylist.length,
            itemBuilder: (BuildContext context,int index){
              final imagePath = _getEmotionImagePath(diarylist[index].emotion)?? 'images/catface/anshin.png';
              print("imagePath:"+imagePath);
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
                              //時間
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 0),
                                child: Row(
                                  children: [
                                    // 時間の表示
                                    Text(
                                      DateFormat('yyyy/MM/dd').format(diarylist[index].createdDate),
                                      style: TextStyle(fontSize: 20),
                                    ),
                                    SizedBox(width: 10),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              //感情
                              Row(
                                children: [
                                  Image.asset(
                                      imagePath,
                                    width: screenWidth*0.1,
                                  ),
                                  SizedBox(width: screenWidth*0.01,),
                                  Text("${diarylist[index].emotion}",
                                    style:TextStyle(fontSize: screenHeight*0.03) ,),
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
                                      title: Text("日記を消す"),
                                      content:
                                      Text("本当に消しちゃう？"),
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
                                    _deleteDiary(diarylist[index].diaryAccount!, index);
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
                                Row(
                                  children: [
                                    Text("どこで: ",
                                      style: TextStyle(
                                          color: Colors.black54,
                                        fontSize: screenHeight*0.02
                                      ),),
                                    Text("${diarylist[index].place}",
                                      style: TextStyle(
                                          color: Colors.black87,
                                          fontSize: screenHeight*0.025
                                      ),)
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text("やったこと: ",
                                      style: TextStyle(
                                        color: Colors.black54,
                                        fontSize: screenHeight*0.02
                                    ),),
                                    Text("${diarylist[index].description}",
                                      style: TextStyle(
                                          color: Colors.black87,
                                          fontSize: screenHeight*0.025
                                      ),)
                                  ],
                                ),
                                SizedBox(height: screenHeight*0.01,),
                                //投稿内容
                                Text("どうしてそう感じたの？: ",style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: screenHeight*0.02
                                ),),
                                Text("${diarylist[index].emotionreason}"),
                                // 画像が存在する場合のみ表示
                                if (diarylist[index].imagePath!="imageurl")
                                  Image.network(diarylist[index].imagePath),
                              ]
                            ),

                          ),

                        ],
                      ),
                    ),
                    Divider(),
                  ],
                ),
              );
            }
        ),
      ),
    );
  }
}

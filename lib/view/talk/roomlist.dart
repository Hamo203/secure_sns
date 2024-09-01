import 'package:flutter/material.dart';
import 'package:secure_sns/view/Chat1.dart';
import 'package:secure_sns/view/Chat2.dart';


class Roomlist extends StatefulWidget {
  const Roomlist({super.key});

  @override
  State<Roomlist> createState() => _RoomlistState();
}

class _RoomlistState extends State<Roomlist> {

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title:
        const Text('メッセージ',style: TextStyle(color:  Colors.black87,
            fontSize: 20,
            fontFamily: 'Inria Sans',
            fontWeight:FontWeight.bold,
            height: 0
        ),),
      ),
      body: Container(
        color:Colors.white,
        child: ListView(
          children: [
            InkWell(
              onTap: (){
                //チャット押したらページ遷移
                Navigator.of(context).push(MaterialPageRoute(builder: (context)=>Chat_1()));
              },
              child:  Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: ListTile(
                      //アイコン画像
                      leading: CircleAvatar(radius: 30,),
                      // ユーザ名
                      title: Text('Chat 1',style: TextStyle(
                          color: Colors.black,fontWeight: FontWeight.normal
                      ),),
                      //会話の一部
                      subtitle: Text('test'),
                    ),
                  ),
                ],
              ),
            ),
            InkWell(
              onTap: (){
                //チャット押したらページ遷移
                Navigator.of(context).push(MaterialPageRoute(builder: (context)=>Chat_2()));
              },
              child:  Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: ListTile(
                      //アイコン画像
                      leading: CircleAvatar(radius: 30,backgroundColor: Colors.orangeAccent,),
                      //ユーザ名
                      title: Text('Chat 2',style: TextStyle(
                          color: Colors.black,fontWeight: FontWeight.normal
                      )),
                      //会話の一部
                      subtitle: Text("test2"),

                    ),
                  ),
                  Divider(color: Colors.white,)
                ],
              ),
            )
          ],
        ),
      ),
    );
  }


}

/*
/*
      appBar: AppBar(
        title: Text("message"),
        actions: !search
            ?[
          IconButton(
              onPressed: (){
                setState(() {
                  //ボタン押されたらUIを更新する
                  search =true;
                });
              },
              //falseだったら虫眼鏡マーク
              icon: Icon(Icons.search)
          )
        ] : [
          IconButton(
              onPressed: (){
                setState(() {
                  //ボタン押されたらUIを更新する
                  search =false;
                });
              },
              //trueだったら×マーク
              icon: Icon(Icons.clear)
          )
        ],
      ),
      body: _defaultListView(),
    );*/
* */
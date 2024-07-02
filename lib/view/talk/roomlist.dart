import 'package:flutter/material.dart';

import '../../model/account.dart';

class Roomlist extends StatefulWidget {
  const Roomlist({super.key});

  @override
  State<Roomlist> createState() => _RoomlistState();
}

class _RoomlistState extends State<Roomlist> {

  List<String> user_name_list =["u1","u2","u3"];

  bool search =false;

  Widget _defaultListView(){
    return ListView.builder(
      itemCount: user_name_list.length,
      itemBuilder: (countext, index){

      });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
    );
  }
}

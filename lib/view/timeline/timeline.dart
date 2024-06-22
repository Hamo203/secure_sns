import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../model/account.dart';
import '../../model/post.dart';

class Timeline extends StatefulWidget {
  const Timeline({super.key});

  @override
  State<Timeline> createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {

  Account account =new Account(
      username:'hamo235',
      name: 'hamo',
      id:'1',
      createdDate:DateTime.now()
  );

  List<Post> postlist=[Post(
    id:'1',
    discription :'目が疲れた',
    createdTime :DateTime.now(),
    postAccount:'1',
    buttonPush: false,
  )];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("タイムライン"),
        centerTitle: true,
      ),
      body: Center(
        child: ListView.builder(
            itemCount: postlist.length,
            itemBuilder: (BuildContext context,int index){
              return Container(
                  child:Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children:[
                          CircleAvatar(
                            radius:30,
                          ),
                          Text(account.name),
                        ]
                      ),
                      Image.asset('images/testcat.jpg'),
                      ElevatedButton(
                          onPressed: (){
                            setState((){

                              postlist[index].buttonPush = !(postlist[index].buttonPush);
                              print(postlist[index].buttonPush);
                            });
                          },
                          child: Text(""),
                            style: ElevatedButton.styleFrom(
                            shape: StadiumBorder(),
                              backgroundColor: postlist[index].buttonPush ? Colors.white : Colors.red, // ボタンの背景色を動的に変更

                          ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 20,vertical: 5),
                          child: Column(
                            children: [
                              Text(postlist[index].discription,),
                              Text(DateFormat('yyyy/M/dd h:m').format(postlist[index].createdTime!)),
                            ],
                          )),

                    ]
                  ),


              );


            }
        ),
      ),
    );
  }
}

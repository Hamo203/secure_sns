import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../model/account.dart';
import '../../model/post.dart';
import 'package:like_button/like_button.dart';

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
  ),
    Post(
      id:'2',
      discription :'腰が疲れた',
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
                      LikeButton(
                          size: 40,
                          likeCount: 0,
                          isLiked: postlist[index].buttonPush),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 20,vertical: 5),
                          child: Column(
                            children: [
                              Text(DateFormat('yyyy/M/dd h:mm').format(postlist[index].createdTime!)),
                              Text(postlist[index].discription,),

                            ],
                          )
                      ),
                      SizedBox(height: 10,)
                    ],

                  ),



              );


            }
        ),
      ),
    );
  }
}

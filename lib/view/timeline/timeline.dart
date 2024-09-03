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
      userid:'1',
      createdDate:DateTime.now()
  );

  List<Post> postlist=[Post(
    postid:'1',
    description :'目が疲れた',
    createdTime :DateTime.now(),
    postAccount:'1',
    buttonPush: false,
    favoriteCount: 0,
    retweetCount: 0
  ),
    Post(
      postid:'2',
      description :'腰が疲れた',
      createdTime :DateTime.now(),
      postAccount:'1',
      buttonPush: false,
        favoriteCount: 0,
        retweetCount: 0
    )];


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text("タイムライン"),
        centerTitle: true,
      ),
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            DrawerHeader(
              child: Text('Drawer Header'),
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
            ),
            ListTile(
              title: Text('Item 1'),
              onTap: () {
                // Do something
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Item 2'),
              onTap: () {
                // Do something
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: ListView.builder(
            itemCount: postlist.length,
            itemBuilder: (BuildContext context,int index){
              return Container(
                  child:Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children:[
                            Row(
                              children: [
                                CircleAvatar(
                                  radius:30
                                ),
                                SizedBox(width: 10,),
                                Text(account.name),
                              ],

                            ),
                            OutlinedButton(
                                onPressed: (){},
                                child: Text("フォロー"),
                            )

                          ]
                        ),
                      ),
                      Image.asset('images/testcat.jpg'),
                      LikeButton(
                          size: 40,
                          likeCount: 0,
                          isLiked: postlist[index].buttonPush),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 20,vertical: 5),
                          color: Colors.white,
                          child: Column(
                            children: [
                              Text(DateFormat('yyyy/M/dd h:mm').format(postlist[index].createdTime!)),
                              Text(postlist[index].description,),
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

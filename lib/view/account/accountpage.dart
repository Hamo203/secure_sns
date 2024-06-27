import 'package:flutter/material.dart';

import '../../model/post.dart';

class Accountpage extends StatefulWidget {
  const Accountpage({super.key});

  @override
  State<Accountpage> createState() => _AccountpageState();
}

class _AccountpageState extends State<Accountpage> {

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
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height:200,
                margin: EdgeInsets.all(5),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.yellow)
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                        radius:40
                    ),
                    Column(
                      children: [
                        Text("I am profile!"),
                        Text("永遠の 10 さい!"),
                        Text("好きなもの --> マイメロ♡"),
                        Text("好きな食べ物 --> かば焼きさん太郎しか勝たん!"),
                        Text("ずっ友だぉ✨"),
                        OutlinedButton(
                            onPressed: (){}, child: Text('編集')),
                      ],
                    ),
              
                  ],
                ),
                
              ),
              ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: postlist.length,
                  shrinkWrap: true,
                  itemBuilder: (BuildContext context, int index){
                    return Text("test");
                  }
                  ),

            ],
          ),
        ),
      ),

    );
  }
}

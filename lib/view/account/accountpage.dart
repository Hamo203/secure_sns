import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../model/account.dart';
import '../../model/post.dart';
import 'package:like_button/like_button.dart';

class Accountpage extends StatefulWidget {
  const Accountpage({super.key});

  @override
  State<Accountpage> createState() => _AccountpageState();
}

class _AccountpageState extends State<Accountpage> {
  Account account = new Account(
    username: 'hamo235',
    name: 'hamo',
    userid: '1',
    createdDate: DateTime.now(),
  );

  List<Post> postlist = [
    Post(
      postid: '1',
      description: '目が疲れた',
      createdTime: DateTime.now(),
      postAccount: '1',
      buttonPush: false,
        favoriteCount: 0,
        retweetCount: 0
    ),
    Post(
      postid: '2',
      description: '腰が疲れた',
      createdTime: DateTime.now(),
      postAccount: '1',
      buttonPush: false,
        favoriteCount: 0,
        retweetCount: 0
    )
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                margin: EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Colors.pink[50],
                  border: Border.all(color: Colors.pinkAccent),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Stack(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundImage: AssetImage('images/profile_picture.jpg'), // Add a profile picture
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "profile!",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.pink,
                                ),
                              ),
                              Text(
                                "07 sjk",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.pinkAccent,
                                ),
                              ),
                              Text(
                                "好きなもの --> マイメロ♡",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.pinkAccent,
                                ),
                              ),
                              Text(
                                "好きな食べ物 --> かば焼き",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.pinkAccent,
                                ),
                              ),
                              Text(
                                "ずっ友",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.pinkAccent,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.pinkAccent),
                        ),
                        child: Text(
                          '編集',
                          style: TextStyle(color: Colors.pinkAccent),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: postlist.length,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(radius: 30),
                                  SizedBox(width: 8),
                                  Text(account.name),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Image.asset('images/testcat.jpg'),
                        LikeButton(
                          size: 40,
                          likeCount: 0,
                          isLiked: postlist[index].buttonPush,
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 5,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(DateFormat('yyyy/M/dd h:mm').format(postlist[index].createdTime!)),
                              Text(postlist[index].description),
                            ],
                          ),
                        ),
                        SizedBox(height: 10),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:curved_labeled_navigation_bar/curved_navigation_bar.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar_item.dart';
import 'package:flutter/material.dart';
import 'package:secure_sns/view/account/accountpage.dart';
import 'package:secure_sns/view/timeline/postpage.dart';
import 'package:secure_sns/view/timeline/timeline.dart';

class Navigation extends StatefulWidget {
  const Navigation({super.key});

  @override
  State<Navigation> createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  int selectedIndex=0;
  List<Widget> pagelist =[Timeline(),Postpage(),Accountpage()];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:pagelist[selectedIndex],
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.blueAccent,
        items: [
          CurvedNavigationBarItem(
            child: Icon(Icons.home_outlined),
            label: 'Timeline',
          ),
          CurvedNavigationBarItem(
            child: Icon(Icons.chat_bubble_outline),
            label: 'Chat',
          ),
          /*
          CurvedNavigationBarItem(
            child: Icon(Icons.search),
            label: 'Search',
          ),
          CurvedNavigationBarItem(
            child: Icon(Icons.newspaper),
            label: 'Feed',
          ),*/
          CurvedNavigationBarItem(
            child: Icon(Icons.perm_identity),
            label: 'Personal',
          ),
        ],

        onTap: (index) {
          setState(() {
            selectedIndex=index;
          });
          // Handle button tap
        },
      ),

    );
  }
}

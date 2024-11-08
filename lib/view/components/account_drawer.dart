import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../startup/login.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});
  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}
class _CustomDrawerState extends State<CustomDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: <Widget>[
          const SizedBox(
            height: 80,
            child: DrawerHeader(
              child: Text('設定とアクティビティ'),
              decoration: BoxDecoration(
                color:  Color(0xFFC5D8E7),
              ),
            ),
          ),
          ListTile(
            title: Text('アカウント情報'),
            onTap: () {
              // Do something
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: Text('ログアウト'),
            onTap: () async {
              // Do something
              bool? confirm = await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text("ログアウト"),
                  content:
                  Text("ログアウトしてもよろしいですか？"),
                  actions: [
                    TextButton(
                      child: Text("キャンセル"),
                      onPressed: () {
                        Navigator.of(context).pop(false); // キャンセルを返す
                      },
                    ),
                    TextButton(
                      child: Text("はい"),
                      onPressed: () {
                        Navigator.of(context).pop(true); // 削除を返す
                      },
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                FirebaseAuth.instance.signOut();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => Login()), (_) => false,
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

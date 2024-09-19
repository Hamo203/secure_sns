import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class CommentPage extends StatefulWidget {
  final String userid;
  final String postid;

  const CommentPage({Key? key, required this.userid, required this.postid}) : super(key: key);

  @override
  _CommentPageState createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {
  final TextEditingController _commentController = TextEditingController();
  File? _image;
  final ImagePicker picker = ImagePicker();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future captureImage() async {
    final XFile? photo = await picker.pickImage(source: ImageSource.camera);
    if (photo == null) {
      print('No image selected');
      return;
    }

    setState(() {
      _image = File(photo.path);
    });
  }

  Future getImageFromGallery() async {
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) {
      print('No image selected');
      return;
    }

    setState(() {
      _image = File(image.path);
    });
  }

  Future<void> _uploadComment(String description) async {
    try {
      FirebaseStorage storage = FirebaseStorage.instance;
      String imageUrl = "imageurl"; // デフォルトのURL

      // 画像が選択されている場合は画像をアップロード
      /*if (_image != null) {
        TaskSnapshot snapshot = await storage
            .ref("users/${widget.userid}/posts/${widget.postid}/comments/${DateTime.now().millisecondsSinceEpoch}.png")
            .putFile(_image!);
        imageUrl = await snapshot.ref.getDownloadURL();
      }*/

      // コメントをFirestoreに保存
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userid)
          .collection('posts')
          .doc(widget.postid)
          .collection('comments')
          .add({
        'description': description,
        'imagePath': imageUrl,
        'createdTime': DateTime.now(),
      });

      setState(() {
        _commentController.clear();
        _image = null;
      });

      print("コメントが保存されました");
    } catch (e) {
      print('コメントの保存中にエラーが発生しました: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchComments() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userid)
          .collection('posts')
          .doc(widget.postid)
          .collection('comments')
          .orderBy('createdTime', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      print('コメントの取得中にエラーが発生しました: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("コメント一覧"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: fetchComments(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError || !snapshot.hasData) {
                  return Center(child: Text('エラーが発生しました'));
                }

                final comments = snapshot.data ?? [];

                return ListView.builder(
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    final comment = comments[index];
                    return ListTile(
                      leading: comment['imagePath'] != 'imageurl'
                          ? Image.network(comment['imagePath'], width: 50, height: 50, fit: BoxFit.cover)
                          : null,
                      title: Text(comment['description'] ?? ''),
                      subtitle: Text(DateFormat('yyyy/MM/dd HH:mm').format(comment['createdTime'].toDate())),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: 'コメントを入力',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'コメントを入力してください';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 10),
                  if (_image != null)
                    Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: Image.file(_image!, fit: BoxFit.cover),
                    ),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: captureImage,
                        child: Icon(Icons.add_a_photo),
                      ),
                      ElevatedButton(
                        onPressed: getImageFromGallery,
                        child: Icon(Icons.photo_library),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _uploadComment(_commentController.text);
                      }
                    },
                    child: Text("コメントを投稿"),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

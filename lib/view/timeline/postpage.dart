import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class Postpage extends StatefulWidget {
  const Postpage({super.key});

  @override
  State<Postpage> createState() => _PostpageState();
}

class _PostpageState extends State<Postpage> {
  File? _image ;
  final ImagePicker picker = ImagePicker();

  Future captureImage() async {
    // Capture a photo.
    final XFile? photo = await picker.pickImage(source: ImageSource.camera);
    setState(() {
      _image = File(photo!.path);
    });
  }

  Future getImageFromGallery() async{
    // Pick an image.
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = File(image!.path);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("新規投稿"),
        actions: <Widget>[
          IconButton(
              onPressed: (){},
              icon: Image.asset('images/OIP.jpg'),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 20,vertical: 5),
          child: Column(
            children: [
              TextField(
                decoration: InputDecoration(
                  hintText: '入力して'
                ),
              ),
              _image==null
              ? Text('No image selected')
              :Image.file(_image!),
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
              )
            ],
          ),
        ),
      ),
    );
  }
}


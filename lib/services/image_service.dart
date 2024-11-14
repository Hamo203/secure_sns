import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class ImageService{
  final ImagePicker _picker = ImagePicker();
  final FirebaseStorage _storage = FirebaseStorage.instance;

  //写真を取る
  Future captureImage() async {
    // Capture a photo.
    try {
      final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
      if (photo == null) {
        print('画像が選択されませんでした');
        return null;
      }
      return File(photo.path);
    } catch (e) {
      print('画像キャプチャ中にエラーが発生しました: $e');
      return null;
    }
  }

  //ギャラリーから写真を撮ってくる
  Future getImageFromGallery() async{
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) {
        print('画像が選択されませんでした');
        return null;
      }
      return File(image.path);
    } catch (e) {
      print('ギャラリーからの画像選択中にエラーが発生しました: $e');
      return null;
    }
  }

}
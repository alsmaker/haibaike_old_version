import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:image/image.dart' as img;

class FirebaseStorageManager {
  firebase_storage.UploadTask uploadProfileImage(String uid, String fileName, File file) {
    firebase_storage.Reference ref  = firebase_storage.FirebaseStorage.instance
        .ref()
        .child('users/$uid')
        .child('/$fileName.jpg');

    return ref.putFile(file);
  }

  Future<String> updateProfileImage(String uid, String fileName, File file) async{
    String downloadUrl;

    var image = img.decodeImage(File(file.path).readAsBytesSync());
    var width = image.width;
    var height = image.height;
    int baseSize = 200;
    var resizeImage;

    if (width < baseSize || height < baseSize) {
      print('small size image - no convert');
    }
    else if (width < height) {
      resizeImage = img.copyResize(image, height: baseSize);
    } else if (height < width) {
      resizeImage = img.copyResize(image, width: baseSize);
    } else {
      resizeImage = img.copyResize(image, width: baseSize, height: baseSize);
    }

    Uint8List resultImgData = img.encodeJpg(resizeImage);

    firebase_storage.Reference ref  = firebase_storage.FirebaseStorage.instance
        .ref()
        .child('users/$uid')
        .child('/$fileName.jpg');

    firebase_storage.UploadTask task = ref.putData(resultImgData);

    await task.whenComplete(() async {
      try {
        print('get download url');
        downloadUrl = await ref.getDownloadURL();
        print(downloadUrl);
      } catch (onError) {
        print('download url error');
      }
    });

    return downloadUrl;
  }
}
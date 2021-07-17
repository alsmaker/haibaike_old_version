import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hibaike/src/component/image_process.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:image/image.dart' as img;

class MultiImageController extends GetxController {
  //RxList<Uint8List> images = <Uint8List>[].obs;
  List<Uint8List> images = [];
  RxInt imageLength = 0.obs;
  List<Asset> assetList = [];

  Future getMultiImage(int maxCount) async {
    ImageProcess ip = ImageProcess();

    try {
      assetList = await MultiImagePicker.pickImages(
        //maxImages: 10 - imgFileList.length,
        maxImages: maxCount,
        enableCamera: false,
        selectedAssets: assetList,
        cupertinoOptions: CupertinoOptions(takePhotoIcon: "사진선택"),
        materialOptions: MaterialOptions(
          actionBarColor: "#ff3333",
          actionBarTitle: "사진선택",
          allViewTitle: "전체보기",
          useDetailsView: true,
          selectCircleStrokeColor: "#ffffff",
        ),
      );
    } catch (e) {
      ip.hasError();
      ip.setError(e.toString());
    }

    imageLength(assetList.length);
    for(var i = 0 ; i < imageLength.value ; i++) {
      //images[i] = new Uint8List(0);
      images.add(new Uint8List(0));
      print('test');
    }
    // for(var i = 0 ; i < assetList.length ; i++) {
    //   var data = await assetList[i].getByteData();
    //   Uint8List image = data.buffer.asUint8List();
    //
    //   images.add(image);
    // }
  }

  Future<String> loadImageData(index) async {
    var data = await assetList[index].getByteData();
    Uint8List image = data.buffer.asUint8List();

    images[index] = image;

    return 'done';
  }

  void removeAtImg(int index) {
    //imgFileList.removeAt(index);
    images.removeAt(index);
    assetList.removeAt(index);
    imageLength--;
  }

  void reset() {
    images.clear();
  }

  Future<List<String>> shopImagesToStorage(String folderName) async {
    List<String> imageList = [];

    print('shop images to firebase storage');

    for (var i = 0; i < images.length; i++) {
      if (images[i] != null) {
        // 0. time stamp를 가져와서 파일명의 마지막에 붙여주는 역할
        var fileTimeStamp = DateTime.now().millisecondsSinceEpoch;
        // 1. storage reference 만들기
        firebase_storage.Reference ref = firebase_storage
            .FirebaseStorage.instance
            .ref()
            .child('shops')
            .child(folderName)
            .child(fileTimeStamp.toString() + '.jpg');

        // 2.
        //File adjustImg = await adjustImages(imgCtrl.imgFileList[i]);
        Uint8List adjustImg = await adjustImagesData(images[i]);

        // 2. storage 에 업로드
        //firebase_storage.UploadTask uploadTask = ref.putFile(adjustImg);
        final metadata =
            firebase_storage.SettableMetadata(contentType: 'image/jpeg');
        firebase_storage.UploadTask uploadTask =
            ref.putData(adjustImg, metadata);

        String downloadURL;
        // 3. 등록된 이미지의 url 을 따와서 리스트로 저장
        await uploadTask.whenComplete(() async {
          try {
            print('get download url');
            downloadURL = await ref.getDownloadURL();
            imageList.add(downloadURL);
            print(downloadURL);
          } catch (onError) {
            print('download url error');
          }
        });
      }
    }
    return imageList;
  }

  Future<Uint8List> adjustImagesData(Uint8List imgData) async {
    var width, height;
    var decodedImage;
    int newWidth, newHeight;

    decodedImage = img.decodeImage(
        imgData);
    width = decodedImage.width;
    height = decodedImage.height;
    print('selected image with = $width & height = $height');

    if (width < 640 || height < 640) {
      newWidth = width;
      newHeight = height;
    }
    else if (width < height) {
      var ratio2 = (width / height).toStringAsFixed(3);
      var newValue2 = 640 * double.parse(ratio2);
      newWidth = newValue2.toInt();
      newHeight = 640;
    } else if (height < width) {
      var ratio2 = (height / width).toStringAsFixed(3);
      var newValue2 = 640 * double.parse(ratio2);
      newWidth = 640;
      newHeight = newValue2.toInt();
    } else {
      newWidth = 640;
      newHeight = 640;
    }

    img.Image timage = img.copyResize(
        decodedImage, width: newWidth, height: newHeight);

    Uint8List resultImgData = img.encodeJpg(timage);
    return resultImgData;
  }
}
/*
Future<void> adjustImages(List<Uint8List> images) async {
  List<Uint8List> resultImg = [];

  for(var i=0 ; i<images.length ; i++) {
    var width, height;
    var newWidth, newHeight;
    var tImage = decodeImage(images[i]);

    if(Platform.isAndroid) {
      width = tImage.width;
      height = tImage.height;
    } else {
      // todo : ios implement
    }
    print('selected image with = $width & height = $height');

    if(width<640 || height<640) {
      // no need to resize
      newWidth = width;
      newHeight = height;
    }
    else if(width < height) {
      var ratio2 = (width / height).toStringAsFixed(3);
      var newValue2 = 640 * double.parse(ratio2);
      newWidth = newValue2.toInt();
      newHeight = 640;
    }
    else if (height < width) {
      var ratio2 = (height / width).toStringAsFixed(3);
      var newValue2 = 640 * double.parse(ratio2);
      newWidth = 640;
      newHeight = newValue2.toInt();
    }
    else {
      newWidth = 640;
      newHeight = 640;
    }

    var result = await FlutterImageCompress.compressWithList(
        images[i], minWidth: newWidth, minHeight: newHeight, quality: 88);
    resultImg.add(result);
  }
  return resultImg;
}

 */
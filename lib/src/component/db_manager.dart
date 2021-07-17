import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:get/get.dart';
import 'package:hibaike/src/controller/bike_data_controller.dart';
import 'package:hibaike/src/controller/multi_image_controller.dart';
import 'package:hibaike/src/model/bike.dart';
import 'package:hibaike/src/model/users.dart';
import 'package:image/image.dart' as img;

class DBManager {
  final BikeDataController dataCtrl = Get.find();
  final MultiImageController imgCtrl = Get.find();
  CollectionReference ref = FirebaseFirestore.instance.collection('bikes');
  CollectionReference userRef = FirebaseFirestore.instance.collection('users');
  //DateTime now = DateTime.now();
  //String bikeDataId = 'bike-${now.millisecondsSinceEpoch.toString()}';

  Future<List<String>> storeImageList(DateTime now) async {
    List<String> imageList = [];

    print('image save start');

    //for (var i = 0; i < imgCtrl.imgFileList.length; i++) {
    for (var i = 0; i < imgCtrl.images.length; i++) {
      //if (imgCtrl.imgFileList[i] != null) {
      if (imgCtrl.images[i] != null) {
        // 0. timestamp를 가져와서 파일명의 마지막에 붙여주는 역할
        var fileTimeStamp = DateTime
            .now()
            .millisecondsSinceEpoch;
        // 1. storage reference 만들기
        firebase_storage.Reference ref = firebase_storage.FirebaseStorage
            .instance
            .ref()
            .child('bikeImage')
            .child('bike-${now.millisecondsSinceEpoch}')
            .child(fileTimeStamp.toString() + '.jpg');

        // 2.
        //File adjustImg = await adjustImages(imgCtrl.imgFileList[i]);
        Uint8List adjustImg = await adjustImagesData(imgCtrl.images[i]);

        // 2. storage 에 업로드
        //firebase_storage.UploadTask uploadTask = ref.putFile(adjustImg);
        final metadata = firebase_storage.SettableMetadata(
            contentType: 'image/jpeg'
        );
        firebase_storage.UploadTask uploadTask = ref.putData(
            adjustImg, metadata);


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

  Future updateImageList(List<String> diff, String storageId) async {
    List<String> result;

    // todo 1 :  diff 리스트의 이미지 삭제
    if(diff.length > 0) {
      diff.forEach((url) {
        firebase_storage.FirebaseStorage.instance.refFromURL(url).delete();
        // FirebaseFirestore.instance.collection('bikes').doc(storageId).update(
        // {
        //   'imageList': FieldValue.arrayRemove([url])
        // });
      });
    }

    // todo 2 : multiImageController 이미지 추가
    for (var i = 0; i < imgCtrl.images.length; i++) {
      //if (imgCtrl.imgFileList[i] != null) {
      if (imgCtrl.images[i] != null) {
        // 0. timestamp를 가져와서 파일명의 마지막에 붙여주는 역할
        var fileTimeStamp = DateTime
            .now()
            .millisecondsSinceEpoch;
        // 1. storage reference 만들기
        firebase_storage.Reference ref = firebase_storage.FirebaseStorage
            .instance
            .ref()
            .child('bikeImage')
            .child(storageId)
            .child(fileTimeStamp.toString() + '.jpg');

        // 2.
        //File adjustImg = await adjustImages(imgCtrl.imgFileList[i]);
        Uint8List adjustImg = await adjustImagesData(imgCtrl.images[i]);

        // 2. storage 에 업로드
        //firebase_storage.UploadTask uploadTask = ref.putFile(adjustImg);
        final metadata = firebase_storage.SettableMetadata(
            contentType: 'image/jpeg'
        );
        firebase_storage.UploadTask uploadTask = ref.putData(
            adjustImg, metadata);

        String downloadURL;
        // todo 3 : updateImageList 정리
        await uploadTask.whenComplete(() async {
          try {
            print('get download url');
            downloadURL = await ref.getDownloadURL();
            dataCtrl.updateImageList.add(downloadURL);
            print(downloadURL);
          } catch (onError) {
            print('download url error');
          }
        });
      }
    }
    //return result;
  }

  Future storeBikeData(List<String> imageList, DateTime now) async {

      print('firebase database input start');
      ref.doc('bike-${now.millisecondsSinceEpoch}').set(BikeData(
          key: 'bike-${now.millisecondsSinceEpoch}',
          manufacturer: dataCtrl.manufacturer.value,
          model: dataCtrl.model.value,
          displacement: dataCtrl.displacement.value,
          birthYear: int.parse(dataCtrl.birthYear),
          mileage: int.parse(dataCtrl.mileage),
          amount: int.parse(dataCtrl.amount),
          locationLevel0: dataCtrl.locationLevel0.value,
          locationLevel1: dataCtrl.locationLevel1.value,
          locationLevel2: dataCtrl.locationLevel2.value,
          location: dataCtrl.location,
          gearType: dataCtrl.gearType.value,
          fuelType: dataCtrl.fuelType.value,
          isTuned: dataCtrl.isTuned.value,
          possibleAS: dataCtrl.possibleAS.value,
          comment: dataCtrl.comment,
          imageList: imageList,
          createdTime: now.toIso8601String(),
          createdTimeMilliseconds: now.millisecondsSinceEpoch,
          ownerUid: dataCtrl.ownerUid,
      ).toJson());

    return 'regist done!!';
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

  Future<Users> getUserInfoByUid (String uid) async{
    DocumentSnapshot snapshot = await userRef.doc(uid).get();
    return Users.fromJson(snapshot.data());
  }
}
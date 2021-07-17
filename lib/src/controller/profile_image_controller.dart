import 'dart:io';

import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class ProfileImageController extends GetxController {
  static ProfileImageController get to => Get.find();

  Future<File> selectImage () async{
    PickedFile pickedFile = await ImagePicker().getImage(source: ImageSource.gallery);

    return File(pickedFile.path);
  }
}
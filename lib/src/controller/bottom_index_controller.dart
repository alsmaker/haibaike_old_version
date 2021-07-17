import 'package:get/get.dart';

class BottomIndexController extends GetxController {
  static BottomIndexController get to => Get.find();
  RxInt currentIndex = 0.obs;

  void changePageIndex(int index) {
    currentIndex(index);
  }
}
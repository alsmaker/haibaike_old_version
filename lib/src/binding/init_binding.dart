import 'package:get/get.dart';
import 'package:hibaike/src/controller/bottom_index_controller.dart';
import 'package:hibaike/src/controller/sign_controller.dart';

class InitBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(SignController());
    Get.put(BottomIndexController());
  }
}
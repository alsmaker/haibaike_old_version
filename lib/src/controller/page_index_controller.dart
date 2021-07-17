import 'package:get/get.dart';
class PageIndexController extends GetxController{
  RxInt index = 0.obs;

  void chageIndex(int index){
    this.index.value = index;
  }
}
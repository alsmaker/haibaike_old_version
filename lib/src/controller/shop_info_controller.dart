import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:hibaike/src/controller/multi_image_controller.dart';
import 'package:hibaike/src/controller/sign_controller.dart';
import 'package:hibaike/src/model/shop_data.dart';

class ShopInfoController extends GetxController {
  RxString shopName = ''.obs;
  RxString address = ''.obs;
  RxString roadAddress = ''.obs;
  RxString addressDetail = ''.obs;
  ShopLocation shopLocation = ShopLocation();
  RxString contact = ''.obs;
  bool isOpenPhoneNumber;
  RxString oilType = ''.obs;
  RxString diagnosticDevice = ''.obs;
  RxInt numOfLift = 0.obs;
  RxString comment = ''.obs;

  ShopData shopData;
  SignController signController = Get.find();
  MultiImageController multiImageController = Get.find();

  String owner;

  // for update
  RxList<String> updateImageList = <String>[].obs;

  @override
  void onInit() {
    owner = signController.currentUser.value.uid;
    super.onInit();
  }

  void setShopName(String shopName) {
    this.shopName.value = shopName;
  }

  void setContact(String contact) {
    this.contact.value = contact;
  }
  void setOilType(String oilType) {
    this.oilType.value = oilType;
  }

  void setDiagnosticDevice(String diagnosticDevice) {
    this.diagnosticDevice.value = diagnosticDevice;
  }

  void setComment(String comment) {
    this.comment.value = comment;
  }

  void setLocation(String address, String roadAddress, double lat, double lng) {
    this.address.value = address;
    this.roadAddress.value = roadAddress;

    this.shopLocation.lat = lat;
    this.shopLocation.lon = lng;

  }

  void reset() {

  }

  void registerShopInfoToFireStore(List<String> imageList, String folderName) {
    print('shop info to firestore database');
    FirebaseFirestore.instance.collection('shops').doc(folderName).set(ShopData(
      owner: owner,
      shopName: shopName.value,
      address: address.value,
      roadAddress: roadAddress.value,
      addressDetail: addressDetail.value,
      shopLocation: shopLocation,
      contact: contact.value,
      isOpenPhoneNumber: isOpenPhoneNumber,
      oilType: oilType.value,
      diagnosticDevice: diagnosticDevice.value,
      comment: comment.value,
      imageList: imageList
    ).toJson());
  }

  void updateShopInfoToFireStore(List<String> imageList, String folderName) {
    print('update shop info to firestore database');
    FirebaseFirestore.instance.collection('shops').doc(folderName).update(ShopData(
        owner: owner,
        shopName: shopName.value,
        address: address.value,
        roadAddress: roadAddress.value,
        addressDetail: addressDetail.value,
        shopLocation: shopLocation,
        contact: contact.value,
        isOpenPhoneNumber: isOpenPhoneNumber,
        oilType: oilType.value,
        diagnosticDevice: diagnosticDevice.value,
        comment: comment.value,
        imageList: imageList
    ).toJson());
  }
}
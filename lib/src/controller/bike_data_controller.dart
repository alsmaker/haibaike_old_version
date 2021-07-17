import 'package:get/get.dart';
import 'package:hibaike/src/controller/sign_controller.dart';
import 'package:hibaike/src/model/bike.dart';

class BikeDataController extends GetxController {
  RxString manufacturer = ''.obs;
  RxString model = ''.obs;
  RxInt displacement = 0.obs;

  String birthYear;
  String mileage;
  String amount;

  RxString locationLevel0 = ''.obs;
  RxString locationLevel1 = ''.obs;
  RxString locationLevel2 = ''.obs;

  Location location = Location();

  RxString gearType = 'AUTO'.obs;
  RxString fuelType = 'GASOLINE'.obs;
  RxString isTuned = 'NO_TUNED'.obs;
  RxString possibleAS = 'IMPOSSIBLE'.obs;

  List<String> tuneFieldLabel = ['있음', '없음'];
  List<String> tuneFieldValue = ['TUNED', 'NO_TUNED'];

  String comment;

  String ownerUid;

  // List for update
  RxList<String> updateImageList = <String>[].obs;
  String updateKey;
  String createdTime;

  @override
  void onInit() {
    SignController signController = Get.find();
    ownerUid = signController.currentUser.value.uid;

    super.onInit();
  }

  void setModel(String company, String model, int displacement) {
    this.manufacturer(company);
    this.model(model);
    this.displacement(displacement);

    //update();
  }

  void setLocation(String level0, String level1, String level2, lat, lng) {
    this.locationLevel0(level0);
    this.locationLevel1(level1);
    this.locationLevel2(level2);

    print('set location lat = $lat, lng = $lng');
    this.location.lat = lat;
    this.location.lon = lng;
  }

  void setBirthYear(String birthYear) {
    print('in birthyear controller func + $birthYear');
    this.birthYear = birthYear;

    //update();
  }

  void setMilage(String milage) {

    print('in mileage controller func + $milage');
    this.mileage = milage.replaceAll(',', '');

    //update();
  }

  void setAmount(String amount) {
    print('in amount controller func + $amount');
    this.amount = amount.replaceAll(',', '');

    //update();
  }

  void setComment(String comment) {
    this.comment = comment;

    //update();
  }

  void reset() {
    manufacturer.value = '';
    model.value = '';
    displacement.value = 0;

    isTuned.value = 'NO_TUNED';
    possibleAS.value = 'IMPOSSIBLE';
  }
}
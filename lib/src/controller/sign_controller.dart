import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:hibaike/src/component/storage_manager.dart';
import 'package:hibaike/src/controller/bottom_index_controller.dart';
import 'package:hibaike/src/model/users.dart';
import 'package:sms_autofill/sms_autofill.dart';


class SignController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  CollectionReference ref = FirebaseFirestore.instance.collection('users');
  RxString _verificationId = ''.obs;
  RxBool isSignIn = false.obs;
  String USNumber;
  String KorNumber;
  String nickName;
  String uid;

  String smsCode = '';
  final SmsAutoFill _smsAutoFill = SmsAutoFill();

  RxBool enablePhoneNumberField = true.obs;
  RxBool enableStart = false.obs;
  RxBool enableRegister = false.obs;

  var _timer;
  RxInt timerSecond = 0.obs;

  // most important
  Rx<Users> currentUser = Users().obs;

  File profileImageFile;

  FirebaseStorageManager _firebaseStorageManager = FirebaseStorageManager();

  @override
  void onInit() {
    FirebaseAuth.instance.authStateChanges().listen((User user) {
      if(user == null) {
        print('User is currently sign out');
        isSignIn.value = false;
      }
      else {
        isSignIn.value = true;
        print(user.phoneNumber);
        print('User is signed in');
        bringUserDataByPhoneNum(user.phoneNumber);
      }
    });

    initializeSignCtrl();

    super.onInit();
  }

  void initializeSignCtrl() {
    USNumber = '';
    KorNumber = '';
    USNumber = '';

    enablePhoneNumberField(true);

    if(_timer != null) {
      _timer.cancel();
      _timer = null;
    }

    timerSecond.value = 0;

    profileImageFile = null;
  }

  bringUserDataByPhoneNum(String phoneNumber) async {
    QuerySnapshot snapshot = await ref.where('us_phone_number', isEqualTo: phoneNumber).get();

    if(snapshot.docs.length != 0)
      currentUser.value = Users.fromJson(snapshot.docs[0].data());
    else
      signOut();
  }

  reloadUserDataByUid() async{
    if(currentUser != null) {
      DocumentSnapshot snapshot = await ref.doc(currentUser.value.uid).get();

      if(snapshot.data().length == 0) {
        print('cannot reload : user data is not in database');
      }

      currentUser.value = Users.fromJson(snapshot.data());
    }
  }

  updateWatchList(String bikeKey) {
    bool isInWatchList = currentUser.value.watchList.contains(bikeKey);

    if(isInWatchList) {
      FirebaseFirestore.instance.collection('users').doc(
          currentUser.value.uid)
          .update({
        'watch_list': FieldValue.arrayRemove([bikeKey])
      });

      //currentUser.value.watchList.remove(bikeKey);
      reloadUserDataByUid();
    }
    else {
      FirebaseFirestore.instance.collection('users').doc(
          currentUser.value.uid)
          .update({
        'watch_list': FieldValue.arrayUnion([bikeKey])
      });
      //currentUser.value.watchList.add(bikeKey);
      reloadUserDataByUid();
    }
  }

  Future<void> updateUserGrade(String grade) async {
    await FirebaseFirestore.instance.collection('users').doc(currentUser.value.uid)
        .update({'grade': grade});

    reloadUserDataByUid();
  }

  Future<void> updateShopId(String shopId) async {
    await FirebaseFirestore.instance.collection('users').doc(currentUser.value.uid)
        .update({'shop_id': shopId});

    reloadUserDataByUid();
  }

  Future<void> updateBikeList(String bikeId) async {
    await FirebaseFirestore.instance.collection('users').doc(
        currentUser.value.uid)
        .update({
      'bike_list': FieldValue.arrayUnion([bikeId])
    });

    reloadUserDataByUid();
  }

  Future<bool> checkNickNameInDatabase(String value) async {
    var snapshot = await ref.where("nickName", isEqualTo: value).get();

    print('nickname doc.size = ${snapshot.size}');

    if (snapshot.size == 1)
      return true;
    else if (snapshot.size == 0)
      return false;
    else {
      print('duplicate nick registered'); // size가 2이상이면 문제임
    }
  }

  Future<bool> checkIdInDatabase() async {
    var snapshot = await ref.where("us_phone_number", isEqualTo: USNumber).get();

    print('phone number(id) doc.size = ${snapshot.size}');

    if (snapshot.size == 1)
      return true;
    else if (snapshot.size == 0)
      return false;
    else {
      print('duplicate id registered'); // size가 2이상이면 문제임
    }
  }

  void _updateProfileImageUrl(String downloadUrl) {
    ref.doc(currentUser.value.uid).update({"profile_image_url": downloadUrl});
  }

  void registerUserToDatabase(){
    List<String> defaultWatchList = [''];
    ref.doc(uid).set(Users(
      USPhoneNumber: USNumber,
      KorPhoneNumber: KorNumber,
      nickName: nickName,
      grade: "individual",
      uid: uid,
      watchList: defaultWatchList,
    ).
    toJson());

    if(profileImageFile != null) {
      UploadTask task = _firebaseStorageManager.uploadProfileImage(
          uid, "profile", profileImageFile);
      task.snapshotEvents.listen((event) async{
        if(event.bytesTransferred == event.totalBytes) {
          String downloadUrl = await event.ref.getDownloadURL();
          _updateProfileImageUrl(downloadUrl);
        }
      });
    }
    else {
      _updateProfileImageUrl('');
    }
  }

  Future<void> updateNickname(String nickname) async{
    print(nickname);
    await ref.doc(currentUser.value.uid).update({
      'nick_name': nickname
    });

    bringUserDataByPhoneNum(currentUser.value.USPhoneNumber);
  }

  Future<String> replaceProfileImage(File newImageFile) async {
    String downloadUrl;
    if(newImageFile != null) {
      // UploadTask task = _firebaseStorageManager.uploadProfileImage(
      //     currentUser.value.uid, "profile", newImageFile);
      // task.snapshotEvents.listen((event) async{
      //   if(event.bytesTransferred == event.totalBytes) {
      //     downloadUrl = await event.ref.getDownloadURL();
      //     _updateProfileImageUrl(downloadUrl);
      //     bringUserDataByPhoneNum(currentUser.value.USPhoneNumber);
      //   }
      // });
      downloadUrl = await _firebaseStorageManager.updateProfileImage(
              currentUser.value.uid, "profile", newImageFile);

      _updateProfileImageUrl(downloadUrl);
      bringUserDataByPhoneNum(currentUser.value.USPhoneNumber);
    }
    else {
      _updateProfileImageUrl('');
    }

    print('update profile image done');

    //return downloadUrl;
    return 'done';
  }

  Future<String> bringPhoneNum() async{
    USNumber = await _smsAutoFill.hint;
    if(USNumber != null && USNumber.length != 0)
      KorNumber = USNumber.replaceAll('+82', '0');
    return KorNumber;
  }

  void verifyPhoneNumber() async{
    // 폰번호를 직접 입력하는 경우에 대한 validate
    if(USNumber == null || USNumber.length == 0) {
      if(KorNumber.length != 0) {
        if(KorNumber.startsWith('0')) {
          USNumber = KorNumber.replaceFirst('0', '+82');
        }
      }
    }

    // 폰번호 입력창 & 휴대폰 번호로 인증하기 버튼 disable
    enablePhoneNumberField(false);

    PhoneVerificationCompleted verificationCompleted =
        (PhoneAuthCredential phoneAuthCredential) async {
          print('firebase auth verification completed');

          bool chkid = await checkIdInDatabase();
          // todo : 1. check phone number in database
          if(chkid) {
            print('ID is in database');
            signInWithPhoneNumber();
            BottomIndexController bottomIdxCtrl = Get.find();
            bottomIdxCtrl.changePageIndex(0);
            Future.delayed(Duration(milliseconds: 1000));
            _timer.cancel();
            timerSecond(0);
            Get.toNamed('/');
          }
          else {
            // 닉네임 입력 활성화
            print('ID is not in database');
            Future.delayed(Duration(milliseconds: 1000));
            _timer.cancel();
            timerSecond(0);
            Get.toNamed('/signUp/saveProfile');
          }
    };

    PhoneVerificationFailed verificationFailed =
        (FirebaseAuthException authException) {
          print("exception ${authException.message}");
      Fluttertoast.showToast(
        msg: '핸드폰 번호 인증이 실패하였습니다. 전화번호 확인후 다시 시도해 주세요',
        gravity: ToastGravity.BOTTOM,
      );
      initializeSignCtrl();
    };

    PhoneCodeSent codeSent =
        (String verificationId, [int forceResendingToken]) async {
      _verificationId(verificationId);
      print('firebase auth phone code sect : verification id : $_verificationId');
      bringSmsCode();
    };

    PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
        (String verificationId) {
      _verificationId(verificationId);
      Fluttertoast.showToast(
        msg: '인증시간이 초과되었습니다. 전화번호 입력후 다시 시도해 주세요',
        gravity: ToastGravity.BOTTOM,
      );
      initializeSignCtrl();
    };

    try {
      await _auth.verifyPhoneNumber(
          phoneNumber: USNumber,
          verificationCompleted: verificationCompleted,
          verificationFailed: verificationFailed,
          codeSent: codeSent,
          codeAutoRetrievalTimeout: codeAutoRetrievalTimeout);
    }
    catch(e) {
      print(e.toString());
      print(e.printError());
      Fluttertoast.showToast(msg: '2. 번호인증에 실패하였습니다');
    }
  }

  Future signInWithPhoneNumber() async{
    if(_verificationId != null) {
      try {
        final AuthCredential credential = PhoneAuthProvider.credential(
            verificationId: _verificationId.value,
            smsCode: smsCode);

        final User user = (await _auth.signInWithCredential(credential)).user;

        print('Successfully signed in UID : ${user.uid}');
        uid = user.uid;
      } catch (e) {
        print('Failed to sign in' + e.toString());
      }
    }
    else {
      Fluttertoast.showToast
        (msg: 'verification id 없음');
    }
  }

  void signOut() {
    _auth.signOut();
    enablePhoneNumberField(true);
    KorNumber = '';
  }

  void withDrawAccount() async {
    await _auth.currentUser.delete();
  }

  bringSmsCode() async {
    await SmsAutoFill().listenForCode;
    String signature = await SmsAutoFill().getAppSignature;

    print('bringSmsCode ' + signature);
  }

  void smsTimer() {

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if(timerSecond.value < 30)
        timerSecond.value++;
    });
  }
}
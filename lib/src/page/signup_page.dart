import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:hibaike/src/controller/bottom_index_controller.dart';
import 'package:hibaike/src/controller/sign_controller.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sms_autofill/sms_autofill.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final SignController signCtrl = Get.find();
  final TextEditingController _phoneNumCtrl = TextEditingController();

  @override
  void initState() {
    signCtrl.initializeSignCtrl();
    bringPhoneNumber();
    _phoneNumCtrl.addListener(() {
      signCtrl.KorNumber = _phoneNumCtrl.text;
    });
    super.initState();
  }

  bringPhoneNumber() async {
    _phoneNumCtrl.text = await signCtrl.bringPhoneNum();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('로그인', style: TextStyle(color: Colors.black),),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
          color: Colors.black, //change your color here
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Container(
            child: Column(
              children: [
                Obx(() =>
                    Container(
                    padding: EdgeInsets.only(left: 15),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(4)),
                        border: Border.all(color: Colors.black12)),
                    child: TextField(
                      controller: _phoneNumCtrl,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.done,
                      enabled:
                          signCtrl.enablePhoneNumberField.value ? true : false,
                      decoration: InputDecoration(
                          contentPadding: EdgeInsets.all(0),
                          border: InputBorder.none,
                          hintText: '전화번호입력'),
                    ),
                  ),
                ),
                SizedBox(height: 15,),
                  Obx(() =>
                    GestureDetector(
                    child: Container(
                      alignment: Alignment.center,
                      height: 50,
                      decoration: BoxDecoration(
                          color: signCtrl.enablePhoneNumberField.value
                              ? Colors.black
                              : Colors.black.withOpacity(0.3),
                          borderRadius: BorderRadius.all(Radius.circular(4))),
                      child: Text(
                        '휴대폰 번호로 인증하기',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                    onTap: () {
                      print('tab verify phone number');
                      if (signCtrl.enablePhoneNumberField.value == true) {
                        signCtrl.verifyPhoneNumber();
                        signCtrl.smsTimer();
                        signCtrl.enablePhoneNumberField(false);
                      }
                    },
                  ),
                ),
                SizedBox(height: 35,),
                Container(
                  padding: EdgeInsets.only(left: 15),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                      border: Border.all(color: Colors.black12)),
                  child: TextFieldPinAutoFill(
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.all(0),
                      border: InputBorder.none,
                      hintText: '인증번호입력',
                      counterText: '',

                    ),
                    //currentCode: signCtrl.USNumber,
                    // enbaled: ,
                    // prefill with a code
                    onCodeSubmitted: (code) {
                      print('code submitted');
                      print(code);
                      signCtrl.smsCode = code;
                    },
                    //code submitted callback
                    onCodeChanged: (code) {
                      print('code changed');
                      print(code);
                      signCtrl.smsCode = code;
                    },
                    //code changed callback
                    codeLength: 6,
                  ),
                ),
                SizedBox(height: 15,),
                Obx(() {
                  if(signCtrl.enablePhoneNumberField.value == false) {
                    return Container(
                      alignment: Alignment.centerRight,
                      child: Text('${signCtrl.timerSecond.value}/30'),
                    );
                  }
                  else
                    return Container();
                }),
                SizedBox(height: 15,),
                GestureDetector(
                  child:
                  //Obx(() =>
                      Container(
                    alignment: Alignment.center,
                    height: 50,
                    decoration: BoxDecoration(
                        color: signCtrl.enableStart.value ? Colors.red : Colors.red.withOpacity(0.5),
                        borderRadius: BorderRadius.all(Radius.circular(4))
                    ),
                    child: Text('동의하고 시작하기', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                  ),
                  //),
                  onTap: () {
                    if(signCtrl.enableStart.value)
                      signCtrl.signInWithPhoneNumber();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SignUpWithInfo extends StatefulWidget {
  @override
  _SignUpWithInfoState createState() => _SignUpWithInfoState();
}

class _SignUpWithInfoState extends State<SignUpWithInfo> {
  final TextEditingController _nickNameCtrl = TextEditingController();
  SignController signCtrl = Get.find();
  BottomIndexController idxCtrl = Get.find();

  @override
  void initState() {
    _nickNameCtrl.addListener(() {
      signCtrl.nickName = _nickNameCtrl.text;
    });
    super.initState();
  }

  Future<File> _cropImage(pickedFile) async {
    File croppedFile = await ImageCropper.cropImage(
        sourcePath: pickedFile.path,
        aspectRatioPresets: Platform.isAndroid
            ? [
          CropAspectRatioPreset.square,
          //CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.original,
          //CropAspectRatioPreset.ratio4x3,
          //CropAspectRatioPreset.ratio16x9
        ]
            : [
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.square,
          //CropAspectRatioPreset.ratio3x2,
          //CropAspectRatioPreset.ratio4x3,
          //CropAspectRatioPreset.ratio5x3,
          //CropAspectRatioPreset.ratio5x4,
          //CropAspectRatioPreset.ratio7x5,
          //CropAspectRatioPreset.ratio16x9
        ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: true),
        iosUiSettings: IOSUiSettings(
          title: 'Cropper',
        ));
    return croppedFile;
  }

  Future<File> selectImage() async {
    PickedFile pickedFile = await ImagePicker().getImage(source: ImageSource.gallery);

    if(pickedFile == null) return null;

    return await _cropImage(pickedFile);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('프로필등록'),),
      body: SingleChildScrollView(
        child: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.fromLTRB(15, 50, 15, 0),
          child: Column(
            //mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                child: Container(
                  width: 120,
                  height: 120,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15.0),
                    child: signCtrl.profileImageFile!=null ?
                        Image.file(signCtrl.profileImageFile)
                        :Image.network('https://i.stack.imgur.com/l60Hf.png',
                      fit: BoxFit.cover,),
                  ),
                ),
                onTap: () async {
                  signCtrl.profileImageFile = await selectImage();
                  setState(() {});
                },
              ),
              SizedBox(height: 40,),
              Row(children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.only(left: 15),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(4)),
                        border: Border.all(color: Colors.black12)),
                    child: TextField(
                      controller: _nickNameCtrl,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                          contentPadding: EdgeInsets.all(0),
                          border: InputBorder.none,
                          hintText: '닉네임'),
                    ),
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                GestureDetector(
                  child: Container(
                    alignment: Alignment.center,
                    height: 50,
                    width: 100,
                    decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.all(Radius.circular(4))),
                    child: Text(
                      '중복확인',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  onTap: () async {
                    // 데이터베이트 검색 & 중복확인
                    if((_nickNameCtrl.text != null) && (_nickNameCtrl.text.length !=0)) {
                      // textfield 입력 값이 있을 경우에만
                      print(_nickNameCtrl.text);
                      bool isExist = await signCtrl.checkNickNameInDatabase(_nickNameCtrl.text);
                      if(isExist){
                        Fluttertoast.showToast(msg: "동일한 닉네임이 있습니다. 다른 닉네임을 입력해주세요", gravity: ToastGravity.BOTTOM);
                        _nickNameCtrl.text = '';
                      }
                      else {
                        signCtrl.enableRegister(true);
                      }
                    }
                    else {
                      Fluttertoast.showToast(msg: "닉네임을 입력해주세요", gravity: ToastGravity.BOTTOM);
                    }
                  },
                ),
              ]
              ),
              SizedBox(
                height: 15,
              ),
              Obx(() => GestureDetector(
                child: Container(
                  alignment: Alignment.center,
                  height: 50,
                  decoration: BoxDecoration(
                      color: signCtrl.enableRegister.value ?
                        Colors.blue :
                        Colors.blue.withOpacity(0.3),
                      borderRadius: BorderRadius.all(Radius.circular(4))),
                  child: Text(
                    '회원가입',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                onTap: () async {
                  if(signCtrl.enableRegister.value == true) {
                    await signCtrl.signInWithPhoneNumber();
                    signCtrl.registerUserToDatabase();
                    idxCtrl.changePageIndex(0);
                    Get.offNamedUntil('/', (route) => false);
                  }
                }
              ),),
            ],
          ),
        ),
      ),
    );
  }
}
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hibaike/src/controller/bottom_index_controller.dart';
import 'package:hibaike/src/controller/sign_controller.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class MyPage extends StatefulWidget {
  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  SignController signCtrl = Get.find();
  bool isLoading = false;
  final nicknameController = TextEditingController();
  BottomIndexController indexCtrl = Get.find();

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

  Widget watchListWidget() {
    return InkWell(
      child: Column(
        children: [
          Icon(Icons.favorite_border, color: Colors.red,),
          SizedBox(height: 7,),
          Container(
            child: Text('관심목록', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),),
          ),
        ],
      ),
      onTap: () {
        print('go watch list view');
        Get.toNamed('/watchListView');
      },
    );
  }

  Widget salesListWidget() {
    return InkWell(
      child: Column(
        children: [
          Icon(Icons.app_registration),
          SizedBox(height: 7,),
          Container(
            child: Text('판매목록' ,style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),),
          ),
        ],
      ),
      onTap: () {
        print('go sales list view');
        Get.toNamed('/salesListView');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          '마이페이지',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        iconTheme: IconThemeData(
          color: Colors.black, //change your color here
        ),
      ),
      body: WillPopScope(
        onWillPop: () async{
          BottomIndexController.to.changePageIndex(0);
          Get.offAllNamed('/');
          return;
        },
        child: SingleChildScrollView(
          child: Container(
            child: Column(
              children: [
                SizedBox(height: 20,),
                GestureDetector(
                  child: Stack(
                    children: [
                      Material(
                        child: Obx(() => CachedNetworkImage(
                          placeholder: (context, url) => Container(
                            child: CircularProgressIndicator(
                              strokeWidth: 1.0,
                              //valueColor: AlwaysStoppedAnimation<Color>(themeColor),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.red),
                            ),
                            width: 30.0,
                            height: 30.0,
                            padding: EdgeInsets.all(0.0),
                          ),
                          imageUrl: ((signCtrl.currentUser.value.profileImageUrl != null) &&
                              (signCtrl.currentUser.value.profileImageUrl.length != 0))
                              ? signCtrl.currentUser.value.profileImageUrl
                              : 'https://i.stack.imgur.com/l60Hf.png',
                          width: 100.0,
                          height: 100.0,
                          fit: BoxFit.cover,
                        ),),
                        borderRadius: BorderRadius.all(Radius.circular(100.0)),
                        clipBehavior: Clip.hardEdge,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black12),
                            shape: BoxShape.circle,
                            color: Colors.white
                          ),
                          child: Icon(Icons.camera_alt, color: Colors.grey, size: 18,),
                      ),),
                    ],
                  ),
                  onTap: () async {
                    File newProfileImage = await selectImage();

                    print('profile image change');
                    if (newProfileImage != null) {
                      Get.dialog(
                        Dialog(
                          backgroundColor: Colors.transparent,
                          child: StatefulBuilder(
                              builder: (BuildContext context, StateSetter setState) {
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.grey,
                                  backgroundImage: FileImage(
                                      newProfileImage),
                                  radius: 80,
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                                GestureDetector(
                                  onTap: ()  async {
                                    setState(() {
                                      isLoading = true;
                                    });
                                    await signCtrl
                                        .replaceProfileImage(newProfileImage);
                                    isLoading = false;
                                    Get.back();
                                  },
                                  child: Container(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Container(
                                          width: 25,
                                          height: 25,
                                          padding: EdgeInsets.only(left: 5, right: 5, top: 5, bottom: 5),
                                          margin: EdgeInsets.only(right: 5),
                                          child: isLoading
                                              ? Center(child: CircularProgressIndicator(
                                            strokeWidth: 1,
                                          ))
                                              : Icon(Icons.check, color: Colors.green, size: 18,),
                                        ),
                                        Text('프로필 사진 변경'),
                                      ],
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(20)),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 15, vertical: 7),
                                  ),
                                ),
                              ],
                            );
    },
                          ),
                        ),
                      );
                    }
                  },
                ),
                Container(
                  padding: EdgeInsets.all(13),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Obx(() => Text(
                        '${signCtrl.currentUser.value.nickName}',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),),
                      SizedBox(width: 5,),
                      InkWell(
                          onTap: () {
                            nicknameController.text = signCtrl.currentUser.value.nickName;
                            Get.dialog(
                              Dialog(
                                backgroundColor: Colors.transparent,
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(color: Colors.white)
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                          child: TextField(
                                            controller: nicknameController,
                                            cursorColor: Colors.white,
                                            style: TextStyle(color: Colors.white),
                                            textAlign: TextAlign.center,
                                            decoration: InputDecoration(
                                              border: InputBorder.none,
                                              //focusedBorder: InputBorder.none,
                                            ),
                                          )),
                                      InkWell(
                                          onTap: () async {
                                            await signCtrl.updateNickname(nicknameController.text);
                                            Get.back();
                                          },
                                          child: Icon(
                                            Icons.edit,
                                            color: Colors.white,
                                          )),
                                    ]
                                  ),
                                ),
                              ),
                            );
                          },
                          child: Icon(
                            Icons.edit,
                            color: Colors.grey,
                          )),
                    ],
                  ),
                ),
                Divider(height: 0,),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      watchListWidget(),
                      salesListWidget(),
                    ],
                  ),
                ),
                Divider(height: 0, color: Colors.grey,),
                SizedBox(height: 10),

                InkWell(
                  child: Container(
                    padding: EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 10),
                    child: Row(
                      children: [
                        Icon(Icons.store_outlined, color: Colors.black54, size: 20,),
                        SizedBox(width: 8,),
                        Container(
                          child: Text('비즈회원공간', style: TextStyle(fontSize: 18, color: Colors.black54),),
                        ),
                      ],
                    ),
                  ),
                  onTap: () {
                    if(signCtrl.currentUser.value.grade == 'business') {
                      if(signCtrl.currentUser.value.shopId == null
                          || signCtrl.currentUser.value.shopId.length == 0) {
                        print('user grade is business, but no data about shop');
                        Get.toNamed('/shop/entry');
                      }
                      else {
                        print('view my shop info');
                        Get.toNamed('/shop/view');
                      }
                    }
                    else {
                      print('user grade is individual');
                      Get.toNamed('/shop/entry');
                    }
                  },
                ),

                Container(
                  padding: EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 10),
                  child: Row(
                    children: [
                      Icon(Icons.notifications_outlined, size: 20, color: Colors.black54,),
                      SizedBox(width: 8,),
                      Text('공지사항', style: TextStyle(fontSize: 18, color: Colors.black54)),
                    ],
                  ),
                ),

                Container(
                  padding: EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 10),
                  child: Row(
                    children: [
                      Icon(Icons.report_problem_outlined, size: 20, color: Colors.black54,),
                      SizedBox(width: 8,),
                      Text('오류사항제보', style: TextStyle(fontSize: 18, color: Colors.black54)),
                    ],
                  ),
                ),

                GestureDetector(
                  child: Container(
                    height: 50,
                    child: Text('로그아웃'),
                  ),
                  onTap: () {
                    signCtrl.signOut();
                    print('tab sign out button');
                    Get.offAllNamed('/');
                  },
                ),
                GestureDetector(
                  child: Container(
                    height: 50,
                    child: Text('회원탈퇴'),
                  ),
                  onTap: () {
                    signCtrl.withDrawAccount();
                    print('tab withdraw button');
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: indexCtrl.currentIndex.value,
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.grey,
          onTap: (index) {
            indexCtrl.changePageIndex(index);
            switch (index) {
              case 0:
                Get.toNamed('/');
                break;
              case 1:
                Get.toNamed('/nearby');
                break;
              case 2:
                if (signCtrl.isSignIn.value == true)
                  Get.toNamed('/chatRoom');
                else
                  Get.toNamed('/signUp');
                break;
              case 3:
                Get.toNamed('/tips');
                break;
              case 4:
                if (signCtrl.isSignIn.value == true)
                  Get.toNamed('/myPage');
                else
                  Get.toNamed('/signUp');
              //Get.toNamed('/signUp/saveProfile');
            }
          },
          items: [
            BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: '홈'),
            BottomNavigationBarItem(
                icon: Icon(Icons.place_outlined),
                activeIcon: Icon(Icons.place),
                label: '주변'),
            BottomNavigationBarItem(
                icon: Icon(Icons.chat_outlined),
                activeIcon: Icon(Icons.chat),
                label: '채팅'),
            BottomNavigationBarItem(
                icon: Icon(Icons.help_outline),
                activeIcon: Icon(Icons.help),
                label: '거래팁'),
            BottomNavigationBarItem(
                icon: Icon(Icons.account_circle_outlined),
                activeIcon: Icon(Icons.account_circle),
                label: signCtrl.isSignIn.value ? 'my' : '로그인'),
          ],
        ),
      ),
    );
  }
}
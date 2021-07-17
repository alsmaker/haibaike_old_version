import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hibaike/src/controller/bottom_index_controller.dart';
import 'package:package_info/package_info.dart';

import 'controller/sign_controller.dart';

class Home extends StatefulWidget {

  const Home({Key key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // final SignController signCtrl = Get.put(SignController());
  // final BottomIndexController indexCtrl = Get.put(BottomIndexController());
  SignController signCtrl = Get.find();
  BottomIndexController indexCtrl = Get.find();

  @override
  void initState() {
    super.initState();
  }

  Widget sellBikeWidget() {
    return Container(
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.all(Radius.circular(4)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('간편하고 빠른 바이크 등록',style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),),
                Text('1분이면 등록 OK', style: TextStyle(color: Colors.black54),),
              ],
            ),
          ),
          ElevatedButton(
              child: Text('Sell Bike'),
              onPressed: () {
                FirebaseFirestore.instance
                    .collection('bikes')
                    .where('ownerUid', isEqualTo: signCtrl.currentUser.value.uid)
                    .get()
                    .then((snap) => {
                      if(snap.size >= 3) {
                        if(signCtrl.currentUser.value.grade == 'business'
                          && signCtrl.currentUser.value.shopId.length > 0) {
                          Get.toNamed('/register')
                        } else
                        Get.toNamed("/shop/entry")
                      }
                      else
                        Get.toNamed("/register")
                    });
              }
          ),
        ],
      ),
    );
  }

  Widget tipsWidget() {
    return Container(
      padding: EdgeInsets.only(left: 15, right: 15, top: 10),
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.only(bottom: 17),
            child: Row(
              children: [
                Text('중고바이크 거래팁', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                Icon(Icons.navigate_next),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(bottom: 15),
            child: Row(
              children: [
                Icon(Icons.help_outline, size: 17),
                SizedBox(width: 3,),
                Expanded(
                    child: Text('이전등록시 필요서류와 절차는?',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.bold),
                    )),
                InkWell(
                  onTap: () {
                    Get.toNamed('/tips', arguments: 0);
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: Text('자세히보기', style: TextStyle(color: Colors.white, fontSize: 12),),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () {
                Get.toNamed('/tips', arguments: 1);
                },
            child: Container(
              margin: EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Icon(Icons.help_outline, size: 17),
                  SizedBox(width: 3,),
                  Expanded(
                      child: Text('취등록세 계산기',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                            fontWeight: FontWeight.bold),
                      )),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: Text('자세히보기', style: TextStyle(color: Colors.white, fontSize: 12),),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('하이바이크', style: TextStyle(color: Colors.black,fontWeight: FontWeight.w800),),),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              child: Column(
                children: [
                  Container(
                    child: Text('내가 원하는 모델타입들만 골라서 검색'),
                  ),
                  Container(
                    child: Text('나와 가까운 동네부터 검색'),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 15, right: 15, bottom: 15, top: 15),
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 3),
                      borderRadius: BorderRadius.all(Radius.circular(7)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.search, color: Colors.red,),
                        SizedBox(width: 5,),
                        Text('Buy Bike', style: TextStyle(color: Colors.red, fontSize: 21, fontWeight: FontWeight.w900),)
                      ],
                    ),
                  ),
                ],
              ),
              onTap: () {
                if(signCtrl.isSignIn.value == true)
                  Get.toNamed("/view");
                else
                  Get.toNamed('/signUp');
              },
            ),
            Divider(),
            sellBikeWidget(),
            Divider(),
            tipsWidget(),
            Divider(),
            Container(
              padding: EdgeInsets.only(left: 15, right: 15, top: 15),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('엔진오일교체, 고장수리는 어디서??', style: TextStyle(color: Colors.black54),),
                        SizedBox(height: 10,),
                        Row(
                          children: [
                            Icon(Icons.place_outlined, color: Colors.black, size: 20,),
                            Text('우리동네 바이크샵 찾기', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                          ],
                        ),
                      ],
                    ),
                  ),

                  Container(
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.all(Radius.circular(5))
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.map_outlined),
                        Text('지도로보기', style: TextStyle(fontSize: 10)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Divider(),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  child: Text(
                    '벌금? 행정처분?',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                Container(
                  child: Text(
                    '전문가가 진행하는 머플러 구조 변경 서류대행 5만원',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                ElevatedButton(
                    onPressed: () {
                      Get.toNamed('/appbartest');
                      },
                    child: Text('test')),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: Obx(() => BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: indexCtrl.currentIndex.value,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          indexCtrl.changePageIndex(index);
          switch(index) {
            case 0:
              Get.toNamed('/');
              break;
            case 1:
              Get.toNamed('/nearby');
              break;
            case 2:
              if(signCtrl.isSignIn.value == true)
                Get.toNamed('/chatRoom');
              else
                Get.toNamed('/signUp');
              break;
            case 3:
                Get.toNamed('/tips');
                break;
            case 4:
              if(signCtrl.isSignIn.value == true)
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
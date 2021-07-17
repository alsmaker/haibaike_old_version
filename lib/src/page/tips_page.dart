import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:elastic_client/elastic_client.dart' as elastic;
import 'package:hibaike/src/component/currency_input_formmatter.dart';
import 'package:hibaike/src/controller/bottom_index_controller.dart';
import 'package:hibaike/src/controller/sign_controller.dart';
import 'package:hibaike/src/model/registry_data.dart';
import 'package:intl/intl.dart';

class TipsPage extends StatefulWidget {
  @override
  _TipsPageState createState() => _TipsPageState();
}

class _TipsPageState extends State<TipsPage> with TickerProviderStateMixin{
  int initialTab = Get.arguments;
  TabController _tabController;

  SignController signCtrl = Get.find();
  BottomIndexController indexCtrl = Get.find();

  @override
  void initState() {
    if(Get.arguments == null)
      _tabController = TabController(length: 2, vsync: this, initialIndex: 0);
    else
      _tabController = TabController(length: 2, vsync: this, initialIndex: initialTab);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        indexCtrl.currentIndex(0);
        Get.offAllNamed('/');
        return;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('중고거래팁', style: TextStyle(color: Colors.white),),
          iconTheme: IconThemeData(
            color: Colors.white
          ),
          backgroundColor: Colors.black,
          bottom: TabBar(
            controller: _tabController,
            labelColor: Colors.white,
            labelStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            indicatorWeight: 5,
            tabs: [
              Tab(
                text: '이전등록절차',
              ),
              Tab(
                text: '취등록세계산기',
              ),
            ],
          ),
        ),
        body: TabBarView(controller: _tabController, children: [
          TransferProcess(),
          TexCalculator(),
        ]),

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
      ),
    );
  }
}

class TransferProcess extends StatefulWidget{
  @override
  _TransferProcessState createState() => _TransferProcessState();
}

class _TransferProcessState extends State<TransferProcess> {
  List<String> kindOfSeller = ['개인', '법인'];
  List<String> kindOfBuyer = ['개인', '법인'];
  List<String> numberExist = ['번호판 없을때', '번호판 있을때'];

  int currentSeller = 0;
  int currentBuyer = 0;
  int currentNumberExist = 0;

  Widget selectCondition() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('판매자'),
            SizedBox(height: 8,),
            Container(
              child: PopupMenuButton(
                offset: Offset(0, 45),
                shape: ShapeBorder.lerp(RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
                    RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
                    0),
                itemBuilder: (BuildContext context) {
                  return kindOfSeller.map((menu) {
                    print(menu);
                    var index =
                    kindOfSeller.indexOf(menu);
                    if(index == currentSeller)
                      return PopupMenuItem(
                          value: index,
                          child: Row(
                            children: [
                              Icon(Icons.check, color: Colors.red, size: 18,),
                              SizedBox(width: 3,),
                              Text(menu),
                            ],
                          ));
                    else
                      return PopupMenuItem(
                          value: index,
                          child: Row(
                              children: [
                                SizedBox(width: 22,),
                                Text(menu)
                              ]));
                  }).toList();
                },
                onSelected: (int value) {
                  setState(() {
                    currentSeller = value;
                  });
                },
                child: Container(
                  padding: EdgeInsets.fromLTRB(10, 5, 7, 5),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                      border: Border.all(color: Colors.black54)
                  ),
                  child: Row(
                    children: [
                      Text(
                        kindOfSeller[currentSeller],
                        style: TextStyle(
                            color: Colors.black54, fontSize: 16),
                      ),
                      SizedBox(width: 8,),
                      Icon(Icons.expand_more, color: Colors.black54, size: 25,)
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),

        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('구매자'),
            SizedBox(height: 8,),
            Container(
              child: PopupMenuButton(
                offset: Offset(0, 45),
                shape: ShapeBorder.lerp(RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
                    RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
                    0),
                itemBuilder: (BuildContext context) {
                  return kindOfBuyer.map((menu) {
                    print(menu);
                    var index =
                    kindOfBuyer.indexOf(menu);
                    if(index == currentBuyer)
                      return PopupMenuItem(
                          value: index,
                          child: Row(
                            children: [
                              Icon(Icons.check, color: Colors.red, size: 18,),
                              SizedBox(width: 3,),
                              Text(menu),
                            ],
                          ));
                    else
                      return PopupMenuItem(
                          value: index,
                          child: Row(
                              children: [
                                SizedBox(width: 22,),
                                Text(menu)
                              ]));
                  }).toList();
                },
                onSelected: (int value) {
                  setState(() {
                    currentBuyer = value;
                  });
                },
                child: Container(
                  padding: EdgeInsets.fromLTRB(10, 5, 7, 5),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                      border: Border.all(color: Colors.black54)
                  ),
                  child: Row(
                    children: [
                      Text(
                        kindOfBuyer[currentBuyer],
                        style: TextStyle(
                            color: Colors.black54, fontSize: 16),
                      ),
                      SizedBox(width: 8,),
                      Icon(Icons.expand_more, color: Colors.black54, size: 25,)
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),

        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('번호판'),
            SizedBox(height: 8,),
            Container(
              child: PopupMenuButton(
                offset: Offset(0, 45),
                shape: ShapeBorder.lerp(RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
                    RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
                    0),
                itemBuilder: (BuildContext context) {
                  return numberExist.map((menu) {
                    print(menu);
                    var index =
                    numberExist.indexOf(menu);
                    if(index == currentNumberExist)
                      return PopupMenuItem(
                          value: index,
                          child: Row(
                            children: [
                              Icon(Icons.check, color: Colors.red, size: 18,),
                              SizedBox(width: 3,),
                              Text(menu),
                            ],
                          ));
                    else
                      return PopupMenuItem(
                          value: index,
                          child: Row(
                              children: [
                                SizedBox(width: 22,),
                                Text(menu)
                              ]));
                  }).toList();
                },
                onSelected: (int value) {
                  setState(() {
                    currentNumberExist = value;
                  });
                },
                child: Container(
                  padding: EdgeInsets.fromLTRB(10, 5, 7, 5),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                      border: Border.all(color: Colors.black54)
                  ),
                  child: Row(
                    children: [
                      Text(
                        numberExist[currentNumberExist],
                        style: TextStyle(
                            color: Colors.black54, fontSize: 16),
                      ),
                      SizedBox(width: 8,),
                      Icon(Icons.expand_more, color: Colors.black54, size: 25,)
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget sellerIndividual() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      decoration: BoxDecoration(
          color: Colors.black12,
          borderRadius: BorderRadius.all(Radius.circular(5))
      ),
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('판매자 준비사항', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
          SizedBox(height: 8,),
          Text('1. 폐지증명서 발급', style: TextStyle(fontSize: 16),),
          Container(
              padding: EdgeInsets.only(left: 15),
              child: Column(
                children: [
                  Text(
                    '* 지역별로 시/군/구청 또는 주민센터 등 처리 관청이 상이하므로 지역별로 확인 필요. 서울의 경우 구청에서 처리',
                    style: TextStyle(fontSize: 15),
                  ),
                  Text(
                    '* 차량 번호판과 이륜자동차사용신고필증을 제출하면 폐지증명서 발급',
                    style: TextStyle(fontSize: 15),
                  ),
                  Text(
                    '* 번호판 제거는 처리기관에서 해주는 경우도 있으며 직접 제거해도 무방함',
                    style: TextStyle(fontSize: 15),
                  ),
                ],
              )),
          Text('2. 양도증명서(매매계약서)', style: TextStyle(fontSize: 16),),
          Container(
            padding: EdgeInsets.only(left: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
            '* 시/군/구청 또는 주민센터 등 처리관청에 비치된 양식 작성',
                    style: TextStyle(fontSize: 15),
                  ),
                  Text(
                    '[작성 예시 보기]',
                    style: TextStyle(fontSize: 15, color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                ],
              )),
          Text('3. 판매자 신분증 사본', style: TextStyle(fontSize: 16),),
        ],
      ),
    );
  }

  Widget sellerCorporation() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      decoration: BoxDecoration(
          color: Colors.black12,
          borderRadius: BorderRadius.all(Radius.circular(5))
      ),
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('판매자 준비사항', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
          SizedBox(height: 8,),
          Text('1. 폐지증명서 발급', style: TextStyle(fontSize: 16),),
          Text('2. 양도양수 증명서(매매계약서)', style: TextStyle(fontSize: 16),),
          Text('3. 사업자등록증 사본', style: TextStyle(fontSize: 16),),
          Text('4. 법인인감증명서', style: TextStyle(fontSize: 16),),
        ],
      ),
    );
  }

  Widget buyerIndividual() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      decoration: BoxDecoration(
          color: Colors.black12,
          borderRadius: BorderRadius.all(Radius.circular(5))
      ),
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('구매자 등록절차', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
          SizedBox(height: 8,),
          Text('1. 판매자가 준비한 서류 확인', style: TextStyle(fontSize: 16),),
          Text('2. 보험가입증명서', style: TextStyle(fontSize: 16),),
          Container(
            padding: EdgeInsets.only(left: 15),
            child: Column(
              children: [
                Text('* 차량 등록 전 보험가입은 필수입니다. 보험 가입이 되지 않을 경우 등록 불가', style: TextStyle(fontSize: 16),),
                Text('* 보험가입증명서를 지참하지 않더라도 자동차 등록소에서 폐지증명서에 기재된 차대번호로 보험 전산 확인이 가능합니다.', style: TextStyle(fontSize: 16),),
              ],
            ),
          ),
          Text('3. 가까운 자동차 등록소 방문하여 차량 등록', style: TextStyle(fontSize: 16),),
          Container(
            padding: EdgeInsets.only(left: 15),
            child: Column(
              children: [
                Text('* 신분증을 꼭 지참해 주세요', style: TextStyle(fontSize: 16),),
                InkWell(
                  onTap: () {
                    Get.toNamed('/nearby/registryLocation');
                  },
                    child: Text(
                  '[가까운 차량 등록소 찾기]',
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.red,
                      fontWeight: FontWeight.bold),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buyerCorporation() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      decoration: BoxDecoration(
          color: Colors.black12,
          borderRadius: BorderRadius.all(Radius.circular(5))
      ),
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('구매자 등록절차', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
          SizedBox(height: 8,),
          Text('1. 판매자가 준비한 서류 확인', style: TextStyle(fontSize: 16),),
          Text('2. 보험가입증명서', style: TextStyle(fontSize: 16),),
          Text('3. 사업자등록증 사본', style: TextStyle(fontSize: 16),),
          Text('4. 법인대표자 신분증', style: TextStyle(fontSize: 16),),
          Text('5. (법인대표자가 직접 구청에 방문하지 않는 경우) 위임장', style: TextStyle(fontSize: 16),),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.only(left: 10, right: 15, top: 10, bottom: 10),
        child: Column(
          children: [
            selectCondition(),
            SizedBox(height: 10,),
            currentSeller == 0
                ? sellerIndividual()
                : sellerCorporation(),
            SizedBox(height: 15,),
            currentBuyer==0
                ?buyerIndividual()
                :buyerCorporation(),
          ],
        ),
      ),
    );
  }
}

class TexCalculator extends StatefulWidget {
  @override
  _TexCalculatorState createState() => _TexCalculatorState();
}

class _TexCalculatorState extends State<TexCalculator> {
  final displacementController = TextEditingController();
  final amountController = TextEditingController();

  bool showResult = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.only(left: 15, right: 15, top: 20),
        child: Column(
          children: [
            Text('취등록세 계산'),
            Row(
              children: [
                Text('배기량', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),),
                SizedBox(width: 20,),
                Expanded(
                    child: TextField(
                      controller: displacementController,
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: '예) 125',
                          hintStyle: TextStyle(color: Colors.grey)
                      ),
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      inputFormatters: [
                        CurrencyInputFormatter()
                      ],
                    ),
                ),
                SizedBox(width: 10,),
                Text('cc', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),),
              ],
            ),
            Divider(),
            Row(
              children: [
                Text('거래금액', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),),
                SizedBox(width: 20,),
                Expanded(
                    child: TextField(
                      controller: amountController,
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: '예) 5,000,000',
                          hintStyle: TextStyle(color: Colors.grey)
                      ),
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      inputFormatters: [
                        CurrencyInputFormatter()
                      ],
                    ),
                ),
                SizedBox(width: 10,),
                Text('원', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),),
              ],
            ),
            Divider(),
            SizedBox(height: 15,),
            InkWell(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                ),
                child: Text(
                  '계산하기',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
              ),
              onTap: () {
                //FocusScope.of(context).unfocus();
                if(isValidInput()) {
                  setState(() {
                    showResult = true;
                  });
                }
                else
                  return Container();
              },
            ),
            showResult
            ? resultTaxWidget()
            : Container()
          ],
        ),
      ),
    );
  }

  Widget resultTaxWidget() {
    final numberFormatter = NumberFormat('#,###');

    if(int.parse(displacementController.text) <= 50) {
      return Column(
        children: [
          SizedBox(height: 15,),
          Divider(),
          SizedBox(height: 15,),
          Container(
            child: Text(
              '50cc 이하는 세금이 부과되지 않습니다',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      );
    }
    else if(int.parse(displacementController.text) >= 50 &&
        int.parse(displacementController.text) <= 125) {
      var amount = amountController.text.replaceAll(',', '');
      double acquisitionTax = double.parse(amount) * 0.02;
      int registrationTax = 0;
      return Column(
        children: [
          SizedBox(height: 15,),
          Divider(),
          SizedBox(height: 15,),
          Row(
            children: [
              Expanded(child: Text('취득세', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),)),
              Text(numberFormatter.format(acquisitionTax.toInt()), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
              Text('원', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
              ],
          ),
          SizedBox(height: 15,),
          Row(
            children: [
              Expanded(child: Text('등록세',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),),
              Text(registrationTax.toString(), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
              Text('원', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
            ],
          ),
          Divider(height: 35,),
          Row(
            children: [
              Expanded(child: Text('총액',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),),
              Text(numberFormatter.format(acquisitionTax.toInt()+registrationTax), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
              Text('원', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
            ],
          ),
        ],
      );
    }

    else {
      var amount = amountController.text.replaceAll(',', '');
      double acquisitionTax = double.parse(amount) * 0.02;
      double registrationTax = double.parse(amount) * 0.03;
      return Column(
        children: [
          SizedBox(height: 15,),
          Divider(),
          SizedBox(height: 15,),
          Row(
            children: [
              Expanded(child: Text('취득세', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),)),
              Text(numberFormatter.format(acquisitionTax.toInt()), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
              Text('원', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
            ],
          ),
          SizedBox(height: 15,),
          Row(
            children: [
              Expanded(child: Text('등록세',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),),
              Text(numberFormatter.format(registrationTax.toInt()), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
              Text('원', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
            ],
          ),
          Divider(height: 35,),
          Row(
            children: [
              Expanded(child: Text('총액',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),),
              Text(numberFormatter.format(acquisitionTax.toInt()+registrationTax.toInt()), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
              Text('원', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
            ],
          ),
        ],
      );
    }


    return Container();
  }

  bool isValidInput(){
    if(displacementController.text == null || displacementController.text.length == 0){
      Fluttertoast.showToast(msg: '배기량을 입력해주세요');
      return false;
    }
    if(amountController.text == null || amountController.text.length == 0) {
      Fluttertoast.showToast(msg: '거래금액을 입력해주세요');
      return false;
    }

    return true;
  }
}

class RegistryLocation extends StatefulWidget {

  @override
  _RegistryLocationState createState() => _RegistryLocationState();
}

class _RegistryLocationState extends State<RegistryLocation> with WidgetsBindingObserver{
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  GoogleMapController _controller;
  String apiKey = 'AIzaSyAgkR2a33agDSGR2adz2KK-aZ5A_MEbBnw'; // google places api key
  Position position;
  LatLng currentPosition;
  CameraPosition cameraPosition;
  var lat, lng;
  bool isLoading = true;
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

  String locationQuery;

  MarkerId latestSelectedMarker = MarkerId('');

  @override
  void initState() {
    checkGPAvailability();
    WidgetsBinding.instance.addObserver(this);

    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      resumeGoogleMap();
    }
  }

  resumeGoogleMap() async{
    print('resume google map');
    //final GoogleMapController controller = await _controller.future;
    //controller.setMapStyle("[]");
    _controller.setMapStyle("[]]");
  }

  void checkGPAvailability() async {
    bool serviceEnabled;
    LocationPermission permission;

    print('sync test 1');

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('location services are disabled');
      return;
    }

    print('sync test 2');

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      print(
          'Location permission are permently denied, we cannot request permissions');
      return;
    }
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        print('Location permissions are denied (actual value: $permission).');
        return;
      }
    }

    print('sync test 3');

    await getUserCurrentPosition();

    print('sync test');
  }

  Future<LatLng> getUserCurrentPosition () async {
    position = await Geolocator.getCurrentPosition();
    print('my position is lat = ${position.latitude}, lng = ${position
        .longitude}');


    setState(() {
      lat = position.latitude;
      lng = position.longitude;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text("가까운등록소 찾기", style: TextStyle(color: Colors.white),),
        iconTheme: IconThemeData(
          color: Colors.white
        ),
        backgroundColor: Colors.black,
      ),
      body: isLoading
          ? Container(
        decoration: BoxDecoration(color: Colors.white),
      )
          : GoogleMap(
        mapType: MapType.normal,
        markers: Set<Marker>.of(markers.values),//Set.from(registryList),
        initialCameraPosition: CameraPosition(
          //target: LatLng(37.49639442929692, 127.04438769057595),
          target: LatLng(lat, lng),
          zoom: 15,
        ),
        onMapCreated: (GoogleMapController controller) {
          //_controller.complete(controller);
          _controller = controller;
          // getAddrFromLocation();
        },
        myLocationEnabled: true,
        zoomControlsEnabled: false,
        onCameraMoveStarted: _onCameraMoveStarted,
        onCameraMove: _onCameraMove,
        onCameraIdle: _onCameraIdle,
      ),
    );
  }

  _onCameraMoveStarted() {
    //print('camera move start');
  }

  _onCameraMove(CameraPosition position) async{
    cameraPosition = position;
    //print("camera moving");
    LatLngBounds bounds = await _controller.getVisibleRegion();
    print(bounds);
  }

  _onCameraIdle() {
    print('camera idle');
    markers.clear();
    loadRegistryDataFromElastic();
  }

  Widget bottomSheet(RegistryData registryData) {
    return Container(
      //padding:
      //EdgeInsets.only(left: 15, right: 15, top: 20, bottom: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.only(top: 15, left: 10, right: 10, bottom: 15),
                  decoration: BoxDecoration(
                    color: Colors.red
                  ),
                  child: Text(
                    registryData.name,
                    style: TextStyle(
                        color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 15,
          ),
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                    borderRadius:
                    BorderRadius.all(Radius.circular(5)),
                    color: Colors.grey),
                child: Text(
                  '지번',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(
                width: 7,
              ),
              Text(
                registryData.address,
                style: TextStyle(fontSize: 15),
              ),
            ],
          ),
          SizedBox(
            height: 7,
          ),
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                    borderRadius:
                    BorderRadius.all(Radius.circular(5)),
                    color: Colors.grey),
                child: Text(
                  '도로',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(
                width: 5,
              ),
              Text(
                registryData.roadAddress,
                style: TextStyle(fontSize: 15),
              ),
            ],
          ),
          SizedBox(
            height: 8,
          ),
          Row(
            children: [
              Icon(
                Icons.local_phone,
                size: 15,
                color: Colors.grey,
              ),
              SizedBox(
                width: 5,
              ),
              Text(
                registryData.contact,
                style: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ],
          )
        ],
      ),
    );

  }

  loadRegistryDataFromElastic() async{
    String username = 'elastic';
    String password = 'uGeImNqJ3DP31Qanpavemgqz';
    String basicAuth =
        'Basic ' + base64Encode(utf8.encode('$username:$password'));
    final transport = elastic.HttpTransport(url: "https://hibaike-search-deployment.es.asia-northeast1.gcp.cloud.es.io:9243",
        authorization: basicAuth);
    final client = elastic.Client(transport);

    LatLngBounds bounds = await _controller.getVisibleRegion();
    var top = bounds.northeast.latitude;
    var bottom = bounds.southwest.latitude;
    var left = bounds.southwest.longitude;
    var right = bounds.northeast.longitude;
    int limit = 10;

    print('top = $top, bottom = $bottom, left = $left, right = $right');

    String queryString = '{"bool": {"must": {"match_all": {}},"filter": {"geo_bounding_box": {"location": {"top_left": {"lat": $top,"lon": $left},"bottom_right": {"lat": $bottom,"lon": $right}}}}}}';
    Map queryMap = json.decode(queryString);

    var response = await client.search(
        index: 'bike_registry',
        type: '_doc',
        query: queryMap,
        limit: limit,
        source: true,
    );

    if(response.hits.length >=  limit)
      Fluttertoast.showToast(msg: '최대 10개 등록소가 표시됩니다');

    response.hits.forEach((doc) {
      print(doc.doc['name']);
      var mapJson = Map<String, dynamic>.from(doc.doc);
      RegistryData registryData = RegistryData.fromJson(mapJson);

      var _marker = Marker(
          markerId: MarkerId(doc.id),
          position:
              LatLng(registryData.location.lat, registryData.location.lon),
          icon: doc.id==latestSelectedMarker.value
              ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue)
              : BitmapDescriptor.defaultMarker,
          consumeTapEvents: true,
          onTap: () {
            print('marker tab');
            //scaffoldKey.currentState.showBottomSheet((context) => BottomSheetWidget(registryData: registryData,));
            setState(() {
              if(latestSelectedMarker != null && latestSelectedMarker.value.length != 0 
                && markers.containsKey(latestSelectedMarker)) {
                Marker _marker = markers[latestSelectedMarker];
                markers[latestSelectedMarker] =
                    _marker.copyWith(iconParam: BitmapDescriptor.defaultMarker);
              }
              latestSelectedMarker = MarkerId(doc.id);
              Marker _marker = markers[latestSelectedMarker];
              markers[latestSelectedMarker] = _marker.copyWith(
                iconParam: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue));

              scaffoldKey.currentState.showBottomSheet((context) {
                return bottomSheet(registryData);
              });
            });
          });

      setState(() {
        markers[MarkerId(doc.id)] = _marker;
      });

    });
  }
}

class BottomSheetWidget extends StatefulWidget {
  final RegistryData registryData;
  const BottomSheetWidget({Key key, this.registryData}) : super(key: key);

  @override
  _BottomSheetWidgetState createState() => _BottomSheetWidgetState();
}

class _BottomSheetWidgetState extends State<BottomSheetWidget> {
  // ShopData shopData;
  // _BottomSheetWidgetState({this.shopData});
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    /*
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      padding: EdgeInsets.only(left: 10, right: 10, top: 15, bottom: 30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.registryData.address),
          Text(widget.registryData.roadAddress),
          Text(widget.registryData.contact),
        ],
      ),
    );
     */
  }
}
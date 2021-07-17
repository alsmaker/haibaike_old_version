import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hibaike/src/controller/shop_info_controller.dart';
import 'package:hibaike/src/model/address_from_http.dart';
import 'package:http/http.dart' as http;

class ShopLocation extends StatefulWidget {
  @override
  _ShopLocationState createState() => _ShopLocationState();
}

class _ShopLocationState extends State<ShopLocation> {
  TextEditingController addrCtrl = new TextEditingController();
  AddrFromHttp addrFromHttp = AddrFromHttp();
  ShopInfoController shopInfoController = Get.find();
  final addressDetailController = TextEditingController();

  @override
  initState() {
    addressDetailController.addListener(() {
      shopInfoController.addressDetail.value = addressDetailController.text;
    });

    super.initState();
  }

  Future<String> getPlaceAddress() async {
    String kakaoAppKey = '3c6646867e44dcf25034a602f046af44';
    var header = {'Authorization': 'KakaoAK $kakaoAppKey'};
    String baseKakaoUrl = "https://dapi.kakao.com/v2/local/search/address.json";
    String completeUrl = '$baseKakaoUrl?query=${addrCtrl.text}';

    final response = await http.get(completeUrl, headers: header);
    print(response.body);

    setState(() {
      addrFromHttp = parseAddress(response.body);
    });
  }

  AddrFromHttp parseAddress(String responseBody) {
    final parsed = json.decode(responseBody);

    return AddrFromHttp.fromJson(parsed);
  }

  Widget showSelectedAddress() {
      return Obx(
        () => (shopInfoController.address.value.length > 0 ||
            shopInfoController.roadAddress.value.length > 0)
            ? Container(
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(4),
                    margin: EdgeInsets.only(right: 7),
                    child: Text(
                      '지번',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                    ),
                  ),
                  Text(
                    shopInfoController.address.value,
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
              SizedBox(height: 10,),
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(4),
                    margin: EdgeInsets.only(right: 7),
                    child: Text(
                      '도로명',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                    ),
                  ),
                  Expanded(
                    child: Text(
                          shopInfoController.roadAddress.value,
                          style: TextStyle(fontSize: 16),
                          overflow: TextOverflow.ellipsis,
                          softWrap: false,
                          maxLines: 1,
                        ),
                  ),
                    ],
              ),
              Container(
                padding: EdgeInsets.only(left: 20, right: 20),
                child: TextField(
                  controller: addressDetailController,
                  decoration: InputDecoration(
                      //border: InputBorder.none,
                      hintText: '상세주소',
                      hintStyle: TextStyle(color: Colors.grey)),
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.done,
                ),
              ),
              SizedBox(height: 20,),
              Divider(height: 10,),
            ],
          ),
        )
    : Container(),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('마이샵 위치 설정', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
          color: Colors.black
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            showSelectedAddress(),
            Row(
                children: [
                  Expanded(
                    child: TextField(
                      textInputAction: TextInputAction.search,
                      controller: addrCtrl,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: ' 도로명, 건물명 또는 지번으로 검색',
                      ),
                    ),
                  ),
                  GestureDetector(
                    child: Container(child: Icon(Icons.search)),
                    onTap: () {
                      getPlaceAddress();
                    },
                  ),
                ]
            ),
            Divider(height: 10,),
            GestureDetector(
              child: Container(
                height: 45,
                //padding: EdgeInsets.symmetric(horizontal: 10),
                margin: EdgeInsets.fromLTRB(10, 15, 10, 0),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.location_searching, color: Colors.black, size: 18,),
                    Text(' 현재 위치로 주소 찾기', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),),
                  ],
                ),
              ),
              onTap: () {
                Get.toNamed('/location/pickLocationWithGoogleMap', arguments: '/shop/register/location');
              },
            ),
            Divider(height: 10,),
            Expanded(
              child: ListView.builder(
                itemCount: addrFromHttp.meta == null ? 0 : addrFromHttp.meta.totalCount,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: CircleAvatar(
                      child: Icon(
                        Icons.pin_drop,
                        color: Colors.white,
                      ),
                    ),
                    title: addrFromHttp.documents[index].address.addressName.length == 0 ?
                    Text(addrFromHttp.documents[index].roadAddress.addressName) :
                    Text(addrFromHttp.documents[index].address.addressName),
                    subtitle: addrFromHttp.documents[index].address.addressName.length == 0 ?
                    SizedBox(height: 0,) :
                    Text(addrFromHttp.documents[index].roadAddress.addressName),
                    onTap: () {
                      if (addrFromHttp.documents[index].address.addressName !=
                          null &&
                          addrFromHttp.documents[index].address.addressName
                              .length > 0) {
                        shopInfoController.address.value = addrFromHttp
                            .documents[index].address.addressName;
                      }

                      if (addrFromHttp.documents[index].roadAddress
                          .addressName != null &&
                          addrFromHttp.documents[index].roadAddress.addressName
                              .length > 0) {
                        shopInfoController.roadAddress.value = addrFromHttp
                            .documents[index].roadAddress.addressName;
                      }

                      shopInfoController.shopLocation.lat =
                          double.parse(addrFromHttp.documents[index].y);
                      shopInfoController.shopLocation.lon =
                          double.parse(addrFromHttp.documents[index].x);
                    }
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Obx(() =>
          (shopInfoController.address.value.length > 0 ||
                  shopInfoController.roadAddress.value.length > 0)
              ? InkWell(
            onTap: () {
              Get.back();
            },
                child: Container(
                    height: 55,
                    decoration: BoxDecoration(color: Colors.red),
                    child: Center(
                        child: Text(
                      '위치 설정 완료',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 17),
                    )),
                  ),
              )
              : Container(
                  height: 0,
                )),
    );
  }
}
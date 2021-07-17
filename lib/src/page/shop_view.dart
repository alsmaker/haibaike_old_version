import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hibaike/src/controller/sign_controller.dart';
import 'package:hibaike/src/model/shop_data.dart';

class ShopViewPage extends StatefulWidget {
  @override
  _ShopViewPageState createState() => _ShopViewPageState();
}

class _ShopViewPageState extends State<ShopViewPage> {
  SignController signController = Get.find();
  ShopData shopData;
  
  @override
  void initState() {
    bringShopData();
    super.initState();
  }

  Future<ShopData> bringShopData() async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('shops')
        .doc(signController.currentUser.value.shopId)
        .get();
     return shopData = ShopData.fromJson(snapshot.data());
  }
  
  Widget photosWidget() {
    return Column(
      children: [
        Row(
          children: [
            Icon(Icons.photo, size: 22, color: Colors.black54,),
            SizedBox(width: 5,),
            Text('매장사진', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black54),),
          ],
        ),
        Container(
          height: 115,
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
          child: ListView.builder(
            // todo
            itemCount: shopData.imageList.length,
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              double thumbnailSize = 75;

              return Container(
                padding:
                    EdgeInsets.only(left: 10, right: 10, bottom: 10, top: 10),
                child: Material(
                  child: CachedNetworkImage(
                    placeholder: (context, url) => Container(
                      child: CircularProgressIndicator(
                        strokeWidth: 1.0,
                        //valueColor: AlwaysStoppedAnimation<Color>(themeColor),
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                      ),
                      width: thumbnailSize,
                      height: thumbnailSize,
                      padding: EdgeInsets.all(10.0),
                    ),
                    imageUrl: shopData.imageList[index],
                    width: thumbnailSize,
                    height: thumbnailSize,
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.all(
                    Radius.circular(5.0),
                  ),
                  clipBehavior: Clip.hardEdge,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget addressWidget() {
    return Column(
      children: [
        Row(
          children: [
            Icon(Icons.place_outlined, size: 22, color: Colors.black54,),
            SizedBox(width: 5,),
            Text('매장주소', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black54),),
          ],
        ),
        SizedBox(height: 5,),
        Container(
            padding: EdgeInsets.only(top: 10, bottom: 10),
            child: Column(children: [
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
                      color: Colors.red,
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                    ),
                  ),
                  shopData.address.length > 0
                      ? Text(
                    shopData.address +
                        ' ' +
                        shopData.addressDetail,
                    style: TextStyle(fontSize: 16),
                  )
                      : Container(),
                ],
              ),
              SizedBox(
                height: 10,
              ),
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
                      color: Colors.red,
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                    ),
                  ),
                  shopData.roadAddress.length > 0
                      ? Expanded(
                    child: Text(
                      shopData.roadAddress +
                          ' ' +
                          shopData.addressDetail,
                      style: TextStyle(fontSize: 16),
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                      maxLines: 2,
                    ),
                  )
                      : Container(),
                ],
              ),
            ])),
      ]
    );
  }

  Widget contactWidget() {
    return Column(
      children: [
        Row(
          children: [
            Icon(Icons.local_phone, size: 22, color: Colors.black54,),
            SizedBox(width: 5,),
            Text('연락처', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black54),),
          ],
        ),
        SizedBox(height: 10,),
        Row(
          children: [
            SizedBox(width: 25,),
            Text('• ${shopData.contact}', style: TextStyle(fontSize: 16),),
          ],
        ),
        shopData.isOpenPhoneNumber
            ? Row(
              children: [
                SizedBox(width: 25,),
                Text(
                    '• 휴대폰 번호 공개',
                    style: TextStyle(fontSize: 16),
                  ),
              ],
            )
            : Row(
              children: [
                SizedBox(width: 25,),
                Text(
                    '• 휴대폰 번호 비공개',
                    style: TextStyle(fontSize: 16),
                  ),
              ],
            ),
      ],
    );
  }

  Widget diagnosticDeviceWidget() {
    return Column(
      children: [
        Row(
          children: [
            Icon(Icons.perm_device_info, size: 22, color: Colors.black54,),
            SizedBox(width: 5,),
            Text('진단기 보유 종류', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black54),),
          ],
        ),
        Text(shopData.diagnosticDevice),
      ],
    );
  }

  Widget oilTypeWidget() {
    return Column(
      children: [
        Row(
          children: [
            Icon(Icons.device_thermostat, size: 22, color: Colors.black54,),
            SizedBox(width: 5,),
            Text('취급오일 종류', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black54),),
          ],
        ),
        Text(shopData.oilType),
      ],
    );
  }

  Widget commentWidget() {
    return Column(
      children: [
        Row(
          children: [
            Icon(Icons.comment, size: 22, color: Colors.black54,),
            SizedBox(width: 5,),
            Text('매장소개', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black54),),
          ],
        ),
        Text(shopData.comment),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          '마이샵',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        iconTheme: IconThemeData(
          color: Colors.black, //change your color here
        ),
        actions: [
          PopupMenuButton(
              offset: Offset(0, 45),
              shape: ShapeBorder.lerp(RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
                  RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
                  0),
              icon: Icon(Icons.more_vert),
              itemBuilder: (context) => [
                PopupMenuItem(
                  child: Text("매장정보삭제"),
                  value: 1,
                ),
              ]
          )
        ],
      ),
      body: FutureBuilder<ShopData>(
          future: bringShopData(),
          builder: (context, snapshot) {
            if (!snapshot.hasData)
              return Center(
                child: CircularProgressIndicator(),
              );
            else
              return SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(15),
                  child: Column(
                    children: [
                      photosWidget(),
                      Divider(),
                      addressWidget(),
                      Divider(),
                      contactWidget(),
                      Divider(),
                      diagnosticDeviceWidget(),
                      Divider(),
                      oilTypeWidget(),
                      Divider(),
                      commentWidget(),
                    ],
                  ),
                ),
              );
          }),
      bottomNavigationBar: InkWell(
        onTap: () {
          Get.toNamed('/shop/update', arguments: shopData);
        },
        child: Container(
          padding: EdgeInsets.only(top: 18, bottom: 18),
          //alignment: Alignment.bottomCenter,
          decoration: BoxDecoration(
            color: Colors.black
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('내용수정',style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),),
            ],
          ),
        ),
      ),
    );
  }
}
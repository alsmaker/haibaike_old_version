import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:hibaike/src/controller/multi_image_controller.dart';
import 'package:hibaike/src/controller/shop_info_controller.dart';
import 'package:hibaike/src/controller/sign_controller.dart';
import 'package:hibaike/src/model/shop_data.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class UpdateShop extends StatefulWidget {
  @override
  _UpdateShopState createState() => _UpdateShopState();
}

class _UpdateShopState extends State<UpdateShop> {
  ShopData shopData = Get.arguments;
  final MultiImageController _multiImgCtrl = Get.put(MultiImageController());
  final ShopInfoController _shopInfoCtrl = Get.put(ShopInfoController());
  int maxCount = 5;

  final _shopNameCtrl = TextEditingController();
  final _contactCtrl = TextEditingController();
  final _oilTypeCtrl = TextEditingController();
  final _diagnosticDeviceCtrl = TextEditingController();
  final _commentCtrl = TextEditingController();

  @override
  void initState() {
    bringOriginalData();

    _shopNameCtrl.addListener(() {
      _shopInfoCtrl.setShopName(_shopNameCtrl.text);
    });
    _contactCtrl.addListener(() {
      _shopInfoCtrl.setContact(_contactCtrl.text);
    });
    _oilTypeCtrl.addListener(() {
      _shopInfoCtrl.setOilType(_oilTypeCtrl.text);
    });
    _diagnosticDeviceCtrl.addListener(() {
      _shopInfoCtrl.setDiagnosticDevice(_diagnosticDeviceCtrl.text);
    });
    _commentCtrl.addListener(() {
      _shopInfoCtrl.setComment(_commentCtrl.text);
    });

    _shopInfoCtrl.isOpenPhoneNumber = false;

    super.initState();
  }

  void bringOriginalData() {
    _shopNameCtrl.text = shopData.shopName;
    _contactCtrl.text = shopData.contact;
    _oilTypeCtrl.text = shopData.oilType;
    _diagnosticDeviceCtrl.text = shopData.diagnosticDevice;
    _commentCtrl.text = shopData.comment;

    _shopInfoCtrl.shopName.value = shopData.shopName;
    _shopInfoCtrl.contact.value = shopData.contact;
    _shopInfoCtrl.oilType.value = shopData.oilType;
    _shopInfoCtrl.diagnosticDevice.value = shopData.diagnosticDevice;
    _shopInfoCtrl.comment.value = shopData.comment;

    _shopInfoCtrl.updateImageList.value = List.of(shopData.imageList);
    _shopInfoCtrl.isOpenPhoneNumber = shopData.isOpenPhoneNumber;
    _shopInfoCtrl.address.value = shopData.address;
    _shopInfoCtrl.roadAddress.value = shopData.roadAddress;
    _shopInfoCtrl.addressDetail.value = shopData.addressDetail;
    _shopInfoCtrl.shopLocation.lat = shopData.shopLocation.lat;
    _shopInfoCtrl.shopLocation.lon = shopData.shopLocation.lon;
  }

  @override
  void dispose() {
    _shopNameCtrl.dispose();
    _contactCtrl.dispose();
    _oilTypeCtrl.dispose();
    _diagnosticDeviceCtrl.dispose();
    _commentCtrl.dispose();

    super.dispose();
  }

  Widget imageHeader() {
    return GestureDetector(
      child: Container(
        width: 75,
        //height: 30,
        alignment: Alignment.center,
        margin: EdgeInsets.fromLTRB(0, 10.0, 10.0, 10.0),
        decoration: BoxDecoration(
            border: Border.all(color: Colors.black12),
            borderRadius: BorderRadius.all(Radius.circular(5.0))),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.camera_alt,
              color: Colors.grey,
              size: 30,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${_multiImgCtrl.imageLength.value + _shopInfoCtrl.updateImageList.length}',
                  style: TextStyle(
                      color: (_multiImgCtrl.imageLength.value + _shopInfoCtrl.updateImageList.length) == 0
                          ? Colors.grey
                          : Colors.red),
                ),
                Text(
                  '/$maxCount',
                  style: TextStyle(color: Colors.grey),
                )
              ],
            ),
          ],
        ),
      ),
      onTap: () {
        if(maxCount-_shopInfoCtrl.updateImageList.length > 0)
          _multiImgCtrl.getMultiImage(maxCount-_shopInfoCtrl.updateImageList.length);
        else
          Fluttertoast.showToast(msg: '사진은 5장까지 등록이 가능합니다. 다른 사진을 등록하려면 사진 삭제후 다른 사진을 등록해주세요.');
      },
    );
  }

  Widget imageThumbnail(int index) {
    double thumbnailSize = 75;
    if(index<_shopInfoCtrl.updateImageList.length)
      return Stack(
        children: [
          Container(
            padding: EdgeInsets.only(left: 10, right: 10, bottom: 10, top: 10),
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
                imageUrl: _shopInfoCtrl.updateImageList[index],
                width: thumbnailSize,
                height: thumbnailSize,
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.all(
                Radius.circular(5.0),
              ),
              clipBehavior: Clip.hardEdge,
            ),
          ),
          Positioned(
            right: 3,
            top: 3,
            child: GestureDetector(
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 15,
                ),
              ),
              onTap: () {
                //_multiImgCtrl.removeAtImg(index);
                _shopInfoCtrl.updateImageList.removeAt(index);
              },
            ),
          ),
        ],
      );
    else
    return FutureBuilder<String>(
        future: _multiImgCtrl.loadImageData(index-_shopInfoCtrl.updateImageList.length),
        builder: (context, AsyncSnapshot<String> snapshot) {
          if (!snapshot.hasData) {
            return Container(
                width: 75,
                //alignment: Alignment.center,
                margin: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                ),
                child: Center(child: CircularProgressIndicator()));
          } else
            return Stack(
              children: [
                Container(
                  width: 75,
                  //alignment: Alignment.center,
                  margin: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    image: DecorationImage(
                        fit: BoxFit.cover,
                        image: MemoryImage(_multiImgCtrl.images[index-_shopInfoCtrl.updateImageList.length])),
                  ),
                  //child: Image.memory(_multiImgCtrl.images[index], fit: BoxFit.cover,),
                ),
                Positioned(
                  right: 3,
                  top: 3,
                  child: GestureDetector(
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 15,
                      ),
                    ),
                    onTap: () {
                      _multiImgCtrl.removeAtImg(index-_shopInfoCtrl.updateImageList.length);
                    },
                  ),
                ),
              ],
            );
        });
  }

  Widget photoManageWidget() {
    return Obx(
          () => Container(
        height: 115,
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
        child: ListView.builder(
          //itemCount: _multiImgCtrl.imgFileList.length + 1, // +1 for header image
          itemCount: _shopInfoCtrl.updateImageList.length+ _multiImgCtrl.imageLength.value + 1, // +1 for header image
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            if (index == 0)
              return imageHeader();
            else
              return imageThumbnail(index - 1);
          },
        ),
      ),
    );
  }

  Widget locationWidget() {
    return Obx(() {
      if (_shopInfoCtrl.address.value.length > 0 ||
          _shopInfoCtrl.roadAddress.value.length > 0) {
        return InkWell(
          onTap: () {
            Get.toNamed('/shop/register/location');
          },
          child: Container(
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
                    _shopInfoCtrl.address.value.length > 0
                        ? Text(
                      _shopInfoCtrl.address.value +
                          ' ' +
                          _shopInfoCtrl.addressDetail.value,
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
                    _shopInfoCtrl.roadAddress.value.length > 0
                        ? Expanded(
                      child: Text(
                        _shopInfoCtrl.roadAddress.value +
                            ' ' +
                            _shopInfoCtrl.addressDetail.value,
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
        );
      }
      return InkWell(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_searching,
              size: 17,
            ),
            SizedBox(
              width: 5,
            ),
            Container(
              margin: EdgeInsets.only(top: 15, bottom: 15),
              child: Text(
                "매장 위치를 입력해주세요",
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        onTap: () {
          Get.toNamed('/shop/register/location');
        },
      );
    });

    /*
    return InkWell(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.location_searching, size: 17,),
          SizedBox(width: 5,),
          Container(
            margin: EdgeInsets.only(top: 15, bottom: 15),
            child: Text(
              "매장 위치를 입력해주세요",
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      onTap: () {
        Get.toNamed('/shop/register/location');
      },
    );

     */
  }

  Widget shopNameWidget() {
    return Container(
      child: Column(
        children: [
          Container(
              alignment: Alignment.centerLeft,
              margin: EdgeInsets.only(top: 10, bottom: 10),
              child: Text(
                '상호',
                style: TextStyle(color: Colors.black, fontSize: 18),
              )),
          TextField(
            controller: _shopNameCtrl,
            decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                  borderSide: BorderSide(width: 1, color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                  borderSide: BorderSide(width: 2, color: Colors.red),
                ),
                hintText: '정학한 상호를 입력해주세요',
                hintStyle: TextStyle(color: Colors.grey)),
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.next,
            //focusNode: yearFocus,
            //showCursor: false,
          ),
        ],
      ),
    );
  }

  Widget contactWidget() {
    return Container(
      child: Column(
        children: [
          Container(
              alignment: Alignment.centerLeft,
              margin: EdgeInsets.only(top: 10, bottom: 10),
              child: Row(
                children: [
                  Text(
                    '전화번호',
                    style: TextStyle(color: Colors.black, fontSize: 18),
                  ),
                  Text(
                    '(일반번호가 있는 경우에만 입력해주세요)',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              )),
          TextField(
            controller: _contactCtrl,
            decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                  borderSide: BorderSide(width: 1, color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                  borderSide: BorderSide(width: 2, color: Colors.red),
                ),
                hintText: '000-000-0000',
                hintStyle: TextStyle(color: Colors.grey)),
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            //focusNode: yearFocus,
            //showCursor: false,
          ),
          Row(
            children: [
              Checkbox(
                //checkColor: Colors.black,
                  value: _shopInfoCtrl.isOpenPhoneNumber,
                  onChanged: (value) {
                    setState(() {
                      _shopInfoCtrl.isOpenPhoneNumber = value;
                    });
                  }),
              Text(
                '휴대폰 번호 공개',
                style: TextStyle(color: Colors.black, fontSize: 18),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget oilTypeWidget() {
    return Container(
      child: Column(
        children: [
          Container(
              alignment: Alignment.centerLeft,
              margin: EdgeInsets.only(top: 10, bottom: 10),
              child: Text(
                '취급 엔진오일 종류',
                style: TextStyle(color: Colors.black, fontSize: 18),
              )),
          TextField(
            controller: _oilTypeCtrl,
            decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                  borderSide: BorderSide(width: 1, color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                  borderSide: BorderSide(width: 2, color: Colors.red),
                ),
                hintText: '멕시마오일, 쉘어드밴스',
                hintStyle: TextStyle(color: Colors.grey)),
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.next,
            //focusNode: yearFocus,
            //showCursor: false,
          ),
        ],
      ),
    );
  }

  Widget diagnosticDeviceWidget() {
    return Container(
      child: Column(
        children: [
          Container(
              alignment: Alignment.centerLeft,
              margin: EdgeInsets.only(top: 10, bottom: 10),
              child: Text(
                '보유 진단기 종류',
                style: TextStyle(color: Colors.black, fontSize: 18),
              )),
          TextField(
            controller: _diagnosticDeviceCtrl,
            decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                  borderSide: BorderSide(width: 1, color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                  borderSide: BorderSide(width: 2, color: Colors.red),
                ),
                hintText: '혼다, 야마하, BMW, 울트라',
                hintStyle: TextStyle(color: Colors.grey)),
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.next,
            //focusNode: yearFocus,
            //showCursor: false,
          ),
        ],
      ),
    );
  }

  Widget commentWidget() {
    return Container(
      child: Column(
        children: [
          Container(
              alignment: Alignment.centerLeft,
              margin: EdgeInsets.only(top: 10, bottom: 10),
              child: Text(
                '마이샵 정보',
                style: TextStyle(color: Colors.black, fontSize: 18),
              )),
          TextField(
            controller: _commentCtrl,
            decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                  borderSide: BorderSide(width: 1, color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                  borderSide: BorderSide(width: 2, color: Colors.red),
                ),
                hintText: '매장 홍보 내용을 입력해주세요',
                hintStyle: TextStyle(color: Colors.grey)),
            keyboardType: TextInputType.multiline,
            maxLines: null,
            minLines: 10,
            //textInputAction: TextInputAction.next,
            //focusNode: yearFocus,
            //showCursor: false,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          '매장정보 등록',
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(15),
          child: Column(
            children: [
              photoManageWidget(),
              Divider(
                height: 10,
              ),
              locationWidget(),
              Divider(
                height: 10,
              ),
              shopNameWidget(),
              Divider(
                height: 10,
              ),
              contactWidget(),
              Divider(
                height: 10,
              ),
              oilTypeWidget(),
              Divider(
                height: 10,
              ),
              diagnosticDeviceWidget(),
              Divider(
                height: 10,
              ),
              commentWidget(),
            ],
          ),
        ),
      ),
      // 하단 : 등록 / 초기화 bottom navigation button
      bottomNavigationBar: Container(
        height: 65,
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.black12)),
        ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 8, 10),
              child: GestureDetector(
                child: Container(
                  alignment: Alignment.center,
                  width: MediaQuery.of(context).size.width / 3,
                  child: Text(
                    '초기화',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  ),
                ),
                onTap: () {
                  _multiImgCtrl.reset();
                  _shopInfoCtrl.reset();
                  _shopNameCtrl.text = '';
                  _contactCtrl.text = '';
                  _oilTypeCtrl.text = '';
                  _diagnosticDeviceCtrl.text = '';
                  _commentCtrl.text = '';
                },
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 10, 10),
                child: GestureDetector(
                  child: Container(
                    alignment: Alignment.center,
                    child: Text(
                      '수정된 정보 등록',
                      style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    ),
                  ),
                  onTap: () async {
                    if(shopInfoValidate())
                      Get.dialog(
                          registerShopWithDialog()
                      );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future updateShopData() async {
    print('매장정보 수정');
    SignController signController = Get.find();
    String shopFolderName = signController.currentUser.value.shopId;
    List<String> multiImageList = [];
    List<String> mergeImageList = [];

    List<String> diff = [];
    if(listEquals(shopData.imageList, _shopInfoCtrl.updateImageList)) {
      print('list equal');
    }
    else {
      diff = shopData.imageList
          .where(
              (element) => !_shopInfoCtrl.updateImageList.contains(element))
          .toList();
      print(diff.toString());
    }

    // todo 1 :  diff 리스트의 이미지 삭제
    if(diff.length > 0) {
      diff.forEach((url) {
        firebase_storage.FirebaseStorage.instance.refFromURL(url).delete();
        // FirebaseFirestore.instance.collection('bikes').doc(shopFolderName).update(
        // {
        //   'imageList': FieldValue.arrayRemove([url])
        // });
      });
    }

    if(_multiImgCtrl.imageLength > 0) {
      multiImageList = await _multiImgCtrl.shopImagesToStorage(shopFolderName);
    }

    if(_multiImgCtrl.imageLength > 0)
      mergeImageList = List.from(_shopInfoCtrl.updateImageList)..addAll(multiImageList);
    else
      mergeImageList = List.of(_shopInfoCtrl.updateImageList);

    _shopInfoCtrl.registerShopInfoToFireStore(mergeImageList, shopFolderName);

    // if(signController.currentUser.value.grade == 'individual')
    //   await signController.updateUserGrade('business');
    // await signController.updateShopId(shopFolderName);


    return 'update done';
  }

  Widget registerShopWithDialog() {
    return FutureBuilder(
        future: updateShopData(),
        builder: (context, snapshot) {
          if(snapshot.hasData) {
            SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
              Get.offNamedUntil('/myPage', (route)=>false);
              //Get.offAllNamed('/');
            });

            return Container();
          }
          else
            return Center(child: CircularProgressIndicator());
        }
    );
  }

  bool shopInfoValidate() {
    if ((_multiImgCtrl.images.length + _shopInfoCtrl.updateImageList.length) == 0) {
      Fluttertoast.showToast(msg: '사진은 한장이상 등록이 필수입니다');
      return false;
    }
    if (_shopInfoCtrl.shopName.value.length == 0) {
      Fluttertoast.showToast(msg: '상호를 입력해주세요');
      return false;
    }
    if(_shopInfoCtrl.address.value.length == 0 && _shopInfoCtrl.roadAddress.value.length == 0) {
      Fluttertoast.showToast(msg: '매장위치를 입력해주세요');
      return false;
    }
    return true;
  }
}
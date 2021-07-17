import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:hibaike/src/controller/multi_image_controller.dart';
import 'package:hibaike/src/controller/shop_info_controller.dart';
import 'package:hibaike/src/controller/sign_controller.dart';

class RegisterShopEntry extends StatefulWidget {
  @override
  _RegisterShopEntryState createState() => _RegisterShopEntryState();
}

class _RegisterShopEntryState extends State<RegisterShopEntry> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InkWell(
              onTap: () {
                Get.toNamed('/shop/register');
              },
                child: Icon(
              Icons.add_circle_outline,
              color: Colors.grey,
              size: 80,
            )),
            SizedBox(height: 20,),
            Text('등록된 매장 정보가 없습니다', style: TextStyle(fontSize: 16),),
            SizedBox(height: 5,),
            Text('마이샵을 동록하고 우리 매장 위치와 정보를 홍보해보세요'),
            SizedBox(height: 15,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.info_outline, color: Colors.red, size: 18,),
                SizedBox(width: 5,),
                Text('개인 사용자는 3대까지 무료로 등록 가능합니다', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),),
              ],
            ),
            SizedBox(height: 5,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.info_outline, color: Colors.red, size: 18,),
                SizedBox(width: 5,),
                Text('매장정보를 등록하고 추가 등록해 주세요', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


class RegisterShop extends StatefulWidget {
  @override
  _RegisterShopState createState() => _RegisterShopState();
}

class _RegisterShopState extends State<RegisterShop> {
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
                  '${_multiImgCtrl.imageLength.value}',
                  style: TextStyle(
                      color: _multiImgCtrl.imageLength.value == 0
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
        _multiImgCtrl.getMultiImage(maxCount);
      },
    );
  }

  Widget imageThumbnail(int index) {
    return FutureBuilder<String>(
        future: _multiImgCtrl.loadImageData(index),
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
                        image: MemoryImage(_multiImgCtrl.images[index])),
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
                      _multiImgCtrl.removeAtImg(index);
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
          itemCount: _multiImgCtrl.imageLength.value + 1, // +1 for header image
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
                      '매장정보등록',
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

  Future registerShopData() async {
    print('매장정보 등록');
    String shopFolderName = 'shop-${DateTime.now().millisecondsSinceEpoch.toString()}';
    List<String> imageList = await _multiImgCtrl.shopImagesToStorage(shopFolderName);
    _shopInfoCtrl.registerShopInfoToFireStore(imageList, shopFolderName);
    SignController signController = Get.find();
    if(signController.currentUser.value.grade == 'individual')
      await signController.updateUserGrade('business');
    await signController.updateShopId(shopFolderName);


    return 'update done';
  }

  Widget registerShopWithDialog() {
    return FutureBuilder(
        future: registerShopData(),
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
    if (_multiImgCtrl.images.length == 0) {
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

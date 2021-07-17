import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:hibaike/src/component/currency_input_formmatter.dart';
import 'package:hibaike/src/component/db_manager.dart';
import 'package:hibaike/src/controller/bike_data_controller.dart';
import 'package:hibaike/src/controller/multi_image_controller.dart';
import 'package:hibaike/src/model/bike.dart';

class UpdateBike extends StatefulWidget {
  @override
  _UpdateBikeState createState() => _UpdateBikeState();
}

class _UpdateBikeState extends State<UpdateBike> {
  DocumentSnapshot ds = Get.arguments;
  BikeData bikeData;
  final MultiImageController _multiImgCtrl = Get.put(MultiImageController());
  final BikeDataController _bikeDataCtrl = Get.put(BikeDataController());

  final _yearCtrl = TextEditingController();
  final _mileageCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _commentCtrl = TextEditingController();
  FocusNode yearFocus, mileageFocus, amountFocus;

  @override
  void initState() {
    bikeData = BikeData.fromJson(ds.data());

    bringOriginalData();

    _yearCtrl.addListener(() {
      _bikeDataCtrl.setBirthYear(_yearCtrl.text);
    });
    _mileageCtrl.addListener(() {
      _bikeDataCtrl.setMilage(_mileageCtrl.text);
    });
    _amountCtrl.addListener(() {
      _bikeDataCtrl.setAmount(_amountCtrl.text);
    });
    _commentCtrl.addListener(() {
      _bikeDataCtrl.setComment(_commentCtrl.text);
    });

    yearFocus = FocusNode();
    mileageFocus = FocusNode();
    amountFocus = FocusNode();

    super.initState();
  }

  bringOriginalData() {
    _yearCtrl.text = bikeData.birthYear.toString();
    _mileageCtrl.text = bikeData.mileage.toString();
    _amountCtrl.text = bikeData.amount.toString();
    _commentCtrl.text = bikeData.comment;

    _bikeDataCtrl.birthYear = bikeData.birthYear.toString();
    _bikeDataCtrl.mileage = bikeData.mileage.toString();
    _bikeDataCtrl.amount = bikeData.amount.toString();
    _bikeDataCtrl.comment = bikeData.comment;

    _bikeDataCtrl.manufacturer.value = bikeData.manufacturer;
    _bikeDataCtrl.model.value = bikeData.model;
    _bikeDataCtrl.displacement.value = bikeData.displacement;

    _bikeDataCtrl.location.lat = bikeData.location.lat;
    _bikeDataCtrl.location.lon = bikeData.location.lat;
    _bikeDataCtrl.locationLevel0.value = bikeData.locationLevel0;
    _bikeDataCtrl.locationLevel1.value = bikeData.locationLevel1;
    _bikeDataCtrl.locationLevel2.value = bikeData.locationLevel2;

    _bikeDataCtrl.isTuned.value = bikeData.isTuned;
    _bikeDataCtrl.possibleAS.value = bikeData.possibleAS;

    _bikeDataCtrl.updateImageList.value = List.of(bikeData.imageList);
  }

  @override
  void dispose() {
    super.dispose();

    _yearCtrl.dispose();
    _mileageCtrl.dispose();
    _amountCtrl.dispose();
    _bikeDataCtrl.dispose();

    yearFocus.dispose();
    mileageFocus.dispose();
    amountFocus.dispose();
  }

  Widget imageHeader() {
    int maxCount = 10;
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
            Icon(Icons.camera_alt, color: Colors.grey, size: 30,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //Text('${_multiImgCtrl.imgFileList.length}',
                //style: TextStyle(color: _multiImgCtrl.imgFileList.length==0 ? Colors.grey : Colors.blue),),
                Text('${_multiImgCtrl.images.length + _bikeDataCtrl.updateImageList.length}',
                  style: TextStyle(
                      color: (_multiImgCtrl.images.length +
                                  _bikeDataCtrl.updateImageList.length) == 0
                          ? Colors.grey : Colors.red),
                ),

                Text('/$maxCount', style: TextStyle(color: Colors.grey),)
              ],
            ),
          ],
        ),
      ),
      onTap: (){
        _multiImgCtrl.getMultiImage(maxCount-_bikeDataCtrl.updateImageList.length);
      },
    );
  }

  Widget imageThumbnail(int index) {
    double thumbnailSize = 75;
    if(index < _bikeDataCtrl.updateImageList.length) {
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
                imageUrl: _bikeDataCtrl.updateImageList[index],
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
                _bikeDataCtrl.updateImageList.removeAt(index);
              },
            ),
          ),
        ],
      );
    } else {
      return Stack(
        children: [
          Container(
            width: 75,
            //alignment: Alignment.center,
            margin: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(5.0)),
              image: DecorationImage(
                  fit: BoxFit.fill,
                  image: MemoryImage(_multiImgCtrl.images[index-_bikeDataCtrl.updateImageList.length])
              ),
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
                _multiImgCtrl.removeAtImg(index-_bikeDataCtrl.updateImageList.length);
              },
            ),
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('내바이크 등록', style: TextStyle(color: Colors.black),),
        iconTheme: IconThemeData(
            color: Colors.black
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.0),
          child: Column(
            children: [
              Obx(()=>Container(
                height: 115,
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                child: ListView.builder(
                  itemCount: _multiImgCtrl.images.length + 1 + _bikeDataCtrl.updateImageList.length, // +1 for header image
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    if (index == 0)
                      return imageHeader();
                    else {
                      return imageThumbnail(index - 1);
                    }
                  },
                ),
              ),
              ),
              Divider(height: 10,),
              Obx(() {
                // 제조사와 모델이 선택이 되어 있지 않을때
                if ((_bikeDataCtrl.manufacturer.value == null) ||
                    (_bikeDataCtrl.model.value == null) ||
                    (_bikeDataCtrl.manufacturer.value.length == 0) ||
                    (_bikeDataCtrl.model.value.length == 0))
                  return InkWell(
                    child: Container(
                      height: 50,
                      alignment: Alignment.centerLeft,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('제조사/모델 선택', style: TextStyle(
                              color: Colors.grey),),
                          Icon(
                            Icons.arrow_forward_ios_rounded, color: Colors.grey,
                            size: 18,)
                        ],
                      ),
                    ),
                    onTap: () {
                      Get.toNamed("/manufacturer", arguments: '/update_bike');
                    },
                  );
                else
                  return InkWell(
                    child: Container(
                      height: 50,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${_bikeDataCtrl.manufacturer}  •  ${_bikeDataCtrl.model}  •  ${_bikeDataCtrl.displacement.toString()}cc',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),),
                          Icon(
                            Icons.arrow_forward_ios_rounded, color: Colors.black,
                            size: 18,)
                        ],
                      ),
                    ),
                    onTap: () {
                      Get.toNamed("/manufacturer", arguments: '/update_bike');
                    },
                  );
              }
              ),
              Divider(height: 10,),
              Obx(() {
                if((_bikeDataCtrl.locationLevel0.value == null) ||
                    (_bikeDataCtrl.locationLevel0.value.length == 0) ||
                    (_bikeDataCtrl.locationLevel0.value == null) ||
                    (_bikeDataCtrl.locationLevel0.value.length == 0)) {
                  return InkWell(
                    child: Container(
                      height: 50,
                      alignment: Alignment.centerLeft,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '판매지역',
                            style: TextStyle(color: Colors.grey),
                          ),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: Colors.grey,
                            size: 18,
                          )
                        ],
                      ),
                    ),
                    onTap: () {
                      Get.toNamed("/location", arguments: '/update_bike');
                    },
                  );
                }
                else {
                  return InkWell(
                    child: Container(
                      height: 50,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${_bikeDataCtrl.locationLevel0} ${_bikeDataCtrl.locationLevel1} ${_bikeDataCtrl.locationLevel2}',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),),
                          Icon(
                            Icons.arrow_forward_ios_rounded, color: Colors.black,
                            size: 18,)
                        ],
                      ),
                    ),
                    onTap: () {
                      Get.toNamed("/location", arguments: '/update_bike');
                    },
                  );
                }
              }),
              Divider(height: 10,),
              Container(
                height: 50,
                child: Row(
                  children: [
                    Container(
                        width: 80,
                        child: Text('연식', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),)
                    ),
                    Expanded(
                      child: TextField(
                        controller: _yearCtrl,
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: '예) 2021',
                            hintStyle: TextStyle(color: Colors.grey)
                        ),
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        focusNode: yearFocus,
                        //showCursor: false,
                      ),
                    ),
                    Text('년'),
                  ],
                ),
              ),
              Container(
                height: 50,
                child: Row(
                  children: [
                    Container(
                        width: 80,
                        child: Text('주행거리', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),)
                    ),
                    Expanded(
                      child: TextField(
                        controller: _mileageCtrl,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: '예) 30,000',
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        focusNode: mileageFocus,
                        inputFormatters: [
                          CurrencyInputFormatter()
                        ],
                      ),
                    ),
                    Text('KM'),
                  ],
                ),
              ),
              Container(
                height: 50,
                child: Row(
                  children: [
                    Container(
                        width: 80,
                        child: Text('판매가격', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),)
                    ),
                    Expanded(
                      child: TextField(
                        controller: _amountCtrl,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: '예) 1,500',
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.done,
                        focusNode: amountFocus,
                        inputFormatters: [
                          CurrencyInputFormatter()
                        ],
                      ),
                    ),
                    Text('만원'),
                  ],
                ),
              ),
              Divider(height: 10,),
              Container(
                height: 50,
                child: Row(
                  children: [
                    Container(
                      width: 80,
                      child: Text('튜닝사항', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),),
                    ),
                    Expanded(
                      child: Container(
                        //alignment: Alignment.center,
                        child: Row(
                          children: [
                            Obx(
                                  () => GestureDetector(
                                child: Container(
                                  width: (MediaQuery.of(context).size.width - 130) / 2,
                                  height: 30,
                                  //margin: EdgeInsets.all(0),
                                  padding: EdgeInsets.all(7),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color:
                                    _bikeDataCtrl.isTuned.value == "TUNED"
                                        ? Colors.red
                                        : Colors.white,
                                    border: Border.all(
                                        color: Colors.red,
                                        // set border color
                                        width: 1.2), // set border width
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(
                                            30.0)), // set rounded corner radius
                                  ),
                                  child: Text(
                                    '있음',
                                    style: TextStyle(
                                      color:
                                      _bikeDataCtrl.isTuned.value == "TUNED"
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                ),
                                onTap: () {
                                  _bikeDataCtrl.isTuned('TUNED');
                                },
                              ),
                            ),
                            SizedBox(width: 15,),
                            Obx(
                                  () => GestureDetector(
                                child: Container(
                                  width: (MediaQuery.of(context).size.width - 130) / 2,
                                  height: 30,
                                  //margin: EdgeInsets.all(0),
                                  padding: EdgeInsets.all(7),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color:
                                    _bikeDataCtrl.isTuned.value == "NO_TUNED"
                                        ? Colors.red
                                        : Colors.white,
                                    border: Border.all(
                                        color: Colors.red,
                                        // set border color
                                        width: 1.2), // set border width
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(
                                            30.0)), // set rounded corner radius
                                  ),
                                  child: Text(
                                    '없음',
                                    style: TextStyle(
                                      color:
                                      _bikeDataCtrl.isTuned.value == "NO_TUNED"
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                ),
                                onTap: () {
                                  _bikeDataCtrl.isTuned('NO_TUNED');
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 50,
                child: Row(
                  children: [
                    Container(
                      width: 80,
                      child: Text('A/S', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),),
                    ),
                    Expanded(
                      child: Container(
                        //alignment: Alignment.center,
                        child: Row(
                          children: [
                            Obx(
                                  () => GestureDetector(
                                child: Container(
                                  width: (MediaQuery.of(context).size.width - 130) / 2,
                                  height: 30,
                                  //margin: EdgeInsets.all(0),
                                  padding: EdgeInsets.all(7),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color:
                                    _bikeDataCtrl.possibleAS.value == "POSSIBLE"
                                        ? Colors.red
                                        : Colors.white,
                                    border: Border.all(
                                        color: Colors.red,
                                        // set border color
                                        width: 1.2), // set border width
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(
                                            30.0)), // set rounded corner radius
                                  ),
                                  child: Text(
                                    '가능',
                                    style: TextStyle(
                                      color:
                                      _bikeDataCtrl.possibleAS.value == "POSSIBLE"
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                ),
                                onTap: () {
                                  _bikeDataCtrl.possibleAS('POSSIBLE');
                                },
                              ),
                            ),
                            SizedBox(width: 15,),
                            Obx(
                                  () => GestureDetector(
                                child: Container(
                                  width: (MediaQuery.of(context).size.width - 130) / 2,
                                  height: 30,
                                  //margin: EdgeInsets.all(0),
                                  padding: EdgeInsets.all(7),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color:
                                    _bikeDataCtrl.possibleAS.value == "IMPOSSIBLE"
                                        ? Colors.red
                                        : Colors.white,
                                    border: Border.all(
                                        color: Colors.red,
                                        // set border color
                                        width: 1.2), // set border width
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(
                                            30.0)), // set rounded corner radius
                                  ),
                                  child: Text(
                                    '불가능',
                                    style: TextStyle(
                                      color:
                                      _bikeDataCtrl.possibleAS.value == "IMPOSSIBLE"
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                ),
                                onTap: () {
                                  _bikeDataCtrl.possibleAS('IMPOSSIBLE');
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(height: 10,),
              // comment
              Container(
                //height: 50,
                //child:
                //Expanded(
                child: TextField(
                  controller: _commentCtrl,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: '내 바이크에 대한 설명을 작성해주세요\n운행용도, 튜닝사항, 사고유무 등등\n구매자에게 내 바이크를 어필해보세요',
                    hintStyle: TextStyle(color: Colors.grey),
                  ),
                  keyboardType: TextInputType.multiline,
                  //textInputAction: TextInputAction.next,
                  maxLines: null,
                  minLines: 10,
                  //showCursor: false,
                ),
                //),
              ),
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
                  child: Text('초기화', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  ),
                ),
                onTap: () {
                  _multiImgCtrl.reset();
                  _bikeDataCtrl.reset();
                  _yearCtrl.text = '';
                  _mileageCtrl.text = '';
                  _amountCtrl.text = '';
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
                    child: Text('바이크등록', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    ),
                  ),
                  onTap: () {
                    //if(bikeFieldValidate())
                    //  Get.toNamed('/register/progressStore');
                    Get.dialog(
                      updateDialog()
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

  Future updateBikeData() async {
    final dbManager = DBManager();
    List<String> diff = [];
    if(listEquals(bikeData.imageList, _bikeDataCtrl.updateImageList)) {
      print('list equal');
    }
    else {
      diff = bikeData.imageList
          .where(
              (element) => !_bikeDataCtrl.updateImageList.contains(element))
          .toList();
      print(diff.toString());
    }

    await dbManager.updateImageList(diff, ds.id);


    FirebaseFirestore.instance.collection('bikes').doc(ds.id).update(

        {
          "manufacturer": _bikeDataCtrl.manufacturer.value,
          "model": _bikeDataCtrl.model.value,
          "displacement": _bikeDataCtrl.displacement.value,
          "birthYear": int.parse(_bikeDataCtrl.birthYear),
          "mileage": int.parse(_bikeDataCtrl.mileage),
          "amount": int.parse(_bikeDataCtrl.amount),
          "locationLevel0": _bikeDataCtrl.locationLevel0.value,
          "locationLevel1": _bikeDataCtrl.locationLevel1.value,
          "locationLevel2": _bikeDataCtrl.locationLevel2.value,
          "location.lat": _bikeDataCtrl.location.lat,
          "location.lon": _bikeDataCtrl.location.lon,
          "isTuned": _bikeDataCtrl.isTuned.value,
          "possibleAS": _bikeDataCtrl.possibleAS.value,
          "comment": _bikeDataCtrl.comment,
          // todo
          "imageList": _bikeDataCtrl.updateImageList,
        }

    );
    return 'update done';
  }

  Widget updateDialog() {
    return FutureBuilder(
        future: updateBikeData(),
        builder: (context, snapshot) {
          if(snapshot.hasData) {
            SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
              Get.offNamedUntil('/salesListView', (route)=>false);
              //Get.offAllNamed('/');
            });

            return Container();
          }
          else
            return Center(child: CircularProgressIndicator());
        }
    );
  }
}
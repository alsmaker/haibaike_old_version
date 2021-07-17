import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:hibaike/src/component/bike_list_tile.dart';
import 'package:hibaike/src/controller/load_bike_controller.dart';
import 'package:hibaike/src/model/manufacturer_model.dart';

class BikeListView extends StatefulWidget {
  BikeListView({Key key}) : super(key: key);

  @override
  _BikeListViewState createState() => _BikeListViewState();
}

class _BikeListViewState extends State<BikeListView> {
  final LoadBikeController controller = Get.put(LoadBikeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          controller: controller.scrollController,
          slivers: [
            SliverAppBar(
              iconTheme: IconThemeData(
                color: Colors.black, //change your color here
              ),
              backgroundColor: Colors.transparent,
              title: Container(
                child: Row(
                  children: [
                    Expanded(child: Text("바이크", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),),),
                    PopupMenuButton(
                        offset: Offset(0, 35),
                        shape: ShapeBorder.lerp(RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
                            RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
                            0),
                        itemBuilder: (BuildContext context) {
                          return controller.sortingOptions.map((menu) {
                              print(menu);
                              var index =
                                  controller.sortingOptions.indexOf(menu);
                              if(index == controller.sortIndex.value)
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
                          controller.setSortIndex(value);
                        },
                        child: Obx(() => Container(
                          padding: EdgeInsets.fromLTRB(8, 3, 1, 3),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(5)),
                              border: Border.all(color: Colors.black54)
                            ),
                            child: Row(
                              children: [
                                Text(
                                  controller.sortingOptions[controller.sortIndex.value],
                                  style: TextStyle(
                                      color: Colors.black54, fontSize: 12),
                                ),
                                Icon(Icons.expand_more, color: Colors.black54, size: 18,)
                              ],
                            ),
                        ),),
                      ),
                    SizedBox(width: 10,),
                    GestureDetector(
                      onTap: () {
                        Get.toNamed('/view/filter', arguments: controller);
                      },
                      child:
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6.0),
                            child: Container(
                              width: 22,
                              height: 22,
                              child: SvgPicture.asset('assets/icons/filter1.svg',
                                  color: Colors.black54),
                            ),
                          ),
                    ),
                  ],
                ),
              ),
              floating: true,
              snap: true,
            ),
            GetBuilder<LoadBikeController>(builder: (controller) {
              print('list getbuilder');
              return SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  return GestureDetector(
                    onTap: () {
                      Get.toNamed('/view/detail',
                          //'/profiletest',
                          arguments: controller.bikeDataList[index]);
                    },
                    child: (controller == null ||
                        controller.bikeDataList.length == 0)
                        ? null
                        : BikeListTile(
                        bikeData: controller.bikeDataList[index]),
                  );
                },
                    childCount: (controller == null ||
                        controller.bikeDataList.length == 0)
                        ? 0
                        : controller.bikeDataList.length),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class Filter extends StatefulWidget {
  @override
  _FilterState createState() => _FilterState();
}

class _FilterState extends State<Filter> {

  LoadBikeController loadBikeController = Get.arguments;

  @override
  void initState() {
    super.initState();

    loadBikeController.setMilageText(loadBikeController.milageRange.value);
    loadBikeController.adjustAmountText(loadBikeController.amountRange.value);
  }

  Widget chipCompnayModelButton(String value) {
    return Container(
      width: 110,
      padding: EdgeInsets.all(0),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
            color: Colors.grey, // set border color
            width: 1.2), // set border width
        borderRadius: BorderRadius.all(
            Radius.circular(30.0)), // set rounded corner radius
      ),
      child: Text(value,
          style: TextStyle(color: Colors.grey, fontSize: 12)),
    );
  }

  Widget displacementFilter() {
    return Column(
      children: [
        Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
            child: Text(
              '배기량',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            )),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Obx(()=>GestureDetector(
              onTap: () {
                if(loadBikeController.displacementSwitch[0])
                  loadBikeController.displacementSwitch[0] = false;
                else
                  loadBikeController.displacementSwitch[0] = true;
              },
              child: Container(
                width: MediaQuery.of(context).size.width/3-15,//110,
                //margin: EdgeInsets.all(0),
                padding: EdgeInsets.all(7),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color:
                  Get.find<LoadBikeController>().displacementSwitch[0]
                      ? Colors.red
                      : Colors.white,
                  border: Border.all(
                      color: Get.find<LoadBikeController>()
                          .displacementSwitch[0]
                          ? Colors.red
                          : Colors.red, // set border color
                      width: 1.2), // set border width
                  borderRadius: BorderRadius.all(
                      Radius.circular(30.0)), // set rounded corner radius
                  //boxShadow: [BoxShadow(blurRadius: 10,color: Colors.black,offset: Offset(1,3))]// make rounded corner of border
                ),
                child: Text(
                  "125cc이하",
                  style: TextStyle(
                    color: Get.find<LoadBikeController>().displacementSwitch[0]
                        ? Colors.white
                        : Colors.black,
                    fontSize: 13,
                    fontWeight: Get.find<LoadBikeController>().displacementSwitch[0]
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
            ),),
            Obx(()=>GestureDetector(
              onTap: () {
                if(loadBikeController.displacementSwitch[1])
                  loadBikeController.displacementSwitch[1] = false;
                else
                  loadBikeController.displacementSwitch[1] = true;
              },
              child: Container(
                width: MediaQuery.of(context).size.width/3-15,//110,
                //margin: EdgeInsets.all(0),
                padding: EdgeInsets.all(7),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color:
                  Get.find<LoadBikeController>().displacementSwitch[1]
                      ? Colors.red
                      : Colors.white,
                  border: Border.all(
                      color: Get.find<LoadBikeController>()
                          .displacementSwitch[1]
                          ? Colors.red
                          : Colors.red, // set border color
                      width: 1.2), // set border width
                  borderRadius: BorderRadius.all(
                      Radius.circular(30.0)), // set rounded corner radius
                  //boxShadow: [BoxShadow(blurRadius: 10,color: Colors.black,offset: Offset(1,3))]// make rounded corner of border
                ),
                child: Text(
                  "500cc이하",
                  style: TextStyle(
                    color: Get.find<LoadBikeController>().displacementSwitch[1]
                        ? Colors.white
                        : Colors.black,
                    fontSize: 13,
                    fontWeight: Get.find<LoadBikeController>().displacementSwitch[1]
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
            ),),
            Obx(()=>GestureDetector(
              onTap: () {
                if(loadBikeController.displacementSwitch[2])
                  loadBikeController.displacementSwitch[2] = false;
                else
                  loadBikeController.displacementSwitch[2] = true;
              },
              child: Container(
                width: MediaQuery.of(context).size.width/3-15,//110,
                //margin: EdgeInsets.all(0),
                padding: EdgeInsets.all(7),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color:
                  Get.find<LoadBikeController>().displacementSwitch[2]
                      ? Colors.red
                      : Colors.white,
                  border: Border.all(
                      color: Get.find<LoadBikeController>()
                          .displacementSwitch[2]
                          ? Colors.red
                          : Colors.red, // set border color
                      width: 1.2), // set border width
                  borderRadius: BorderRadius.all(
                      Radius.circular(30.0)), // set rounded corner radius
                  //boxShadow: [BoxShadow(blurRadius: 10,color: Colors.black,offset: Offset(1,3))]// make rounded corner of border
                ),
                child: Text(
                  "500cc이상",
                  style: TextStyle(
                    color: Get.find<LoadBikeController>().displacementSwitch[2]
                        ? Colors.white
                        : Colors.black,
                    fontSize: 13,
                    fontWeight: Get.find<LoadBikeController>().displacementSwitch[2]
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
            ),),
          ],
        ),
      ],
    );
  }

  Widget amountFilter() {
    return Column(
      children: [
        Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
            child: Text(
              '판매가격',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            )),
        Container(
          height: 17.0,
          alignment: Alignment.center,
          padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
          child: Obx(()=>Text(loadBikeController.amountText.value,
            style: TextStyle(fontSize: 12, color: Colors.black),
          )),
        ),
        Obx(()=>RangeSlider(
            divisions: 25,
            activeColor: Colors.black.withOpacity(0.8),
            inactiveColor: Colors.black12,
            min: 0,
            max: 2500,
            values: loadBikeController.amountRange.value,
            onChanged: (value) {
              loadBikeController.amountRange.value = value;
              loadBikeController.adjustAmountText(value);
            }),
        ),
      ],
    );
  }

  Widget mileageFilter() {
    return Column(
      children: [
        Container(
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
          child: Text(
            '주행거리',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
          //color: Colors.white,
        ),
        Container(
          height: 17.0,
          alignment: Alignment.center,
          padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
          child: Obx(()=>Text(loadBikeController.milageText.value,
            style: TextStyle(fontSize: 12, color: Colors.black),
          )),
        ),
        Obx(()=>RangeSlider(
            divisions: 13,
            activeColor: Colors.black.withOpacity(0.8),
            inactiveColor: Colors.black12,
            min: 0,
            max: 130000,
            values: loadBikeController.milageRange.value,
            onChanged: (value) {
              loadBikeController.milageRange.value = value;
              loadBikeController.setMilageText(value);
            }),
        ),
      ],
    );
  }

  Widget modelListFilter() {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            if( (loadBikeController.companyModel.length) < 5)
              Get.toNamed('/view/filter/company', arguments: loadBikeController);
            else
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                      title: Text('5개까지 선택가능'),
                      content: Text("선택된 모델을 삭제후 시도해 주세요"),
                      actions: <Widget>[
                        ElevatedButton(
                          child: Text('OK'),
                          onPressed: () {
                            Navigator.pop(context, "OK");
                          },
                        ),
                      ]);
                },
              );
          },
          child: Obx(() => Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
            child: Row(
              children: [
                Text(
                  '제조사/모델',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 5,),
                Text(
                  '(${loadBikeController.companyModel.length.toString()}/5)',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),),
        ),
        Obx(()=>Container(
          alignment: Alignment.centerLeft,
          height: 30,
          child: ListView.builder(
            itemCount: loadBikeController.companyModel.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: (){
                  loadBikeController.companyModel.remove(loadBikeController.companyModel[index]);
                },
                child: Container(
                  margin: EdgeInsets.fromLTRB(0,0,8,0),
                  padding: EdgeInsets.symmetric(horizontal: 11.0),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    /*border: Border.all(
                            color: Colors.grey, // set border color
                            width: 1.2), // set border width*/
                    borderRadius: BorderRadius.all(
                        Radius.circular(30.0)), // set rounded corner radius
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 14,
                      ),
                      SizedBox(width: 5),
                      Text(loadBikeController.companyModel[index],
                          style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              );
            },
            scrollDirection: Axis.horizontal,
          ),
        ),),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Get.put(LoadBikeController());
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.close,
            color: Colors.black,
          ),
          onPressed: () {
            Get.back();
          },
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('필터', style: TextStyle(color: Colors.black),),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // paddingSymmetric(horizontal: 30),
            displacementFilter(),
            Divider(height: 30,),
            modelListFilter(),
            Divider(height: 30,),
            modelListFilter(),
            Divider(height: 30,),
            amountFilter(),
            Divider(height: 30,),
            mileageFilter(),
          ],
        ),
      ),
      floatingActionButton:
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.3,
            child: FloatingActionButton.extended(
                onPressed: (){
                  loadBikeController.resetFilter();
                },
                heroTag: 'reset',
                label: Text('초기화', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),),
              backgroundColor: Colors.red,
            ),
          ),
          SizedBox(width: 20,),
          Container(
            width: MediaQuery.of(context).size.width * 0.4,
            child: FloatingActionButton.extended(
                onPressed: (){
                  loadBikeController.makeElasticQuery();
                  //Get.until((route) => Get.currentRoute == '/view/filter');
                  Get.back();
                },
                heroTag: 'filter',
                label: Text('검색', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),),
              backgroundColor: Colors.black
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

List<ManufacturerNModel> parseModelSpec(String companyJson) {
  final parsed = json.decode(companyJson).cast<Map<String, dynamic>>();
  return parsed.map<ManufacturerNModel>((json) => ManufacturerNModel.fromJson(json)).toList();
}

class FilterCompanyList extends StatelessWidget {
  final LoadBikeController controller = Get.arguments;

  Future<List<ManufacturerNModel>> loadJson() async {
    print('load json func()');
    String jsonString =
    await rootBundle.loadString('assets/json/bike_model.json');
    print('loadjson \n' + jsonString);

    return compute(parseModelSpec, jsonString);
  }

  Widget companyListView(List<ManufacturerNModel> company) {
    print(company.length);
    return ListView.separated(
      itemCount: company.length,
      itemBuilder: (BuildContext context, int index) {
        return ListTile(
          title: Text(company[index].manufacturer),
          onTap: () {
            Get.to(FilterModelList(
              company: company[index].manufacturer,
              model: company[index].modelNSpec,
              controller: controller,
            ));
          },
        );
      },
      separatorBuilder: (context, index) {
        return Divider();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('제조사'),
      ),
      body: Center(
        child: FutureBuilder<List<ManufacturerNModel>>(
          future: loadJson(),
          builder: (context, snapshot) {
            //print(snapshot.data);
            if (snapshot.hasError) print(snapshot.error);

            if (snapshot.hasData) {
              print(snapshot.data);
              final List<ManufacturerNModel> company = snapshot.data;
              return companyListView(company);
            } else
              return Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}

class FilterModelList extends StatelessWidget {
  final String company;
  final List<ModelNSpec> model;
  final LoadBikeController controller;

  FilterModelList({Key key, @required this.company, @required this.model, @required this.controller})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("모델명선택"),
      ),
      body: ListView.separated(
        itemCount: model.length,
        itemBuilder: (contetxt, int index) {
          return ListTile(
            title: Text(model[index].name),
            onTap: () {
              //controller.companyModel.add(model[index].name, "model");
              controller.companyModel.add(model[index].name);
              Get.until((route) => Get.currentRoute == '/view/filter');
            },
          );
        },
        separatorBuilder: (context, index) {
          return Divider();
        },
      ),
      floatingActionButton:
      FloatingActionButton.extended(
          onPressed: (){
            controller.companyModel.add(company);
            Get.until((route) => Get.currentRoute == '/view/filter');
          },
          label: Text(company+' 전체선택')),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
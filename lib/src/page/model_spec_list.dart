import 'package:flutter/material.dart';
import 'package:hibaike/src/controller/bike_data_controller.dart';
import 'package:hibaike/src/model/manufacturer_model.dart';
import 'package:get/get.dart';

class ModelList extends StatelessWidget {
  final String manufacturer;
  final List<ModelNSpec> model;
  final String fromRoute;

  ModelList({Key key, @required this.manufacturer, @required this.model, @required this.fromRoute}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("모델명선택"),
      ),
      body: ListView.builder(
        itemCount: model.length,
        itemBuilder: (contetxt, int index){
          return ListTile(
            title: Text(model[index].name),
            onTap: () {
              Get.to(DisplacementSelect(
                manufacturer: manufacturer,
                model: model[index].name,
                displacement: model[index].displacement,
                fromRoute: fromRoute,
              ));
            },
          );
        },
      ),
    );
  }
}

class DisplacementSelect extends StatelessWidget {
  final String manufacturer;
  final String model;
  final int displacement;
  final String fromRoute;

  DisplacementSelect(
      {Key key,
      @required this.manufacturer,
      @required this.model,
      @required this.displacement,
      @required this.fromRoute})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("배기량선택"),
      ),
      body: ListView.builder(
        itemCount: 1,  // todo : need to chanme List
        itemBuilder: (contetxt, int index){
          return ListTile(
            title: Text(displacement.toString()+'cc'),
            onTap: () {
              Get.find<BikeDataController>().setModel(manufacturer, model, displacement);
              Get.until((route) => Get.currentRoute == fromRoute);
            },
          );
        },
      ),
    );
  }
}
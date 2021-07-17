import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hibaike/src/model/manufacturer_model.dart';
import 'package:get/get.dart';

import 'model_spec_list.dart';

List<ManufacturerNModel> parseModelSpec(String companyJson) {
  final parsed = json.decode(companyJson).cast<Map<String, dynamic>>();
  return parsed.map<ManufacturerNModel>((json) => ManufacturerNModel.fromJson(json)).toList();
}

class ManufacturerList extends StatelessWidget {
  String fromRoute = Get.arguments;
  Future<List<ManufacturerNModel>> loadJson() async{
    print('load bike model json load');
    String jsonString = await rootBundle.loadString('assets/json/bike_model.json');
    print(jsonString);

    return compute(parseModelSpec, jsonString);
  }

  Widget manufacturerListView(List<ManufacturerNModel> manufacturers) {
    print(manufacturers.length);
    return ListView.separated(
      itemCount: manufacturers.length,
      itemBuilder: (BuildContext context, int index){
        return ListTile(
          title: Text(manufacturers[index].manufacturer),
          onTap: () {
            Get.to(ModelList(
                manufacturer: manufacturers[index].manufacturer,
                model: manufacturers[index].modelNSpec,
                fromRoute: fromRoute,
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

            if(snapshot.hasData) {
              print(snapshot.data);
              final List<ManufacturerNModel> manufacturer = snapshot.data;
              return manufacturerListView(manufacturer);
            }
            else
              return Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}
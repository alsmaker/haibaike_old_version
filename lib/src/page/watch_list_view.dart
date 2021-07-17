import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hibaike/src/controller/sign_controller.dart';
import 'package:hibaike/src/model/bike.dart';
import 'package:intl/intl.dart';

class WatchListView extends StatefulWidget {
  @override
  _WatchListViewState createState() => _WatchListViewState();
}

class _WatchListViewState extends State<WatchListView> {
  SignController signController = Get.find();
  double thumbnailSize = 85;
  StreamController streamController = StreamController();

  @override
  initState() {
    fetchWatchList();
    super.initState();
  }

  @override
  dispose() {
    streamController.close();
    super.dispose();
  }

  Future<List<BikeData>> fetchWatchList()  async {
    List<String> watchList = signController.currentUser.value.watchList;
    List<BikeData> watchListBike = [];

    print(watchList.length);

    for (var i = 0; i < watchList.length; i++) {
      var temp = await FirebaseFirestore.instance.collection('bikes')
          .doc(watchList[i])
          .get();
      //print(temp.data());
      watchListBike.add(BikeData.fromJson(temp.data()));
    }
    print('fetch watch list done');

    return watchListBike;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('관심목록', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        elevation: 0,
        iconTheme: IconThemeData(
          color: Colors.black
        ),
      ),
      body: FutureBuilder(
        future: fetchWatchList(),
        builder: (context, AsyncSnapshot<List<BikeData>> snapshot) {
          if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          else {
              return ListView.separated(
                  itemBuilder: (context, index) {
                    print(snapshot.data[index].locationLevel2);
                    return smallBikeTile(snapshot.data[index]);
                  },
                  separatorBuilder: (context, index) {
                    return Divider();
                  },
                  itemCount: signController.currentUser.value.watchList.length);
            }
          }),
    );
  }

  Widget smallBikeTile(BikeData bikeData) {
    final formatter = NumberFormat('#,###');
    return Container(
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.only(left: 10, right: 10),
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
                imageUrl: bikeData.imageList[0],
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(bikeData.manufacturer + ' ' +bikeData.model, style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),),
              Text(bikeData.birthYear.toString()+'년 ' + formatter.format(bikeData.mileage) +'km ' + bikeData.locationLevel2),
            ],
          ),
        ],
      ),
    );
  }
}
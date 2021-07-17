import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hibaike/src/controller/sign_controller.dart';
import 'package:hibaike/src/model/bike.dart';
import 'package:intl/intl.dart';

class SalesListView extends StatelessWidget {
  SignController signController = Get.find();
  double thumbnailSize = 85;

  Widget smallBikeTile(DocumentSnapshot ds) {
    print(ds.data());
    BikeData bikeData = BikeData.fromJson(ds.data());
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
              Row(
                children: [
                  InkWell(
                      onTap: () {
                        Get.toNamed('/update_bike', arguments: ds);
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 7, horizontal: 15),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                        ),
                          child: Text('수정', style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold
                          ),),
                      ),
                  ),
                  SizedBox(width: 10,),
                  InkWell(
                    onTap: () {
                      FirebaseFirestore.instance.collection('sold_out_bikes').doc(bikeData.key).set(bikeData.toJson())
                      .then((value) => FirebaseFirestore.instance.collection('bikes').doc(bikeData.key).delete());
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 7, horizontal: 15),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                      ),
                      child: Text('거래완료', style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold
                      ),),
                    ),
                  ),
                ],
              ),
            ],
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
        title: Text('판매목록',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('bikes')
              .where('ownerUid',
                  isEqualTo: signController.currentUser.value.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if(!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            else {
              return ListView.separated(
                itemBuilder: (context, int index) {
                  return smallBikeTile(snapshot.data.docs[index]);
                },
                separatorBuilder: (context, index) {
                  return Divider();
                },
                itemCount: snapshot.data.docs.length,
              );
            }
          }),
    );
  }
}
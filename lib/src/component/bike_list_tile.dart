import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hibaike/src/component/date_time_formatter.dart';
import 'package:hibaike/src/controller/sign_controller.dart';
import 'package:hibaike/src/model/bike.dart';
import 'package:intl/intl.dart';

class BikeListTile extends StatefulWidget {
  final BikeData bikeData;
  const BikeListTile({Key key, this.bikeData}) : super(key: key);

  @override
  _BikeListTileState createState() => _BikeListTileState();
}

class _BikeListTileState extends State<BikeListTile> {
  Widget _thumnail() {
    SignController signController = Get.find();
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
      child: Stack(
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: ClipRRect(
              borderRadius: BorderRadius.only(topLeft: Radius.circular(4),topRight: Radius.circular(4)),
              //height: 280,
              child: CachedNetworkImage(
                  imageUrl: widget.bikeData.imageList[0],
                  placeholder: (context, url) => Container(
                    //height: 230,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  fit: BoxFit.cover
              ),
            ),
          ),

          Positioned(
            bottom: 10,
            right: 10,
              child: GestureDetector(
                child: Container(
                  width: 37,
                  height: 37,
                  child: signController.currentUser.value.watchList.contains(widget.bikeData.key) ?
                    Icon(Icons.favorite, size: 25, color: Colors.red,) :
                    Icon(Icons.favorite_border, size: 25,),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white),
                ),
                onTap: () {
                  setState(() {
                    signController.updateWatchList(widget.bikeData.key);
                  });

              }),
          ),
        ],
      ),
    );
  }

  Widget _detailInfo() {
    final formatter = NumberFormat('#,###');
    final dateTimeFormtter = DateTimeFormatter();
    return Padding(
      padding: EdgeInsets.fromLTRB(14, 7, 14, 23),
        child: Container(
           decoration: BoxDecoration(
               borderRadius: BorderRadius.only(bottomLeft: Radius.circular(8),bottomRight: Radius.circular(8)),
             //border: Border(left: BorderSide(color: Colors.grey)),
           ),
          // border: Border.),
          child: Row(
            children: [
              Expanded(

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children:[
                    Text(widget.bikeData.manufacturer+' '+widget.bikeData.model, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500,color: Colors.black),),
                    SizedBox(height: 3,),
                    Text(widget.bikeData.birthYear.toString()+'년식 · '+ formatter.format(widget.bikeData.mileage)+'km', style: TextStyle(fontSize: 13, color: Colors.black.withOpacity(0.8))),
                    Text(widget.bikeData.locationLevel2+' · ' + dateTimeFormtter.bikeDateTime(widget.bikeData.createdTime)),
                  ],
                ),
              ),
              //Expanded(child: null),
              Container(
                child: Text(formatter.format(widget.bikeData.amount)+'만원', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black)),
              )
            ],
          ),
        ),

    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          _thumnail(),
          _detailInfo(),
        ],
      ),
    );
  }
}
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hibaike/src/component/date_time_formatter.dart';
import 'package:hibaike/src/controller/page_index_controller.dart';
import 'package:hibaike/src/controller/sign_controller.dart';
import 'package:hibaike/src/model/bike.dart';
import 'package:hibaike/src/model/users.dart';
import 'package:intl/intl.dart';

class BikeDetailView extends StatefulWidget {
  BikeDetailView({Key key}) : super(key: key);

  @override
  _BikeDetailViewState createState() => _BikeDetailViewState();
}

class _BikeDetailViewState extends State<BikeDetailView>
    with TickerProviderStateMixin {

  final BikeData bikeData = Get.arguments;
  final DateTimeFormatter dateTimeFormatter = DateTimeFormatter();
  final numberFormatter = NumberFormat('#,###');
  Users owner;

  AnimationController _colorAnimationController;
  AnimationController _textAnimationController;
  Animation _colorTween, _iconColorTween;
  Animation<Offset> _transTween;

  @override
  void initState() {
    bringOwnerInfo();

    _colorAnimationController =
        AnimationController(vsync: this, duration: Duration(seconds: 0));
    _colorTween = ColorTween(begin: Colors.transparent,
        end: Colors.white)
    //end: Color(0xFFee4c4f))
        .animate(_colorAnimationController);
    _iconColorTween = ColorTween(begin: Colors.white, end: Colors.black)
        .animate(_colorAnimationController);


    _textAnimationController =
        AnimationController(vsync: this, duration: Duration(seconds: 0));

    _transTween = Tween(begin: Offset(-10, 40), end: Offset(-10, 0))
        .animate(_textAnimationController);

    super.initState();
  }

  bringOwnerInfo() async{
    CollectionReference userRef = FirebaseFirestore.instance.collection('users');
    DocumentSnapshot snapshot = await userRef.doc(bikeData.ownerUid).get();
    owner =  Users.fromJson(snapshot.data());
  }

  bool _scrollListener(ScrollNotification scrollInfo) {
    if (scrollInfo.metrics.axis == Axis.vertical) {
      print('scroll info = ${scrollInfo.metrics.pixels}');
      print('width = ${MediaQuery.of(context).size.width}, height = ${MediaQuery.of(context).size.height}');
      _colorAnimationController.animateTo(scrollInfo.metrics.pixels / 300);

      _textAnimationController.animateTo(
          (scrollInfo.metrics.pixels - 300) / 50);
      return true;
    }
  }



  Widget _imageSlider() {
    Get.put(PageIndexController());
    return InkWell(
      onTap: () {
        Get.toNamed('/view/detail/photos', arguments: bikeData.imageList);
      },
      child: Stack(
        children: [
          CarouselSlider(
            items: bikeData.imageList.map((i) {
              return Builder(
                builder: (BuildContext context) {
                  print(MediaQuery.of(context).size.width);
                  return Container(
                    width: MediaQuery.of(context).size.width,
                    //margin: EdgeInsets.symmetric(horizontal: 5.0),
                    decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.5)
                    ),
                    child: CachedNetworkImage(
                      imageUrl: i,
                      placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ),
                  );
                },
              );
            }).toList(),
            options: CarouselOptions(
                initialPage: Get.find<PageIndexController>().index.value,
                autoPlay: false,
                enlargeCenterPage: false,
                enableInfiniteScroll: false,
                aspectRatio: 1.0,
                viewportFraction: 1.0,
                onPageChanged: (index, reason) {
                  //setState(() {
                  Get.find<PageIndexController>().chageIndex(index);
                  //});
                }
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: bikeData.imageList.map((url) {
                int index = bikeData.imageList.indexOf(url);
                return Obx(()=>Container(
                  width: 10.0,
                  height: 10.0,
                  margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Get.find<PageIndexController>().index.value == index
                        ? Color.fromRGBO(255, 255, 255, 0.8)
                        : Color.fromRGBO(80, 80, 80, 0.6),
                  ),
                ));
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _ownerInfo() {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.black12)),
      ),
      padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 7.0),
      child: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(bikeData.ownerUid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              //child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(themeColor)));
                child: CircularProgressIndicator(
                    valueColor:
                    AlwaysStoppedAnimation<Color>(Colors.red)));
          } else {
            return Row(
              children: [
                CircleAvatar(
                  radius: 23,
                  backgroundImage: ((snapshot.data['profile_image_url'] == null) || (snapshot.data['profile_image_url']=='')) ?
                      NetworkImage('https://i.stack.imgur.com/l60Hf.png')
                      : NetworkImage(snapshot.data['profile_image_url']),
                ),
                SizedBox(width: 10,),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(snapshot.data['nick_name'], style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),),
                      SizedBox(height: 6,),
                      Text(bikeData.locationLevel1, style: TextStyle(fontSize: 13),),
                    ],
                  ),
                ),
                GestureDetector(
                  child: Container(
                    //color: Colors.black.withOpacity(0.7),
                    padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 11.0),
                    child: Text('채팅으로 거래하기', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                    decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(5)), color: Colors.black),
                  ),
                  onTap: () {
                    SignController signCtrl = Get.find();
                    if(signCtrl.currentUser == null) {
                      // todo : 로그인이 되어 있는 상태에서만 채팅 가능
                      print('must go to signin page');
                      Get.toNamed('/signUp');
                    }
                    else {
                      List<String> argumentList = [bikeData.key, bikeData.ownerUid];
                      Get.toNamed('/chat', arguments: argumentList);
                    }
                  },
                )
              ],
            );
          }
        },
      ),
    );
  }

  Widget _bikeInfo() {
    return Container(
      padding: EdgeInsets.fromLTRB(5.0, 10.0, 5.0, 0),
      child: Column(
        children: [
          Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.fromLTRB(5.0, 5.0, 0, 0.0),
            child: Text(
              bikeData.manufacturer + ' ' + bikeData.model,
              style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.fromLTRB(5.0, 0.0, 0, 5.0),
            child: Text(
              bikeData.birthYear.toString() + '년식' + ' · ' + numberFormatter.format(bikeData.mileage) + 'Km',
              style: TextStyle(color: Colors.black45, fontSize: 15,),
            ),
          ),
          Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.fromLTRB(5.0, 5.0, 0, 5.0),
            child: Text(
              numberFormatter.format(bikeData.amount) + '만원',
              style: TextStyle(
                  fontSize: 21, fontWeight: FontWeight.w800, color: Colors.red),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(5.0, 0, 0, 10.0),
            child: Row(
              children: [
                Row(children: [
                  Icon(Icons.place_outlined, color: Colors.black45, size: 17,),
                  Text(bikeData.locationLevel0 + ' ' + bikeData.locationLevel1 + ' ' + bikeData.locationLevel2,
                    style: TextStyle(color: Colors.black45, fontSize: 15,),),
                ],),
                SizedBox(width: 25,),
                Row(children: [
                  Icon(Icons.access_time, color: Colors.black45, size: 16,),
                  Text(' '+dateTimeFormatter.bikeDateTime(bikeData.createdTime),
                    style: TextStyle(color: Colors.black45, fontSize: 15,),),
                ],),
              ],
            ),
          ),
          Divider(height: 10,),

          Padding(
            padding: const EdgeInsets.fromLTRB(5.0, 10.0, 0, 10.0),
            child: Row(
              children: [
                Container(
                    //width: 30,
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 7.0),
                    //alignment: Alignment.center,
                    decoration: BoxDecoration(
                      //color: Colors.white,
                      border: Border.all(color: Colors.red, width: 1.2),
                      // set border width
                      borderRadius: BorderRadius.all(
                          Radius.circular(30.0)), // set rounded corner radius
                      //boxShadow: [BoxShadow(blurRadius: 10,color: Colors.black,offset: Offset(1,3))]// make rounded corner of border
                    ),
                    child: Text(bikeData.displacement.toString() + 'cc')),
                SizedBox(width: 7,),
                Container(
                  //width: 30,
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 7.0),
                    //alignment: Alignment.center,
                    decoration: BoxDecoration(
                      //color: Colors.white,
                      border: Border.all(color: Colors.red, width: 1.2),
                      // set border width
                      borderRadius: BorderRadius.all(
                          Radius.circular(30.0)), // set rounded corner radius
                      //boxShadow: [BoxShadow(blurRadius: 10,color: Colors.black,offset: Offset(1,3))]// make rounded corner of border
                    ),
                    child: Text('R타입')),
                SizedBox(width: 7,),
                Container(
                  //width: 30,
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 7.0),
                    //alignment: Alignment.center,
                    decoration: BoxDecoration(
                      //color: Colors.white,
                      border: Border.all(color: Colors.red, width: 1.2),
                      // set border width
                      borderRadius: BorderRadius.all(
                          Radius.circular(30.0)), // set rounded corner radius
                      //boxShadow: [BoxShadow(blurRadius: 10,color: Colors.black,offset: Offset(1,3))]// make rounded corner of border
                    ),
                    child: Text('가솔린')),
                SizedBox(width: 7,),
                Container(
                  //width: 30,
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 7.0),
                    //alignment: Alignment.center,
                    decoration: BoxDecoration(
                      //color: Colors.white,
                      border: Border.all(color: Colors.red, width: 1.2),
                      // set border width
                      borderRadius: BorderRadius.all(
                          Radius.circular(30.0)), // set rounded corner radius
                      //boxShadow: [BoxShadow(blurRadius: 10,color: Colors.black,offset: Offset(1,3))]// make rounded corner of border
                    ),
                    child: Text('자동')),
              ],
            ),
          ),
          Divider(height: 10,),
          Container(
            padding: EdgeInsets.all(7.0),
            alignment: Alignment.topLeft,
            child: Text(bikeData.comment, style: TextStyle(color: Colors.black, fontSize: 17),),
          )

        ],
      ),

    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /*
      appBar: AppBar(
        title: Text(
          bikeData.model,
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
          color: Colors.black, //change your color here
        ),
      ),
      */
      backgroundColor: Color(0xFFEEEEEE),
      body: NotificationListener(
        onNotification: _scrollListener,
        child: Container(
          height: double.infinity,
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  children: [
                    _imageSlider(),
                    _bikeInfo(),
                  ],
                ),
              ),
              Container(
                height: 80,
                child: AnimatedBuilder(
                  animation: _colorAnimationController,
                  builder: (context, child) => AppBar(
                    backgroundColor: _colorTween.value,
                    elevation: 0,
                    titleSpacing: 0.0,
                    title: Transform.translate(
                      offset: _transTween.value,
                      child: Text(
                        bikeData.model,
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      ),
                    ),
                    iconTheme: IconThemeData(
                      color: _iconColorTween.value,
                    ),
                    actions: <Widget>[
                      IconButton(
                        icon: Icon(
                          Icons.share,
                        ),
                        onPressed: () {
//                          Navigator.of(context).push(TutorialOverlay());
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.more_vert,
                        ),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _ownerInfo(),
    );
  }
}
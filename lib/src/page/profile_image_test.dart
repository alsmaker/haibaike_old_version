import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hibaike/src/controller/page_index_controller.dart';
import 'package:hibaike/src/model/bike.dart';

class ProductDetails extends StatefulWidget {
  @override
  _ProductDetailsState createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails>
    with TickerProviderStateMixin {
  AnimationController _colorAnimationController;
  AnimationController _textAnimationController;
  Animation _colorTween, _iconColorTween;
  Animation<Offset> _transTween;
  final BikeData bikeData = Get.arguments;


  @override
  void initState() {
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

  @override
  Widget build(BuildContext context) {
    Get.put(PageIndexController());
    return Scaffold(
      backgroundColor: Color(0xFFEEEEEE),
      body: NotificationListener<ScrollNotification>(
        onNotification: _scrollListener,
        child: Container(
          height: double.infinity,
          child: Stack(
            children: <Widget>[
              SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    Stack(
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
                    Container(
                      height: 150,
                      color:
                      Color((Random().nextDouble() * 0xFFFFFF).toInt() << 0)
                          .withOpacity(1),
                      width: 250,
                    ),
                    Container(
                      height: 150,
                      color: Colors.pink,
                      width: 250,
                    ),
                    Container(
                      height: 150,
                      color: Colors.deepOrange,
                      width: 250,
                    ),
                    Container(
                      height: 150,
                      color: Colors.red,
                      width: 250,
                    ),
                    Container(
                      height: 150,
                      color: Colors.white70,
                      width: 250,
                    ),
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
    );
  }
}
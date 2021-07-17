import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hibaike/src/controller/bottom_index_controller.dart';
import 'package:hibaike/src/controller/sign_controller.dart';
import 'package:hibaike/src/model/shop_data.dart';
import 'package:elastic_client/elastic_client.dart' as elastic;

class NearbyPage extends StatefulWidget {
  @override
  _NearbyPageState createState() => _NearbyPageState();
}

class _NearbyPageState extends State<NearbyPage> with WidgetsBindingObserver{
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  //Completer<GoogleMapController> _controller = Completer();
  GoogleMapController _controller;
  String apiKey = 'AIzaSyAgkR2a33agDSGR2adz2KK-aZ5A_MEbBnw'; // google places api key
  Position position;
  LatLng currentPosition;
  CameraPosition cameraPosition;
  var lat, lng;
  bool isLoading = true;
  ShopData shopData;

  SignController signCtrl = Get.find();
  BottomIndexController indexCtrl = Get.find();

  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  MarkerId latestSelectedMarker = MarkerId('');

  bool isBottomSheetOpen = false;

  @override
  void initState() {
    checkGPAvailability();
    WidgetsBinding.instance.addObserver(this);

    //bringShopDataFromFireStore();
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      resumeGoogleMap();
    }
  }

  resumeGoogleMap() async{
    print('resume google map');
    //final GoogleMapController controller = await _controller.future;
    //controller.setMapStyle("[]");
    _controller.setMapStyle("[]]");
  }

  void checkGPAvailability() async {
    bool serviceEnabled;
    LocationPermission permission;

    print('sync test 1');

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('location services are disabled');
      return;
    }

    print('sync test 2');

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      print(
          'Location permission are permently denied, we cannot request permissions');
      return;
    }
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        print('Location permissions are denied (actual value: $permission).');
        return;
      }
    }

    print('sync test 3');

    await getUserCurrentPosition();

    print('sync test');
  }

  loadRegistryDataFromElastic() async{
    String username = 'elastic';
    String password = 'uGeImNqJ3DP31Qanpavemgqz';
    String basicAuth =
        'Basic ' + base64Encode(utf8.encode('$username:$password'));
    final transport = elastic.HttpTransport(url: "https://hibaike-search-deployment.es.asia-northeast1.gcp.cloud.es.io:9243",
        authorization: basicAuth);
    final client = elastic.Client(transport);

    LatLngBounds bounds = await _controller.getVisibleRegion();
    var top = bounds.northeast.latitude;
    var bottom = bounds.southwest.latitude;
    var left = bounds.southwest.longitude;
    var right = bounds.northeast.longitude;
    int limit = 10;

    print('top = $top, bottom = $bottom, left = $left, right = $right');

    String queryString = '{"bool": {"must": {"match_all": {}},"filter": {"geo_bounding_box": {"shopLocation": {"top_left": {"lat": $top,"lon": $left},"bottom_right": {"lat": $bottom,"lon": $right}}}}}}';
    Map queryMap = json.decode(queryString);

    var response = await client.search(
      index: 'shops',
      type: '_doc',
      query: queryMap,
      limit: limit,
      source: true,
    );

    if(response.hits.length >=  limit)
      Fluttertoast.showToast(msg: '최대 10개 등록소까지 표시됩니다');

    response.hits.forEach((doc) {
      print(doc.doc['name']);
      var mapJson = Map<String, dynamic>.from(doc.doc);
      ShopData shopData = ShopData.fromJson(mapJson);

      var _marker = Marker(
          markerId: MarkerId(doc.id),
          position:
          LatLng(shopData.shopLocation.lat, shopData.shopLocation.lon),
          icon: doc.id==latestSelectedMarker.value
              ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue)
              : BitmapDescriptor.defaultMarker,
          consumeTapEvents: true,
          onTap: () {
            print('marker tab');
            //scaffoldKey.currentState.showBottomSheet((context) => BottomSheetWidget(registryData: registryData,));
            setState(() {
              if(latestSelectedMarker != null && latestSelectedMarker.value.length != 0
                  && markers.containsKey(latestSelectedMarker)) {
                Marker _marker = markers[latestSelectedMarker];
                markers[latestSelectedMarker] =
                    _marker.copyWith(iconParam: BitmapDescriptor.defaultMarker);
              }
              latestSelectedMarker = MarkerId(doc.id);
              Marker _marker = markers[latestSelectedMarker];
              markers[latestSelectedMarker] = _marker.copyWith(
                  iconParam: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue));

              scaffoldKey.currentState.showBottomSheet((context) {
                //return bottomSheetWidget(shopData);
                return bottomSheet(shopData);
                // return DraggableScrollableSheet(
                //   initialChildSize: 0.1, //_initialSheetChildSize,
                //   maxChildSize: 0.5,
                //   minChildSize: 0.1,
                //   expand: false,
                //   builder: (context, scrollController) => ListView.builder(
                //       controller: scrollController,
                //       itemCount: 10,
                //       itemBuilder: (BuildContext context, int index) {
                //         //ListTiles...},
                //         return Text('text');
                //       }),
                // );
              });
            });
          });

      setState(() {
        markers[MarkerId(doc.id)] = _marker;
      });

    });
  }

  bringShopDataFromFireStore() async {
    //List<ShopData> shopList = [];
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('shops').get();

    snapshot.docs.forEach((doc) {
      shopData = ShopData.fromJson(doc.data());
    });

    // markers.add(Marker(
    //     markerId: MarkerId('1'),
    //     position: LatLng(shopData.shopLocation.lat.toDouble(),
    //         shopData.shopLocation.lon.toDouble()),
    //     consumeTapEvents: true,
    //     onTap: () {
    //       print('marker tab');
    //       setState(() {
    //         scaffoldKey.currentState.showBottomSheet((context) {
    //           //return BottomSheetWidget(
    //           return bottomSheetWidget(shopData);
    //         });
    //       });
    //     }));

    setState(() {

    });

    print('shop data test');
  }

  Future<LatLng> getUserCurrentPosition () async {
    position = await Geolocator.getCurrentPosition();
    print('my position is lat = ${position.latitude}, lng = ${position
        .longitude}');


    setState(() {
      lat = position.latitude;
      lng = position.longitude;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text('주변', style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.black,
        //elevation: 0,
        iconTheme: IconThemeData(
            color: Colors.white
        ),
      ),
      body: isLoading
          ? Center(
        child: CircularProgressIndicator(),
      )
      : GoogleMap(
        mapType: MapType.normal,
        markers: Set<Marker>.of(markers.values),//Set.from(shopMarkers),
        initialCameraPosition: CameraPosition(
          //target: LatLng(37.49639442929692, 127.04438769057595),
          target: LatLng(lat, lng),
          zoom: 15,
        ),
        onMapCreated: (GoogleMapController controller) {
          //_controller.complete(controller);
          _controller = controller;
          // getAddrFromLocation();
        },
        myLocationEnabled: true,
        zoomControlsEnabled: false,
        onCameraMoveStarted: _onCameraMoveStarted,
        onCameraMove: _onCameraMove,
        onCameraIdle: _onCameraIdle,
      ),
    );
  }

  _onCameraMoveStarted() {
    //print('camera move start');
  }

  _onCameraMove(CameraPosition position) async{
    cameraPosition = position;
    //print("camera moving");
    //LatLngBounds bounds = await _controller.getVisibleRegion();
    //print(bounds);
  }

  _onCameraIdle() {
    print('camera idle');
    markers.clear();
    loadRegistryDataFromElastic();
  }

  Widget bottomSheet(ShopData shopData) {
    return DraggableScrollableSheet(
      initialChildSize: 0.24,
      //_initialSheetChildSize,
      maxChildSize: 0.7,
      minChildSize: 0.1,
      expand: false,
      // builder: (context, scrollController) => ListView.builder(
      //     controller: scrollController,
      //     itemCount: 50,
      //     itemBuilder: (BuildContext context, int index) {
      //       //ListTiles...},
      //       return Text('text');
      //     }),
      builder: (context, scrollController) {
        double thumbnailSize = MediaQuery.of(context).size.height * 0.14;
        return Container(
          padding: EdgeInsets.only(left: 15, right: 15, top: 5),
          height: MediaQuery.of(context).size.height*0.5,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.transparent),
            borderRadius: BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15)),
          ),
          child: ListView(
            controller: scrollController,
            //mainAxisAlignment: MainAxisAlignment.center,
            //mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.3,
                  height: 7,
                  margin: EdgeInsets.only(top: 5, bottom: 5),
                  decoration: BoxDecoration(
                    color: Colors.grey[350],
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                ),
              ),
              SizedBox(height: 15),
              Container(
                padding: EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Material(
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
                        imageUrl: shopData.imageList[0],
                        width: thumbnailSize,
                        height: thumbnailSize,
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.all(
                        Radius.circular(5.0),
                      ),
                      clipBehavior: Clip.hardEdge,
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 15),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                              child: Text(shopData.shopName, style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),)
                          ),
                          SizedBox(height: 10,),
                          Row(
                            children: [
                              Icon(Icons.phone_iphone, size: 15,),
                              Text('010-3330-1824', style: TextStyle(fontSize: 16),),
                            ],
                          ),
                          SizedBox(height: 5),
                          Row(
                            children: [
                              Icon(Icons.local_phone, size: 15,),
                              Text(shopData.contact, style: TextStyle(fontSize: 16),),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Divider(),

              Container(
                padding: EdgeInsets.only(top: 10, bottom: 10),
                child: Column(
                  children: [

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
                        shopData.address.length > 0
                            ? Text(
                          shopData.address +
                              ' ' +
                              shopData.addressDetail,
                          style: TextStyle(fontSize: 16),
                        )
                            : Container(),
                      ],
                    ),
                    SizedBox(height: 5,),
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
                        shopData.roadAddress.length > 0
                            ? Expanded(
                          child: Text(
                            shopData.roadAddress +
                                ' ' +
                                shopData.addressDetail,
                            style: TextStyle(fontSize: 16),
                            overflow: TextOverflow.ellipsis,
                            softWrap: false,
                            maxLines: 2,
                          ),
                        )
                            : Container(),
                      ],
                    ),

                    Divider(height: 10,),

                    // 오일 타입
                    Container(
                      padding: EdgeInsets.only(top: 10, bottom: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text('취급오일', style: TextStyle(fontSize: 15, color: Colors.grey),),
                              Icon(Icons.navigate_next, color: Colors.grey,),
                            ],
                          ),
                          SizedBox(height: 10,),
                          Text(
                            shopData.oilType,
                            style: TextStyle(
                                fontSize: 17, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                            softWrap: false,
                            maxLines: 2,
                          ),
                        ],
                      ),
                    ),
                    Divider(),
                    Container(
                      padding: EdgeInsets.only(top: 10, bottom: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text('보유진단기', style: TextStyle(fontSize: 15, color: Colors.grey),),
                              Icon(Icons.navigate_next, color: Colors.grey,),
                            ],
                          ),
                          SizedBox(height: 10,),
                          Text(shopData.diagnosticDevice,
                            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                            softWrap: false,
                            maxLines: 2,),
                        ],
                      ),
                    ),
                    Divider(),

                    Container(
                      padding: EdgeInsets.only(top: 10, bottom: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text('매장상세정보', style: TextStyle(fontSize: 15, color: Colors.grey),),
                              Icon(Icons.navigate_next, color: Colors.grey,),
                            ],
                          ),
                          SizedBox(height: 10,),
                          Text(
                            shopData.comment,
                            style: TextStyle(fontSize: 16,),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget bottomSheetWidget(ShopData shopData) {
    double thumbnailSize = 100;
    return Container(
      padding: EdgeInsets.only(left: 15, right: 15, top: 5),
      height: MediaQuery.of(context).size.height*0.5,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.transparent),
        borderRadius: BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            children: [
              Material(
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
                  imageUrl: shopData.imageList[0],
                  width: thumbnailSize,
                  height: thumbnailSize,
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.all(
                  Radius.circular(5.0),
                ),
                clipBehavior: Clip.hardEdge,
              ),
              Container(
                margin: EdgeInsets.only(left: 15),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                        child: Text(shopData.shopName, style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),)
                    ),
                    SizedBox(height: 10,),
                    Row(
                      children: [
                        Icon(Icons.phone_iphone, size: 15,),
                        Text('010-3330-1824', style: TextStyle(fontSize: 16),),
                      ],
                    ),
                    SizedBox(height: 5),
                    Row(
                      children: [
                        Icon(Icons.local_phone, size: 15,),
                        Text(shopData.contact, style: TextStyle(fontSize: 16),),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          Divider(height: 20,),

          Column(
            children: [

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
                  shopData.address.length > 0
                      ? Text(
                    shopData.address +
                        ' ' +
                        shopData.addressDetail,
                    style: TextStyle(fontSize: 16),
                  )
                      : Container(),
                ],
              ),
              SizedBox(height: 5,),
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
                  shopData.roadAddress.length > 0
                      ? Expanded(
                    child: Text(
                      shopData.roadAddress +
                          ' ' +
                          shopData.addressDetail,
                      style: TextStyle(fontSize: 16),
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                      maxLines: 2,
                    ),
                  )
                      : Container(),
                ],
              ),

              // 오일 타입
              Row(
                children: [
                  Text('취급오일', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),),
                  Container(
                    padding: EdgeInsets.only(left: 10, right: 10),
                    child: Text('|', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),),),
                  Text(shopData.oilType, style: TextStyle(fontSize: 17),),
                ],
              ),
              Row(
                children: [
                  Text('보유 진단기', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),),
                  Container(
                    padding: EdgeInsets.only(left: 10, right: 10),
                    child: Text('|', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),),),
                  Text(shopData.diagnosticDevice, style: TextStyle(fontSize: 17),),
                ],
              ),
              SizedBox(height: 50,),
              Text(shopData.comment, style: TextStyle(fontSize: 17),),
            ],
          ),
        ],
      ),
    );
  }
}

class BottomSheetWidget extends StatefulWidget {
  final ShopData shopData;
  const BottomSheetWidget({Key key, this.shopData}) : super(key: key);

  @override
  _BottomSheetWidgetState createState() => _BottomSheetWidgetState();
}

class _BottomSheetWidgetState extends State<BottomSheetWidget> {
  // ShopData shopData;
  // _BottomSheetWidgetState({this.shopData});

  double thumbnailSize = 100;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 15, right: 15, top: 5),
      height: MediaQuery.of(context).size.height*0.4,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.transparent),
        borderRadius: BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Row(
            children: [
              Material(
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
                  imageUrl: widget.shopData.imageList[0],
                  width: thumbnailSize,
                  height: thumbnailSize,
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.all(
                  Radius.circular(5.0),
                ),
                clipBehavior: Clip.hardEdge,
              ),
              Container(
                margin: EdgeInsets.only(left: 15),
                decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(15),
                    ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                        child: Text(widget.shopData.shopName, style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),)
                    ),
                    SizedBox(height: 10,),
                    Row(
                      children: [
                        Icon(Icons.phone_iphone, size: 15,),
                        Text('010-3330-1824', style: TextStyle(fontSize: 16),),
                      ],
                    ),
                    SizedBox(height: 5),
                    Row(
                      children: [
                        Icon(Icons.local_phone, size: 15,),
                        Text(widget.shopData.contact, style: TextStyle(fontSize: 16),),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          Divider(height: 20,),

          Column(
            children: [

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
                      color: Colors.black,
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                    ),
                  ),
                  widget.shopData.address.length > 0
                      ? Text(
                    widget.shopData.address +
                        ' ' +
                        widget.shopData.addressDetail,
                    style: TextStyle(fontSize: 16),
                  )
                      : Container(),
                ],
              ),
              SizedBox(height: 5,),
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
                      color: Colors.black,
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                    ),
                  ),
                  widget.shopData.roadAddress.length > 0
                      ? Expanded(
                    child: Text(
                      widget.shopData.roadAddress +
                          ' ' +
                          widget.shopData.addressDetail,
                      style: TextStyle(fontSize: 16),
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                      maxLines: 2,
                    ),
                  )
                      : Container(),
                ],
              ),

              // 오일 타입
              Row(
                children: [
                  Text('취급오일', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),),
                  Container(
                    padding: EdgeInsets.only(left: 10, right: 10),
                    child: Text('|', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),),),
                  Text(widget.shopData.oilType, style: TextStyle(fontSize: 17),),
                ],
              ),
              Row(
                children: [
                  Text('보유 진단기', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),),
                  Container(
                    padding: EdgeInsets.only(left: 10, right: 10),
                    child: Text('|', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),),),
                  Text(widget.shopData.diagnosticDevice, style: TextStyle(fontSize: 17),),
                ],
              ),
              SizedBox(height: 50,),
              Text(widget.shopData.comment, style: TextStyle(fontSize: 17),),
            ],
          ),
        ],
      ),
    );
  }
}

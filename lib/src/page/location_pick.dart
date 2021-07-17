import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_place/google_place.dart';
import 'package:hibaike/src/controller/bike_data_controller.dart';
import 'package:hibaike/src/controller/shop_info_controller.dart';
import 'package:hibaike/src/model/address_from_http.dart';
import 'package:hibaike/src/model/location_from_http.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationPick extends StatefulWidget {
  @override
  _LocationPickState createState() => _LocationPickState();
}

class _LocationPickState extends State<LocationPick>
    with WidgetsBindingObserver {
  String fromRoute = Get.arguments;
  GooglePlace googlePlace;
  List<AutocompletePrediction> predictions = [];
  String apiKey = 'AIzaSyAgkR2a33agDSGR2adz2KK-aZ5A_MEbBnw'; // google places api key

  TextEditingController addrCtrl = new TextEditingController();
  AddrFromHttp addrFromHttp = AddrFromHttp();


  @override
  void initState() {
    googlePlace = GooglePlace(apiKey);
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      print('my app is resumed');
      setState(() {

      });
    }
  }

  void autoCompleteSearch(String value) async {
    var result = await googlePlace.autocomplete.get(value, language: "ko");
    if (result != null && result.predictions != null && mounted) {
      setState(() {
        predictions = result.predictions;
      });
    }
  }

  Future<String> getPlaceAddress() async {
    String kakaoAppKey = '3c6646867e44dcf25034a602f046af44';
    var header = {'Authorization': 'KakaoAK $kakaoAppKey'};
    String baseKakaoUrl = "https://dapi.kakao.com/v2/local/search/address.json";
    String completeUrl = '$baseKakaoUrl?query=${addrCtrl.text}';

    final response = await http.get(completeUrl, headers: header);
    print(response.body);

    setState(() {
      addrFromHttp = parseAddress(response.body);
    });
  }

  AddrFromHttp parseAddress(String responseBody) {
    final parsed = json.decode(responseBody);

    return AddrFromHttp.fromJson(parsed);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('판매위치 설정', style: TextStyle(color: Colors.black),),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
          color: Colors.black
        ),

      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    textInputAction: TextInputAction.search,
                    controller: addrCtrl,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: ' 도로명, 건물명 또는 지번으로 검색',
                   ),
                  ),
                ),
                GestureDetector(
                  child: Container(child: Icon(Icons.search)),
                onTap: () {

                  getPlaceAddress();
                  },
                ),
            ]
            ),
            Divider(height: 10,),
            GestureDetector(
              child: Container(
                height: 45,
                //padding: EdgeInsets.symmetric(horizontal: 10),
                margin: EdgeInsets.fromLTRB(10, 15, 10, 0),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.location_searching, color: Colors.black, size: 18,),
                    Text(' 현재 위치로 주소 찾기', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),),
                  ],
                ),
              ),
              onTap: () {
                Get.toNamed('/location/pickLocationWithGoogleMap', arguments: fromRoute);
              },
            ),
            Divider(height: 10,),
            Expanded(
              child: ListView.builder(
                itemCount: addrFromHttp.meta == null ? 0 : addrFromHttp.meta.totalCount,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: CircleAvatar(
                      child: Icon(
                        Icons.pin_drop,
                        color: Colors.white,
                      ),
                    ),
                    title: addrFromHttp.documents[index].address.addressName.length == 0 ?
                        Text(addrFromHttp.documents[index].roadAddress.addressName) :
                        Text(addrFromHttp.documents[index].address.addressName),
                    subtitle: addrFromHttp.documents[index].address.addressName.length == 0 ?
                        SizedBox(height: 0,) :
                        Text(addrFromHttp.documents[index].roadAddress.addressName),
                    onTap: () {
                      BikeDataController ctrl = Get.find();
                      ctrl.setLocation(addrFromHttp.documents[index].roadAddress.region1DepthName,
                          addrFromHttp.documents[index].roadAddress.region2DepthName,
                          addrFromHttp.documents[index].roadAddress.region3DepthName,
                          double.parse(addrFromHttp.documents[index].y),
                          double.parse(addrFromHttp.documents[index].x)
                      );
                      Get.back();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LocationPickWithGoogleMap extends StatefulWidget{
  @override
  _LocationPickWithGoogleMapState createState() => _LocationPickWithGoogleMapState();
}

class _LocationPickWithGoogleMapState extends State<LocationPickWithGoogleMap> with WidgetsBindingObserver{
  String fromRoute = Get.arguments;
  Completer<GoogleMapController> _controller = Completer();
  String apiKey = 'AIzaSyAgkR2a33agDSGR2adz2KK-aZ5A_MEbBnw'; // google places api key
  Position position;
  LatLng currentPosition;
  CameraPosition cameraPosition;
  String addr = '';
  String roadAddr = '';
  String locationLevel0 = ''; // 시도
  String locationLevel1 = ''; // 군구
  String locationLevel2 = ''; // 동
  double param_lat, param_lng;
  var lat, lng;
  bool isLoading;

  @override
  void initState() {
    isLoading = true;
    checkGPAvailability();
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
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
    final GoogleMapController controller = await _controller.future;
    controller.setMapStyle("[]");
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

  Future<LatLng> getUserCurrentPosition () async {
    position = await Geolocator.getCurrentPosition();
    print('my position is lat = ${position.latitude}, lng = ${position
        .longitude}');


    setState(() {
      lat = position.latitude;
      lng = position.longitude;
      isLoading = false;
    });

    final GoogleMapController controller = await _controller.future;

    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
            target: LatLng(position.latitude,position.longitude), zoom: 17.0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('현재위치 설정', style: TextStyle(color: Colors.black),),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
            color: Colors.black
        ),
      ),
      body: isLoading
          ? Center(
        child: CircularProgressIndicator(),
      )
      :Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                GoogleMap(
                  mapType: MapType.normal,
                  initialCameraPosition: CameraPosition(
                    //target: LatLng(37.49639442929692, 127.04438769057595),
                    target: LatLng(lat, lng),
                    zoom: 15,
                  ),
                  onMapCreated: (GoogleMapController controller) {
                    _controller.complete(controller);
                    getAddrFromLocation();
                  },
                  myLocationEnabled: true,
                  zoomControlsEnabled: false,
                  onCameraMoveStarted: _onCameraMoveStarted,
                  onCameraMove: _onCameraMove,
                  onCameraIdle: _onCameraIdle,
                ),
                // Positioned(
                //   child: Icon(
                //     Icons.location_history_rounded,
                //     color: Colors.black,
                //     size: 40,
                //   ),
                //   width: ,
                // ),
                Column(
                  children: [
                    Expanded(
                      child: Center(
                        child: Icon(
                          Icons.location_history_rounded,
                          color: Colors.black,
                          size: 40,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 37,
                    )
                  ],
                ),
              ],
            ),
          ),
          Container(
            height: 70,
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Container(
                        padding: EdgeInsets.all(5.0),
                        child: Text(
                          addr,
                          style: TextStyle(
                              fontSize: 17, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                          softWrap: false,
                          maxLines: 1,
                        )),
                  ],
                ),
                showRoadAddr(),
              ],
            ),
          ),
          GestureDetector(
            child: Container(
              height: 45,
              color: Colors.red,
              child: Center(
                  child: Text(
                '선택한 위치로 설정',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold),
              )),
            ),
            onTap: () {
              if(fromRoute == '/register' || fromRoute == '/update_bike') {
                BikeDataController _ctrl = Get.find();
                _ctrl.setLocation(
                    locationLevel0, locationLevel1, locationLevel2,
                    param_lat, param_lng);
                if (fromRoute == '/register')
                  Get.until((route) => Get.currentRoute == fromRoute);
                else if (fromRoute == '/update_bike')
                  Get.until((route) => Get.currentRoute == fromRoute);
              }
              else if(fromRoute == '/shop/register/location') {
                ShopInfoController _shopInfoController = Get.find();
                _shopInfoController.setLocation(addr, roadAddr, param_lat, param_lng);

                Get.until((route) => Get.currentRoute == fromRoute);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget showRoadAddr() {
    if( (roadAddr.length != 0) && (roadAddr != null)) {
      return Row(
        children: [
          Container(
            child: Text(
              '도로명',
              style: TextStyle(color: Colors.white, fontSize: 13),
            ),
            color: Colors.blue.withOpacity(0.6),
            padding: EdgeInsets.all(5.0),
            margin: EdgeInsets.symmetric(horizontal: 5.0),
          ),
          Expanded(
            child: Text(
              roadAddr,
              style: TextStyle(fontSize: 13, color: Colors.grey),
              overflow: TextOverflow.ellipsis,
              softWrap: false,
              maxLines: 1,
            ),
          ),
        ],
      );
    }
    else
      return SizedBox(height: 0,);
  }

  _onCameraMoveStarted() {
    //print('camera move start');
  }

  _onCameraMove(CameraPosition position) {
    cameraPosition = position;
    //print("camera moving");
  }

  _onCameraIdle() {
    print('camera idle');
    getAddrFromLocation();
  }



  Future<String> getAddrFromLocation() async{
    print( cameraPosition.target.latitude);
    String lat = cameraPosition.target.latitude.toString();//AsFixed(8);
    String lng = cameraPosition.target.longitude.toString();//AsFixed(8);

    String vworldApiKey = '1AA97CC7-0384-3FC4-9C22-E7C601BF3A0D';
    String vworldRequestUrl =
        'http://api.vworld.kr/req/address?service=address&request=getAddress&version=2.0&crs=epsg:4326&point=$lng,$lat&format=json&type=both&zipcode=false&simple=false&key=$vworldApiKey';

    final response = await http.get(vworldRequestUrl);
    print(response.body);

    LocFromHttp location = parseLocation(response.body);
    param_lng  = double.parse(location.input.point.x); // 경도 -180~180
    param_lat = double.parse(location.input.point.y); // 위도 -90 ~ 90

    setState(() {
      addr = '';
      roadAddr = '';

      for(var i = 0 ; i < location.result.length ; i++) {
        if(location.result[i].type == 'parcel') {
          addr = location.result[i].text;
          locationLevel0 = location.result[i].structure.level1;
          locationLevel1 = location.result[i].structure.level2;
          locationLevel2 = location.result[i].structure.level4L;
        }
        else if(location.result[i].type == 'road')setState(() {
          roadAddr = location.result[i].text;
        });
      }
    });
  }

  LocFromHttp parseLocation(String responseBody) {
    final parsed = json.decode(responseBody)['response'];

    return LocFromHttp.fromJson(parsed);
  }
}
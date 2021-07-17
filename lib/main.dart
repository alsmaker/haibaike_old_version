import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:hibaike/src/binding/init_binding.dart';
import 'package:hibaike/src/home.dart';
import 'package:hibaike/src/page/bike_detail_view.dart';
import 'package:hibaike/src/page/bike_list_view.dart';
import 'package:hibaike/src/page/bike_photo_view.dart';
import 'package:hibaike/src/page/chat.dart';
import 'package:hibaike/src/page/chat_room.dart';
import 'package:hibaike/src/page/location_pick.dart';
import 'package:hibaike/src/page/manufacturer_list.dart';
import 'package:hibaike/src/page/my_page.dart';
import 'package:hibaike/src/page/nearby_page.dart';
import 'package:hibaike/src/page/profile_image_test.dart';
import 'package:hibaike/src/page/register_bike.dart';
import 'package:hibaike/src/page/register_shop.dart';
import 'package:hibaike/src/page/sales_list_view.dart';
import 'package:hibaike/src/page/shop_location.dart';
import 'package:hibaike/src/page/shop_view.dart';
import 'package:hibaike/src/page/signup_page.dart';
import 'package:hibaike/src/page/test_appbar.dart';
import 'package:hibaike/src/page/tips_page.dart';
import 'package:hibaike/src/page/update_bike.dart';
import 'package:hibaike/src/page/update_shop.dart';
import 'package:hibaike/src/page/watch_list_view.dart';
import 'package:package_info/package_info.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();


  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
  );

  String homePageRoute;

  @override
  void initState() {
    initPackageInfo();
    super.initState();
  }

  Future<void> initPackageInfo() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });

    RemoteConfig remoteConfig = await RemoteConfig.instance;
    // await remoteConfig.setConfigSettings(RemoteConfigSettings(
    //   fetchTimeoutMillis: 30000,
    //   minimumFetchIntervalMillis: 60000,
    // ));
    // await remoteConfig.setDefaults(<String, dynamic>{
    //   //'HIBAIKE_VERSION_MIN': _packageInfo.buildNumber.toString(),
    //   'HIBAIKE_VERSION_MIN': _packageInfo.buildNumber.toString(),
    // });
    //RemoteConfigValue(null, ValueSource.valueStatic);
    await remoteConfig.fetch(expiration: const Duration(seconds: 1));
    await remoteConfig.activateFetched();

    var remoteString = remoteConfig.getString('HIBAIKE_VERSION_MIN');
    print('remote string value = $remoteString');
    print('build number = ${_packageInfo.buildNumber}');

    if(int.parse(_packageInfo.buildNumber) < int.parse(remoteString)) {
      homePageRoute = '/appbartest';
      Get.toNamed('/appbartest');
    }
    else
      homePageRoute = '/';
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'hibaike',
      theme: ThemeData(
        primaryColor: Colors.red,
        primarySwatch: Colors.red,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialBinding: InitBinding(),
      initialRoute: homePageRoute,
        getPages: [
          GetPage(name: '/', page: () => Home()),
          GetPage(name: '/register', page: () => RegisterBike()),
          GetPage(name: '/manufacturer', page: () => ManufacturerList()),
          GetPage(name: '/location', page: () => LocationPick()),
          GetPage(name: '/location/pickLocationWithGoogleMap', page: () => LocationPickWithGoogleMap()),
          GetPage(name: '/register/progressStore', page: () => UploadProgress()),
          GetPage(name: '/view', page: () => BikeListView()),
          GetPage(name: '/view/detail', page: () => BikeDetailView()),
          GetPage(name: '/view/detail/photos', page: () => BikePhotoView()),
          GetPage(name: '/signUp', page: () => SignUpPage()),
          GetPage(name: '/view/filter', page: ()=> Filter()),
          GetPage(name: '/view/filter/company', page: ()=> FilterCompanyList()),
          GetPage(name: '/myPage', page: ()=>MyPage()),
          GetPage(name: '/signUp/saveProfile', page: ()=>SignUpWithInfo()),
          GetPage(name: '/chat', page: ()=>Chat()),
          GetPage(name: '/chatRoom', page: ()=>ChatRoom()),
          GetPage(name: '/appbartest', page: ()=>AppbarTest()),
          GetPage(name: '/profiletest', page: ()=>ProductDetails()),
          GetPage(name: '/tips', page: ()=>TipsPage()),
          GetPage(name: '/salesListView', page: ()=>SalesListView()),
          GetPage(name: '/watchListView', page: ()=>WatchListView()),
          GetPage(name: '/shop/entry', page: ()=>RegisterShopEntry()),
          GetPage(name: '/shop/view', page: ()=>ShopViewPage()),
          GetPage(name: '/shop/register', page: ()=>RegisterShop()),
          GetPage(name: '/shop/update', page: ()=>UpdateShop()),
          GetPage(name: '/shop/register/location', page: ()=>ShopLocation()),
          GetPage(name: '/update_bike', page: ()=>UpdateBike()),
          GetPage(name: '/nearby', page: ()=>NearbyPage()),
          GetPage(name: '/nearby/registryLocation', page: ()=>RegistryLocation()),
        ],
      defaultTransition: Transition.noTransition,
    );
  }
}
import 'dart:convert';

ShopData shopDataFromJson(String str) => ShopData.fromJson(json.decode(str));

String shopDataToJson(ShopData data) => json.encode(data.toJson());

class ShopData {
  ShopData({
    this.owner,
    this.shopName,
    this.address,
    this.roadAddress,
    this.addressDetail,
    this.shopLocation,
    this.contact,
    this.isOpenPhoneNumber,
    this.oilType,
    this.diagnosticDevice,
    this.comment,
    this.imageList,
  });

  String owner;
  String shopName;
  String address;
  String roadAddress;
  String addressDetail;
  ShopLocation shopLocation;
  String contact;
  bool isOpenPhoneNumber;
  String oilType;
  String diagnosticDevice;
  String comment;
  List<String> imageList;

  factory ShopData.fromJson(Map<String, dynamic> json) => ShopData(
    owner: json["owner"],
    shopName: json["shopName"],
    address: json["address"],
    roadAddress: json["roadAddress"],
    addressDetail: json["addressDetail"],
    shopLocation: ShopLocation.fromJson(json["shopLocation"]),
    contact: json["contact"],
    isOpenPhoneNumber: json["isOpenPhoneNumber"],
    oilType: json["oilType"],
    diagnosticDevice: json["diagnosticDevice"],
    comment: json["comment"],
    imageList: List<String>.from(json["imageList"].map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "owner": owner,
    "shopName": shopName,
    "address": address,
    "roadAddress": roadAddress,
    "addressDetail": addressDetail,
    "shopLocation": shopLocation.toJson(),
    "contact": contact,
    "isOpenPhoneNumber": isOpenPhoneNumber,
    "oilType": oilType,
    "diagnosticDevice": diagnosticDevice,
    "comment": comment,
    "imageList": List<dynamic>.from(imageList.map((x) => x)),
  };
}

class ShopLocation {
  ShopLocation({
    this.lat,
    this.lon,
  });

  double lat;
  double lon;

  factory ShopLocation.fromJson(Map<String, dynamic> json) => ShopLocation(
    lat: json["lat"].toDouble(),
    lon: json["lon"].toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "lat": lat,
    "lon": lon,
  };
}
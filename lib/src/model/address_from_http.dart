// To parse this JSON data, do
//
//     final addrFromHttp = addrFromHttpFromJson(jsonString);

import 'dart:convert';

AddrFromHttp addrFromHttpFromJson(String str) => AddrFromHttp.fromJson(json.decode(str));

String addrFromHttpToJson(AddrFromHttp data) => json.encode(data.toJson());

class AddrFromHttp {
  AddrFromHttp({
    this.documents,
    this.meta,
  });

  List<Document> documents;
  Meta meta;

  factory AddrFromHttp.fromJson(Map<String, dynamic> json) => AddrFromHttp(
    documents: List<Document>.from(json["documents"].map((x) => Document.fromJson(x))),
    meta: Meta.fromJson(json["meta"]),
  );

  Map<String, dynamic> toJson() => {
    "documents": List<dynamic>.from(documents.map((x) => x.toJson())),
    "meta": meta.toJson(),
  };
}

class Document {
  Document({
    this.address,
    this.addressName,
    this.addressType,
    this.roadAddress,
    this.x,
    this.y,
  });

  Address address;
  String addressName;
  String addressType;
  RoadAddress roadAddress;
  String x;
  String y;

  factory Document.fromJson(Map<String, dynamic> json) => Document(
    address: Address.fromJson(json["address"]),
    addressName: json["address_name"],
    addressType: json["address_type"],
    roadAddress: RoadAddress.fromJson(json["road_address"]),
    x: json["x"],
    y: json["y"],
  );

  Map<String, dynamic> toJson() => {
    "address": address.toJson(),
    "address_name": addressName,
    "address_type": addressType,
    "road_address": roadAddress.toJson(),
    "x": x,
    "y": y,
  };
}

class Address {
  Address({
    this.addressName,
    this.bCode,
    this.hCode,
    this.mainAddressNo,
    this.mountainYn,
    this.region1DepthName,
    this.region2DepthName,
    this.region3DepthHName,
    this.region3DepthName,
    this.subAddressNo,
    this.x,
    this.y,
  });

  String addressName;
  String bCode;
  String hCode;
  String mainAddressNo;
  String mountainYn;
  String region1DepthName;
  String region2DepthName;
  String region3DepthHName;
  String region3DepthName;
  String subAddressNo;
  String x;
  String y;


  factory Address.fromJson(Map<String, dynamic> json) {
    if(json != null)
      return Address(
        addressName: json["address_name"],
        bCode: json["b_code"],
        hCode: json["h_code"],
        mainAddressNo: json["main_address_no"],
        mountainYn: json["mountain_yn"],
        region1DepthName: json["region_1depth_name"],
        region2DepthName: json["region_2depth_name"],
        region3DepthHName: json["region_3depth_h_name"],
        region3DepthName: json["region_3depth_name"],
        subAddressNo: json["sub_address_no"],
        x: json["x"],
        y: json["y"],
      );
    else
      return Address(
      addressName: '',
      bCode: '',
      hCode: '',
      mainAddressNo: '',
      mountainYn: '',
      region1DepthName: '',
      region2DepthName: '',
      region3DepthHName: '',
      region3DepthName: '',
      subAddressNo: '',
      x: '',
      y: '',
    );
  }

  Map<String, dynamic> toJson() => {
    "address_name": addressName,
    "b_code": bCode,
    "h_code": hCode,
    "main_address_no": mainAddressNo,
    "mountain_yn": mountainYn,
    "region_1depth_name": region1DepthName,
    "region_2depth_name": region2DepthName,
    "region_3depth_h_name": region3DepthHName,
    "region_3depth_name": region3DepthName,
    "sub_address_no": subAddressNo,
    "x": x,
    "y": y,
  };
}

class RoadAddress {
  RoadAddress({
    this.addressName,
    this.buildingName,
    this.mainBuildingNo,
    this.region1DepthName,
    this.region2DepthName,
    this.region3DepthName,
    this.roadName,
    this.subBuildingNo,
    this.undergroundYn,
    this.x,
    this.y,
    this.zoneNo,
  });

  String addressName;
  String buildingName;
  String mainBuildingNo;
  String region1DepthName;
  String region2DepthName;
  String region3DepthName;
  String roadName;
  String subBuildingNo;
  String undergroundYn;
  String x;
  String y;
  String zoneNo;

  factory RoadAddress.fromJson(Map<String, dynamic> json) => RoadAddress(
    addressName: json["address_name"],
    buildingName: json["building_name"],
    mainBuildingNo: json["main_building_no"],
    region1DepthName: json["region_1depth_name"],
    region2DepthName: json["region_2depth_name"],
    region3DepthName: json["region_3depth_name"],
    roadName: json["road_name"],
    subBuildingNo: json["sub_building_no"],
    undergroundYn: json["underground_yn"],
    x: json["x"],
    y: json["y"],
    zoneNo: json["zone_no"],
  );

  Map<String, dynamic> toJson() => {
    "address_name": addressName,
    "building_name": buildingName,
    "main_building_no": mainBuildingNo,
    "region_1depth_name": region1DepthName,
    "region_2depth_name": region2DepthName,
    "region_3depth_name": region3DepthName,
    "road_name": roadName,
    "sub_building_no": subBuildingNo,
    "underground_yn": undergroundYn,
    "x": x,
    "y": y,
    "zone_no": zoneNo,
  };
}

class Meta {
  Meta({
    this.isEnd,
    this.pageableCount,
    this.totalCount,
  });

  bool isEnd;
  int pageableCount;
  int totalCount;

  factory Meta.fromJson(Map<String, dynamic> json) => Meta(
    isEnd: json["is_end"],
    pageableCount: json["pageable_count"],
    totalCount: json["total_count"],
  );

  Map<String, dynamic> toJson() => {
    "is_end": isEnd,
    "pageable_count": pageableCount,
    "total_count": totalCount,
  };
}

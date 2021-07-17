// To parse this JSON data, do
//
//     final users = usersFromJson(jsonString);

import 'dart:convert';

Users usersFromJson(String str) => Users.fromJson(json.decode(str));

String usersToJson(Users data) => json.encode(data.toJson());

class Users {
  Users({
    this.USPhoneNumber,
    this.KorPhoneNumber,
    this.nickName,
    this.grade,
    this.shopId,
    this.uid,
    this.profileImageUrl,
    this.watchList
  });

  String USPhoneNumber;
  String KorPhoneNumber;
  String nickName;
  String grade;
  String shopId;
  String uid;
  String profileImageUrl;
  List<String> watchList;

  factory Users.fromJson(Map<String, dynamic> json) => Users(
    USPhoneNumber: json["us_phone_number"],
    KorPhoneNumber: json["kor_phone_number"],
    nickName: json["nick_name"],
    grade: json["grade"],
    uid: json["uid"],
    shopId: json["shop_id"] != null ? json["shop_id"] : '',
    profileImageUrl: json["profile_image_url"],
    watchList: json["watch_list"] != null ? List<String>.from(json["watch_list"].map((x) => x)) : [],
  );

  Map<String, dynamic> toJson() => {
    "us_phone_number": USPhoneNumber,
    "kor_phone_number": KorPhoneNumber,
    "nick_name": nickName,
    "grade": grade,
    "shop_id": shopId,
    "uid": uid,
    "profile_image_url": profileImageUrl,
    "watch_list": List<dynamic>.from(watchList.map((x) => x)),
  };
}
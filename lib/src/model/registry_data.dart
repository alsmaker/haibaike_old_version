import 'dart:convert';

RegistryData registryDataFromJson(String str) => RegistryData.fromJson(json.decode(str));

String registryDataToJson(RegistryData data) => json.encode(data.toJson());

class RegistryData {
  RegistryData({
    this.name,
    this.address,
    this.roadAddress,
    this.contact,
    this.location,
  });

  String name;
  String address;
  String roadAddress;
  String contact;
  Location location;

  factory RegistryData.fromJson(Map<String, dynamic> json) => RegistryData(
    name: json["name"],
    address: json["address"],
    roadAddress: json["road_address"],
    contact: json["contact"],
    location: Location.fromJson(json["location"]),
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "address": address,
    "road_address": roadAddress,
    "contact": contact,
    "location": location.toJson(),
  };
}

class Location {
  Location({
    this.lat,
    this.lon,
  });

  double lat;
  double lon;

  factory Location.fromJson(Map<String, dynamic> json) => Location(
    lat: json["lat"].toDouble(),
    lon: json["lon"].toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "lat": lat,
    "lon": lon,
  };
}

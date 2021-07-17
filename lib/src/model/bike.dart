class BikeData {
  final String key;
  final String manufacturer;
  final String model;
  final int displacement;
  final int birthYear;
  final int mileage;
  final int amount;
  final String locationLevel0;
  final String locationLevel1;
  final String locationLevel2;
  final Location location;
  final String gearType;
  final String fuelType;
  final String isTuned;
  final String possibleAS;
  final String comment;
  final List<String> imageList;
  final String createdTime;
  final int createdTimeMilliseconds;
  final String ownerUid;

  BikeData(
      {this.key,
      this.manufacturer,
      this.model,
      this.displacement,
      this.birthYear,
      this.mileage,
      this.amount,
      this.locationLevel0,
      this.locationLevel1,
      this.locationLevel2,
      this.location,
      this.gearType,
      this.fuelType,
      this.isTuned,
      this.possibleAS,
      this.comment,
      this.imageList,
      this.createdTime,
        this.createdTimeMilliseconds,
      this.ownerUid});

  factory BikeData.fromJson(Map<String, dynamic> json) => BikeData(
    key: json["key"],
    amount: json["amount"],
    birthYear: json["birthYear"],
    comment: json["comment"],
    manufacturer: json["manufacturer"],
    displacement: json["displacement"],
    fuelType: json["fuelType"],
    gearType: json["gearType"],
    locationLevel0: json["location_level0"],
    locationLevel1: json["location_level1"],
    locationLevel2: json["location_level2"],
    location: Location.fromJson(json["location"]),
    imageList: List<String>.from(json["imageList"].map((x) => x)),
    isTuned: json["isTuned"],
    mileage: json["mileage"],
    model: json["model"],
    possibleAS: json["possibleAS"],
    createdTime: json["createdTime"],
    createdTimeMilliseconds: json["createdTimeMilliseconds"],
    ownerUid: json["ownerUid"],
  );

  toJson() {
    return {
      'key': key,
      'manufacturer' : manufacturer,
      'model' : model,
      'displacement' : displacement,
      'birthYear' : birthYear,
      'mileage' : mileage,
      'amount' : amount,
      'location_level0' : locationLevel0,
      'location_level1' : locationLevel1,
      'location_level2' : locationLevel2,
      "location": location.toJson(),
      'gearType' : gearType,
      'fuelType' : fuelType,
      'isTuned' : isTuned,
      'possibleAS' : possibleAS,
      'comment' : comment,
      'imageList': imageList,
      'createdTime' : createdTime,
      'createdTimeMilliseconds' : createdTimeMilliseconds,
      'ownerUid' : ownerUid,
    };
  }
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

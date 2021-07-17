// To parse this JSON data, do
//
//     final locFromHttp = locFromHttpFromJson(jsonString);

import 'dart:convert';

LocFromHttp locFromHttpFromJson(String str) => LocFromHttp.fromJson(json.decode(str));

String locFromHttpToJson(LocFromHttp data) => json.encode(data.toJson());

class LocFromHttp {
  LocFromHttp({
    this.service,
    this.status,
    this.input,
    this.result,
  });

  Service service;
  String status;
  Input input;
  List<Result> result;

  factory LocFromHttp.fromJson(Map<String, dynamic> json) => LocFromHttp(
    service: Service.fromJson(json["service"]),
    status: json["status"],
    input: Input.fromJson(json["input"]),
    result: List<Result>.from(json["result"].map((x) => Result.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "service": service.toJson(),
    "status": status,
    "input": input.toJson(),
    "result": List<dynamic>.from(result.map((x) => x.toJson())),
  };
}

class Input {
  Input({
    this.point,
    this.crs,
    this.type,
  });

  Point point;
  String crs;
  String type;

  factory Input.fromJson(Map<String, dynamic> json) => Input(
    point: Point.fromJson(json["point"]),
    crs: json["crs"],
    type: json["type"],
  );

  Map<String, dynamic> toJson() => {
    "point": point.toJson(),
    "crs": crs,
    "type": type,
  };
}

class Point {
  Point({
    this.x,
    this.y,
  });

  String x;
  String y;

  factory Point.fromJson(Map<String, dynamic> json) => Point(
    x: json["x"],
    y: json["y"],
  );

  Map<String, dynamic> toJson() => {
    "x": x,
    "y": y,
  };
}

class Result {
  Result({
    this.type,
    this.text,
    this.structure,
  });

  String type;
  String text;
  Structure structure;

  factory Result.fromJson(Map<String, dynamic> json) => Result(
    type: json["type"],
    text: json["text"],
    structure: Structure.fromJson(json["structure"]),
  );

  Map<String, dynamic> toJson() => {
    "type": type,
    "text": text,
    "structure": structure.toJson(),
  };
}

class Structure {
  Structure({
    this.level0,
    this.level1,
    this.level2,
    this.level3,
    this.level4L,
    this.level4Lc,
    this.level4A,
    this.level4Ac,
    this.level5,
    this.detail,
  });

  String level0;
  String level1;
  String level2;
  String level3;
  String level4L;
  String level4Lc;
  String level4A;
  String level4Ac;
  String level5;
  String detail;

  factory Structure.fromJson(Map<String, dynamic> json) => Structure(
    level0: json["level0"],
    level1: json["level1"],
    level2: json["level2"],
    level3: json["level3"],
    level4L: json["level4L"],
    level4Lc: json["level4LC"],
    level4A: json["level4A"],
    level4Ac: json["level4AC"],
    level5: json["level5"],
    detail: json["detail"],
  );

  Map<String, dynamic> toJson() => {
    "level0": level0,
    "level1": level1,
    "level2": level2,
    "level3": level3,
    "level4L": level4L,
    "level4LC": level4Lc,
    "level4A": level4A,
    "level4AC": level4Ac,
    "level5": level5,
    "detail": detail,
  };
}

class Service {
  Service({
    this.name,
    this.version,
    this.operation,
    this.time,
  });

  String name;
  String version;
  String operation;
  String time;

  factory Service.fromJson(Map<String, dynamic> json) => Service(
    name: json["name"],
    version: json["version"],
    operation: json["operation"],
    time: json["time"],
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "version": version,
    "operation": operation,
    "time": time,
  };
}

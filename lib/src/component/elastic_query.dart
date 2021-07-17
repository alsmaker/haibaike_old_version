import 'dart:convert';


String elasticsearchQueryToJson(ElasticsearchQuery data) => json.encode(data.toJson());

class ElasticsearchQuery {
  ElasticsearchQuery({
    this.elasticsearchQueryBool,
  });

  Bool elasticsearchQueryBool;

  Map<String, dynamic> toJson() => {
    "bool": elasticsearchQueryBool.toJson(),
  };
}

class Bool {
  Bool({
    this.must,
    this.filter,
    this.sort,
  });

  List<Must> must;
  List<Filter> filter;
  List<Sort> sort;

  factory Bool.fromJson(Map<String, dynamic> json) => Bool(
    must: List<Must>.from(json["must"].map((x) => Must.fromJson(x))),
    filter: List<Filter>.from(json["filter"].map((x) => Filter.fromJson(x))),
    sort: List<Sort>.from(json["sort"].map((x) => Sort.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "must": List<dynamic>.from(must.map((x) => x.toJson())),
    "filter": List<dynamic>.from(filter.map((x) => x.toJson())),
    "sort": List<dynamic>.from(sort.map((x) => x.toJson())),
  };
}

class Filter {
  Filter({
    this.range,
  });

  Range range;

  factory Filter.fromJson(Map<String, dynamic> json) => Filter(
    range: Range.fromJson(json["range"]),
  );

  Map<String, dynamic> toJson() => {
    "range": range.toJson(),
  };
}

class Range {
  Range({
    this.displacement,
    this.amount,
    this.milage,
  });

  Amount displacement;
  Amount amount;
  Amount milage;

  factory Range.fromJson(Map<String, dynamic> json) => Range(
    displacement: json["displacement"] == null ? null : Amount.fromJson(json["displacement"]),
    amount: json["amount"] == null ? null : Amount.fromJson(json["amount"]),
    milage: json["milage"] == null ? null : Amount.fromJson(json["milage"]),
  );

  Map<String, dynamic> toJson() => {
    "displacement": displacement == null ? null : displacement.toJson(),
    "amount": amount == null ? null : amount.toJson(),
    "milage": milage == null ? null : milage.toJson(),
  };
}

class Amount {
  Amount({
    this.gte,
    this.lte,
  });

  int gte;
  int lte;

  factory Amount.fromJson(Map<String, dynamic> json) => Amount(
    gte: json["gte"],
    lte: json["lte"],
  );

  Map<String, dynamic> toJson() => {
    "gte": gte,
    "lte": lte,
  };
}

class Must {
  Must({
    this.match,
  });

  Match match;

  factory Must.fromJson(Map<String, dynamic> json) => Must(
    match: Match.fromJson(json["match"]),
  );

  Map<String, dynamic> toJson() => {
    "match": match.toJson(),
  };
}

class Match {
  Match({
    this.company,
    this.model,
  });

  String company;
  String model;

  factory Match.fromJson(Map<String, dynamic> json) => Match(
    company: json["company"] == null ? null : json["company"],
    model: json["model"] == null ? null : json["model"],
  );

  Map<String, dynamic> toJson() => {
    "company": company == null ? null : company,
    "model": model == null ? null : model,
  };
}

class Sort {
  Sort({
    this.name,
  });

  String name;

  factory Sort.fromJson(Map<String, dynamic> json) => Sort(
    name: json["name"],
  );

  Map<String, dynamic> toJson() => {
    "name": name,
  };
}
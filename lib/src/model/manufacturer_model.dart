class ModelNSpec {
  final String name;
  final int displacement;

  ModelNSpec({this.name, this.displacement});

  factory ModelNSpec.fromJson(Map<String, dynamic> json) {
    return ModelNSpec(
        name: json['name'],
        displacement: json['displacement']);
  }
}

class ManufacturerNModel {
  final String manufacturer;
  final List<ModelNSpec> modelNSpec;

  ManufacturerNModel({this.manufacturer, this.modelNSpec});

  factory ManufacturerNModel.fromJson(Map<String, dynamic> parsedJson) {
    var list = parsedJson['model'] as List;
    print(list.runtimeType); //returns List<dynamic>
    List<ModelNSpec> modelList = list.map((i) => ModelNSpec.fromJson(i)).toList();
    return ManufacturerNModel(
        manufacturer: parsedJson['company'],
        modelNSpec: modelList);
    //modelSpec: ModelSpec.fromJson(parsedJson['model']));
  }
}
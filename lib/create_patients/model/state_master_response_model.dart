// To parse this JSON data, do
//
//     final stateMasterResponseModel = stateMasterResponseModelFromJson(jsonString);

import 'dart:convert';

StateMasterResponseModel stateMasterResponseModelFromJson(String str) => StateMasterResponseModel.fromJson(json.decode(str));

String stateMasterResponseModelToJson(StateMasterResponseModel data) => json.encode(data.toJson());

class StateMasterResponseModel {
  String? message;
  bool? isSuccess;
  dynamic pageResult;
  List<Result>? result;
  dynamic errors;

  StateMasterResponseModel({
    this.message,
    this.isSuccess,
    this.pageResult,
    this.result,
    this.errors,
  });

  factory StateMasterResponseModel.fromJson(Map<String, dynamic> json) => StateMasterResponseModel(
    message: json["message"],
    isSuccess: json["isSuccess"],
    pageResult: json["pageResult"],
    result: json["result"] == null ? [] : List<Result>.from(json["result"]!.map((x) => Result.fromJson(x))),
    errors: json["errors"],
  );

  Map<String, dynamic> toJson() => {
    "message": message,
    "isSuccess": isSuccess,
    "pageResult": pageResult,
    "result": result == null ? [] : List<dynamic>.from(result!.map((x) => x.toJson())),
    "errors": errors,
  };
}

class Result {
  String? name;
  Code? code;
  int? numericCode;
  int? countryId;
  dynamic country;
  String? uniqueGuid;
  int? id;

  Result({
    this.name,
    this.code,
    this.numericCode,
    this.countryId,
    this.country,
    this.uniqueGuid,
    this.id,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
    name: json["name"],
    code: codeValues.map[json["code"]]!,
    numericCode: json["numericCode"],
    countryId: json["countryId"],
    country: json["country"],
    uniqueGuid: json["uniqueGuid"],
    id: json["id"],
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "code": codeValues.reverse[code],
    "numericCode": numericCode,
    "countryId": countryId,
    "country": country,
    "uniqueGuid": uniqueGuid,
    "id": id,
  };
}

enum Code {
  EMPTY
}

final codeValues = EnumValues({
  " ": Code.EMPTY
});

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}

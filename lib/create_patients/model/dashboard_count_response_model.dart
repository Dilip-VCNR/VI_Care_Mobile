
// To parse this JSON data, do
//
//     final dashboardCountResponseModel = dashboardCountResponseModelFromJson(jsonString);

import 'dart:convert';

DashboardCountResponseModel dashboardCountResponseModelFromJson(String str) => DashboardCountResponseModel.fromJson(json.decode(str));

String dashboardCountResponseModelToJson(DashboardCountResponseModel data) => json.encode(data.toJson());

class DashboardCountResponseModel {
  String? message;
  bool? isSuccess;
  dynamic pageResult;
  Result? result;
  dynamic errors;

  DashboardCountResponseModel({
    this.message,
    this.isSuccess,
    this.pageResult,
    this.result,
    this.errors,
  });

  factory DashboardCountResponseModel.fromJson(Map<String, dynamic> json) => DashboardCountResponseModel(
    message: json["message"],
    isSuccess: json["isSuccess"],
    pageResult: json["pageResult"],
    result: json["result"] == null ? null : Result.fromJson(json["result"]),
    errors: json["errors"],
  );

  Map<String, dynamic> toJson() => {
    "message": message,
    "isSuccess": isSuccess,
    "pageResult": pageResult,
    "result": result?.toJson(),
    "errors": errors,
  };
}

class Result {
  String? lastTested;
  int? totalTests;
  int? reportsCount;

  Result({
    this.lastTested,
    this.totalTests,
    this.reportsCount,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
    lastTested: json["lastTested"],
    totalTests: json["totalTests"],
    reportsCount: json["reportsCount"],
  );

  Map<String, dynamic> toJson() => {
    "lastTested": lastTested,
    "totalTests": totalTests,
    "reportsCount": reportsCount,
  };
}
// To parse this JSON data, do
//
//     final addDeviceResponseModel = addDeviceResponseModelFromJson(jsonString);

import 'dart:convert';

AddDeviceResponseModel addDeviceResponseModelFromJson(String str) => AddDeviceResponseModel.fromJson(json.decode(str));

String addDeviceResponseModelToJson(AddDeviceResponseModel data) => json.encode(data.toJson());

class AddDeviceResponseModel {
  String? message;
  bool? isSuccess;
  dynamic pageResult;
  Result? result;
  dynamic errors;

  AddDeviceResponseModel({
    this.message,
    this.isSuccess,
    this.pageResult,
    this.result,
    this.errors,
  });

  factory AddDeviceResponseModel.fromJson(Map<String, dynamic> json) => AddDeviceResponseModel(
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
  String? type;
  String? deviceSerialNo;
  bool? isPaired;
  int? roleId;
  dynamic role;
  int? userId;
  dynamic user;
  int? deviceId;
  dynamic device;
  String? uniqueGuid;
  int? id;

  Result({
    this.type,
    this.deviceSerialNo,
    this.isPaired,
    this.roleId,
    this.role,
    this.userId,
    this.user,
    this.deviceId,
    this.device,
    this.uniqueGuid,
    this.id,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
    type: json["type"],
    deviceSerialNo: json["deviceSerialNo"],
    isPaired: json["isPaired"],
    roleId: json["roleId"],
    role: json["role"],
    userId: json["userId"],
    user: json["user"],
    deviceId: json["deviceId"],
    device: json["device"],
    uniqueGuid: json["uniqueGuid"],
    id: json["id"],
  );

  Map<String, dynamic> toJson() => {
    "type": type,
    "deviceSerialNo": deviceSerialNo,
    "isPaired": isPaired,
    "roleId": roleId,
    "role": role,
    "userId": userId,
    "user": user,
    "deviceId": deviceId,
    "device": device,
    "uniqueGuid": uniqueGuid,
    "id": id,
  };
}

// To parse this JSON data, do
//
//     final detailedReportPdfModel = detailedReportPdfModelFromJson(jsonString);

import 'dart:convert';

import 'package:vicare/create_patients/model/add_individual_profile_response_model.dart';

DetailedReportPdfModel detailedReportPdfModelFromJson(String str) => DetailedReportPdfModel.fromJson(json.decode(str));

String detailedReportPdfModelToJson(DetailedReportPdfModel data) => json.encode(data.toJson());

class DetailedReportPdfModel {
  String? message;
  bool? isSuccess;
  dynamic pageResult;
  List<Result>? result;
  dynamic errors;

  DetailedReportPdfModel({
    this.message,
    this.isSuccess,
    this.pageResult,
    this.result,
    this.errors,
  });

  factory DetailedReportPdfModel.fromJson(Map<String, dynamic> json) => DetailedReportPdfModel(
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
  String? path;
  dynamic tags;
  dynamic source;
  int? length;
  String? savedFilename;
  String? actualFilename;
  String? url;
  String? sthreeKey;
  int? fileType;
  dynamic requestDeviceId;
  RequestDeviceData? requestDeviceData;
  String? uniqueGuid;
  int? id;

  Result({
    this.name,
    this.path,
    this.tags,
    this.source,
    this.length,
    this.savedFilename,
    this.actualFilename,
    this.url,
    this.sthreeKey,
    this.fileType,
    this.requestDeviceId,
    this.requestDeviceData,
    this.uniqueGuid,
    this.id,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
    name: json["name"],
    path: json["path"],
    tags: json["tags"],
    source: json["source"],
    length: json["length"],
    savedFilename: json["savedFilename"],
    actualFilename: json["actualFilename"],
    url: json["url"],
    sthreeKey: json["sthreeKey"],
    fileType: json["fileType"],
    requestDeviceId: json["requestDeviceId"],
    requestDeviceData: json["requestDeviceData"] == null ? null : RequestDeviceData.fromJson(json["requestDeviceData"]),
    uniqueGuid: json["uniqueGuid"],
    id: json["id"],
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "path": path,
    "tags": tags,
    "source": source,
    "length": length,
    "savedFilename": savedFilename,
    "actualFilename": actualFilename,
    "url": url,
    "sthreeKey": sthreeKey,
    "fileType": fileType,
    "requestDeviceId": requestDeviceId,
    "requestDeviceData": requestDeviceData?.toJson(),
    "uniqueGuid": uniqueGuid,
    "id": id,
  };
}

class RequestDeviceData {
  String? details;
  String? requestDateTime;
  int? processingStatus;
  String? processedDate;
  dynamic inputData;
  int? fileType;
  String? durationName;
  String? deviceSerialNo;
  String? ipAddress;
  int? userAndDeviceId;
  dynamic subscriberGuid;
  int? subscriberId;
  dynamic subscriber;
  int? deviceId;
  dynamic device;
  int? durationId;
  dynamic duration;
  int? userId;
  User? user;
  int? deviceDocumentId;
  dynamic deviceDocument;
  int? roleId;
  dynamic role;
  int? individualProfileId;
  IndividualProfile? individualProfile;
  dynamic enterpriseProfileId;
  EnterpriseProfile? enterpriseProfile;
  String? uniqueGuid;
  int? id;

  RequestDeviceData({
    this.details,
    this.requestDateTime,
    this.processingStatus,
    this.processedDate,
    this.inputData,
    this.fileType,
    this.durationName,
    this.deviceSerialNo,
    this.ipAddress,
    this.userAndDeviceId,
    this.subscriberGuid,
    this.subscriberId,
    this.subscriber,
    this.deviceId,
    this.device,
    this.durationId,
    this.duration,
    this.userId,
    this.user,
    this.deviceDocumentId,
    this.deviceDocument,
    this.roleId,
    this.role,
    this.individualProfileId,
    this.individualProfile,
    this.enterpriseProfileId,
    this.enterpriseProfile,
    this.uniqueGuid,
    this.id,
  });

  factory RequestDeviceData.fromJson(Map<String, dynamic> json) => RequestDeviceData(
    details: json["details"],
    requestDateTime: json["requestDateTime"],
    processingStatus: json["processingStatus"],
    processedDate: json["processedDate"],
    inputData: json["inputData"],
    fileType: json["fileType"],
    durationName: json["durationName"],
    deviceSerialNo: json["deviceSerialNo"],
    ipAddress: json["ipAddress"],
    userAndDeviceId: json["userAndDeviceId"],
    subscriberGuid: json["subscriberGuid"],
    subscriberId: json["subscriberId"],
    subscriber: json["subscriber"],
    deviceId: json["deviceId"],
    device: json["device"],
    durationId: json["durationId"],
    duration: json["duration"],
    userId: json["userId"],
    user: json["user"] == null ? null : User.fromJson(json["user"]),
    deviceDocumentId: json["deviceDocumentId"],
    deviceDocument: json["deviceDocument"],
    roleId: json["roleId"],
    role: json["role"],
    individualProfileId: json["individualProfileId"],
    individualProfile: json["individualProfile"] == null ? null : IndividualProfile.fromJson(json["individualProfile"]),
    enterpriseProfileId: json["enterpriseProfileId"],
    enterpriseProfile: json["enterpriseProfile"] == null ? null : EnterpriseProfile.fromJson(json["enterpriseProfile"]),
    uniqueGuid: json["uniqueGuid"],
    id: json["id"],
  );

  Map<String, dynamic> toJson() => {
    "details": details,
    "requestDateTime": requestDateTime,
    "processingStatus": processingStatus,
    "processedDate": processedDate,
    "inputData": inputData,
    "fileType": fileType,
    "durationName": durationName,
    "deviceSerialNo": deviceSerialNo,
    "ipAddress": ipAddress,
    "userAndDeviceId": userAndDeviceId,
    "subscriberGuid": subscriberGuid,
    "subscriberId": subscriberId,
    "subscriber": subscriber,
    "deviceId": deviceId,
    "device": device,
    "durationId": durationId,
    "duration": duration,
    "userId": userId,
    "user": user?.toJson(),
    "deviceDocumentId": deviceDocumentId,
    "deviceDocument": deviceDocument,
    "roleId": roleId,
    "role": role,
    "individualProfileId": individualProfileId,
    "individualProfile": individualProfile?.toJson(),
    "enterpriseProfileId": enterpriseProfileId,
    "enterpriseProfile": enterpriseProfile?.toJson(),
    "uniqueGuid": uniqueGuid,
    "id": id,
  };
}

class IndividualProfile {
  String? firstName;
  String? lastName;
  String? email;
  String? bmi;
  bool? isSelf;
  int? contactId;
  dynamic contact;
  int? userId;
  User? user;
  int? profilePictureId;
  ProfilePicture? profilePicture;
  String? uniqueGuid;
  int? id;

  IndividualProfile({
    this.firstName,
    this.lastName,
    this.email,
    this.bmi,
    this.isSelf,
    this.contactId,
    this.contact,
    this.userId,
    this.user,
    this.profilePictureId,
    this.profilePicture,
    this.uniqueGuid,
    this.id,
  });

  factory IndividualProfile.fromJson(Map<String, dynamic> json) => IndividualProfile(
    firstName: json["firstName"],
    lastName: json["lastName"],
    email: json["email"],
    bmi: json["bmi"],
    isSelf: json["isSelf"],
    contactId: json["contactId"],
    contact: json["contact"],
    userId: json["userId"],
    user: json["user"] == null ? null : User.fromJson(json["user"]),
    profilePictureId: json["profilePictureId"],
    profilePicture: json["profilePicture"] == null ? null : ProfilePicture.fromJson(json["profilePicture"]),
    uniqueGuid: json["uniqueGuid"],
    id: json["id"],
  );

  Map<String, dynamic> toJson() => {
    "firstName": firstName,
    "lastName": lastName,
    "email": email,
    "bmi": bmi,
    "isSelf": isSelf,
    "contactId": contactId,
    "contact": contact,
    "userId": userId,
    "user": user?.toJson(),
    "profilePictureId": profilePictureId,
    "profilePicture": profilePicture?.toJson(),
    "uniqueGuid": uniqueGuid,
    "id": id,
  };
}

class ProfilePicture {
  String? name;
  dynamic type;
  String? path;
  dynamic tags;
  int? length;
  String? savedFileName;
  String? actualFileName;
  int? fileType;
  String? sthreeKey;
  String? url;
  dynamic deviceId;
  String? uniqueGuid;
  int? id;

  ProfilePicture({
    this.name,
    this.type,
    this.path,
    this.tags,
    this.length,
    this.savedFileName,
    this.actualFileName,
    this.fileType,
    this.sthreeKey,
    this.url,
    this.deviceId,
    this.uniqueGuid,
    this.id,
  });

  factory ProfilePicture.fromJson(Map<String, dynamic> json) => ProfilePicture(
    name: json["name"],
    type: json["type"],
    path: json["path"],
    tags: json["tags"],
    length: json["length"],
    savedFileName: json["savedFileName"],
    actualFileName: json["actualFileName"],
    fileType: json["fileType"],
    sthreeKey: json["sthreeKey"],
    url: json["url"],
    deviceId: json["deviceId"],
    uniqueGuid: json["uniqueGuid"],
    id: json["id"],
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "type": type,
    "path": path,
    "tags": tags,
    "length": length,
    "savedFileName": savedFileName,
    "actualFileName": actualFileName,
    "fileType": fileType,
    "sthreeKey": sthreeKey,
    "url": url,
    "deviceId": deviceId,
    "uniqueGuid": uniqueGuid,
    "id": id,
  };
}

class User {
  String? email;
  String? contactNumber;
  String? passwordHash;
  String? passwordSalt;
  dynamic type;
  int? status;
  dynamic remarks;
  dynamic token;
  String? bmi;
  int? contactId;
  Contact? contact;
  int? roleId;
  dynamic role;
  int? profilePictureId;
  dynamic profilePicture;
  dynamic enterpriseId;
  dynamic enterprise;
  dynamic enterpriseUserId;
  dynamic enterpriseUser;
  dynamic individualProfileId;
  String? uniqueGuid;
  int? id;

  User({
    this.email,
    this.contactNumber,
    this.passwordHash,
    this.passwordSalt,
    this.type,
    this.status,
    this.remarks,
    this.token,
    this.bmi,
    this.contactId,
    this.contact,
    this.roleId,
    this.role,
    this.profilePictureId,
    this.profilePicture,
    this.enterpriseId,
    this.enterprise,
    this.enterpriseUserId,
    this.enterpriseUser,
    this.individualProfileId,
    this.uniqueGuid,
    this.id,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    email: json["email"],
    contactNumber: json["contactNumber"],
    passwordHash: json["passwordHash"],
    passwordSalt: json["passwordSalt"],
    type: json["type"],
    status: json["status"],
    remarks: json["remarks"],
    token: json["token"],
    bmi: json["bmi"],
    contactId: json["contactId"],
    contact: json["contact"] == null ? null : Contact.fromJson(json["contact"]),
    roleId: json["roleId"],
    role: json["role"],
    profilePictureId: json["profilePictureId"],
    profilePicture: json["profilePicture"],
    enterpriseId: json["enterpriseId"],
    enterprise: json["enterprise"],
    enterpriseUserId: json["enterpriseUserId"],
    enterpriseUser: json["enterpriseUser"],
    individualProfileId: json["individualProfileId"],
    uniqueGuid: json["uniqueGuid"],
    id: json["id"],
  );

  Map<String, dynamic> toJson() => {
    "email": email,
    "contactNumber": contactNumber,
    "passwordHash": passwordHash,
    "passwordSalt": passwordSalt,
    "type": type,
    "status": status,
    "remarks": remarks,
    "token": token,
    "bmi":bmi,
    "contactId": contactId,
    "contact": contact?.toJson(),
    "roleId": roleId,
    "role": role,
    "profilePictureId": profilePictureId,
    "profilePicture": profilePicture,
    "enterpriseId": enterpriseId,
    "enterprise": enterprise,
    "enterpriseUserId": enterpriseUserId,
    "enterpriseUser": enterpriseUser,
    "individualProfileId": individualProfileId,
    "uniqueGuid": uniqueGuid,
    "id": id,
  };
}

class Contact {
  String? firstName;
  String? lastName;
  String? email;
  String? contactNumber;
  String? doB;
  int? gender;
  String? bloodGroup;
  int? addressId;
  Address? address;
  String? uniqueGuid;
  int? id;

  Contact({
    this.firstName,
    this.lastName,
    this.email,
    this.contactNumber,
    this.doB,
    this.gender,
    this.bloodGroup,
    this.addressId,
    this.address,
    this.uniqueGuid,
    this.id,
  });

  factory Contact.fromJson(Map<String, dynamic> json) => Contact(
    firstName: json["firstName"],
    lastName: json["lastName"],
    email: json["email"],
    contactNumber: json["contactNumber"],
    doB: json["doB"],
    gender: json["gender"],
    bloodGroup: json["bloodGroup"],
    addressId: json["addressId"],
    address: json["address"] == null ? null : Address.fromJson(json["address"]),
    uniqueGuid: json["uniqueGuid"],
    id: json["id"],
  );

  Map<String, dynamic> toJson() => {
    "firstName": firstName,
    "lastName": lastName,
    "email": email,
    "contactNumber": contactNumber,
    "doB": doB,
    "gender": gender,
    "bloodGroup": bloodGroup,
    "addressId": addressId,
    "address": address?.toJson(),
    "uniqueGuid": uniqueGuid,
    "id": id,
  };
}

class Address {
  String? street;
  String? area;
  String? landmark;
  String? city;
  String? pinCode;
  dynamic longitude;
  dynamic latitude;
  int? stateId;
  dynamic state;
  String? uniqueGuid;
  int? id;

  Address({
    this.street,
    this.area,
    this.landmark,
    this.city,
    this.pinCode,
    this.longitude,
    this.latitude,
    this.stateId,
    this.state,
    this.uniqueGuid,
    this.id,
  });

  factory Address.fromJson(Map<String, dynamic> json) => Address(
    street: json["street"],
    area: json["area"],
    landmark: json["landmark"],
    city: json["city"],
    pinCode: json["pinCode"],
    longitude: json["longitude"],
    latitude: json["latitude"],
    stateId: json["stateId"],
    state: json["state"],
    uniqueGuid: json["uniqueGuid"],
    id: json["id"],
  );

  Map<String, dynamic> toJson() => {
    "street": street,
    "area": area,
    "landmark": landmark,
    "city": city,
    "pinCode": pinCode,
    "longitude": longitude,
    "latitude": latitude,
    "stateId": stateId,
    "state": state,
    "uniqueGuid": uniqueGuid,
    "id": id,
  };
}

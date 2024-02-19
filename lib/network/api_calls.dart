import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:vicare/auth/model/send_otp_response_model.dart';
import 'package:vicare/create_patients/model/add_individual_profile_response_model.dart';
import 'package:vicare/utils/app_buttons.dart';

import '../auth/model/register_response_model.dart';
import '../auth/model/role_master_response_model.dart';
import '../database/app_pref.dart';
import '../database/models/pref_model.dart';
import '../utils/url_constants.dart';

String platform = Platform.isIOS ? "IOS" : "Android";

PrefModel prefModel = AppPref.getPref();

class ApiCalls {
  Future<http.Response> hitApiPost(
      bool requiresAuth, String url, String body) async {
    return await http.post(
      Uri.parse(url),
      headers: getHeaders(requiresAuth),
      body: body,
    );
  }

  Future<http.Response> hitApiGet(bool requiresAuth, String url) async {
    return await http.get(
      Uri.parse(url),
      headers: getHeaders(requiresAuth),
    );
  }

  Map<String, String> getHeaders(bool isAuthEnabled) {
    var headers = <String, String>{};
    if (isAuthEnabled) {
      headers.addAll({
        "x-access-token": "${prefModel.userData!.token}",
        "Content-Type": "application/json"
      });
    } else {
      headers.addAll({"Content-Type": "application/json"});
    }
    return headers;
  }

  Future<SendOtpResponseModel> sendOtpToRegister(
      String email, BuildContext? context) async {
    http.Response response = await hitApiPost(false,
        UrlConstants.sendOtpToRegister + email, jsonEncode({"email": email}));
    if (response.statusCode == 200) {
      return SendOtpResponseModel.fromJson(json.decode(response.body));
    } else {
      Navigator.pop(context!);
      showErrorToast(context, "Something went wrong");
      throw "could not register${response.statusCode}";
    }
  }

  Future<RoleMasterResponseModel> getMasterRoles(BuildContext? context) async {
    http.Response response = await hitApiGet(false, UrlConstants.getRoleMaster);
    if (response.statusCode == 200) {
      return RoleMasterResponseModel.fromJson(json.decode(response.body));
    } else {
      Navigator.pop(context!);
      showErrorToast(context, "Something went wrong");
      throw "could not register${response.statusCode}";
    }
  }

  Future<RegisterResponseModel> registerNewUser({
    File? profilePic,
    required String dob,
    required String fName,
    required String lName,
    required String email,
    int? gender,
    int? roleId,
    String? bloodGroup,
    required String contact,
    required String password,
    BuildContext? context,
  }) async {
    var request =
        http.MultipartRequest('POST', Uri.parse(UrlConstants.registerUser));
    request.fields['Contact.Dob'] = dob;
    request.fields['Contact.Firstname'] = fName;
    request.fields['Contact.Email'] = email;
    request.fields['Contact.Gender'] = gender.toString();
    request.fields['Contact.LastName'] = lName;
    request.fields['RoleId'] = roleId.toString();
    request.fields['Contact.BloodGroup'] = bloodGroup ?? '';
    request.fields['Contact.ContactNumber'] = contact;
    request.fields['Password'] = password;
    if (profilePic != null) {
      var picStream = http.ByteStream(profilePic.openRead());
      var length = await profilePic.length();
      var multipartFile = http.MultipartFile(
        'profilePic',
        picStream,
        length,
        filename: profilePic.path.split('/').last,
        contentType: MediaType('image', 'jpeg'),
      );
      request.files.add(multipartFile);
    }
    print(request.fields);
    var response = await request.send();
    if (response.statusCode == 200) {
      var responseData = await response.stream.toBytes();
      var responseJson = json.decode(utf8.decode(responseData));
      log(responseJson.toString());
      return RegisterResponseModel.fromJson(responseJson);
    } else if (response.statusCode == 204) {
      Navigator.pop(context!);
      showErrorToast(context, "Email or phone may exist.");
      throw "could not register ${response.statusCode}";
    } else if (response.statusCode == 400) {
      Navigator.pop(context!);
      showErrorToast(context, "Invalid data please check.");
      throw "could not register ${response.statusCode}";
    } else {
      Navigator.pop(context!);
      showErrorToast(context, "Something went wrong");
      throw "could not register ${response.statusCode}";
    }
  }

  Future<RegisterResponseModel> loginUser(
      String email, String password, BuildContext buildContext) async {
    http.Response response = await hitApiPost(false, UrlConstants.loginUser,
        jsonEncode({"email": email, 'password': password}));
    if (response.statusCode == 200) {
      return RegisterResponseModel.fromJson(json.decode(response.body));
    } else {
      Navigator.pop(buildContext);
      showErrorToast(buildContext, "Something went wrong");
      throw "could not register${response.statusCode}";
    }
  }

  Future<SendOtpResponseModel> sendOtpToResetPassword(
      String email, BuildContext buildContext) async {
    http.Response response = await hitApiPost(
        false,
        UrlConstants.sendOtpToResetPassword + email,
        jsonEncode({"email": email}));
    if (response.statusCode == 200) {
      return SendOtpResponseModel.fromJson(json.decode(response.body));
    } else {
      Navigator.pop(buildContext);
      showErrorToast(buildContext, "Something went wrong");
      throw "could not register${response.statusCode}";
    }
  }

  Future<AddIndividualProfileResponseModel> addIndividualProfile(
      String dob,
      String mobile,
      String email,
      String fName,
      String lName,
      String address,
      String gender,
      File? selectedImage,
      BuildContext? context) async {
    var request = http.MultipartRequest('POST', Uri.parse(UrlConstants.addIndividualProfile));
    request.fields['Contact.Dob'] = dob;
    request.fields['Contact.Firstname'] = fName;
    request.fields['Contact.Email'] = email;
    request.fields['Contact.Gender'] = gender.toString();
    request.fields['Contact.LastName'] = lName;
    request.fields['Contact.ContactNumber'] = mobile;
    if (selectedImage != null) {
      var picStream = http.ByteStream(selectedImage.openRead());
      var length = await selectedImage.length();
      var multipartFile = http.MultipartFile(
        'uploadedFile',
        picStream,
        length,
        filename: selectedImage.path.split('/').last,
        contentType: MediaType('image', 'jpeg'),
      );
      request.files.add(multipartFile);
    }
    request.headers.addAll({
      "Authorization": "Bearer ${prefModel.userData!.token}",
    });
    print(request.fields);

    var response = await request.send();
    var responseData = await response.stream.toBytes();
    var responseJson = json.decode(utf8.decode(responseData));
    if (response.statusCode == 200) {
      log(responseJson.toString());
      return AddIndividualProfileResponseModel.fromJson(responseJson);
    } else if (response.statusCode == 401) {
      Navigator.pop(context!);
      showErrorToast(context, "Unauthorized");
      throw "could not register ${response.statusCode}";
    }else if (response.statusCode == 204) {
      Navigator.pop(context!);
      showErrorToast(context, "Email or phone may exist.");
      throw "could not register ${response.statusCode}";
    } else if (response.statusCode == 400) {
      Navigator.pop(context!);
      showErrorToast(context, "Invalid data please check.");
      throw "could not register ${response.statusCode}";
    } else {
      Navigator.pop(context!);
      showErrorToast(context, "Something went wrong");
      throw "could not register ${response.statusCode}";
    }
  }

// resetPassword(String email, String password, BuildContext buildContext) async {
//   http.Response response = await hitApiPost(
//       false,
//       UrlConstants.resetPassword,
//       jsonEncode({"email": email}));
//   if (response.statusCode == 200) {
//     return SendOtpResponseModel.fromJson(json.decode(response.body));
//   } else {
//     Navigator.pop(buildContext!);
//     showErrorToast(buildContext, "Something went wrong");
//     throw "could not register${response.statusCode}";
//   }
// }
}
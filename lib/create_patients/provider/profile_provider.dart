import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vicare/auth/model/register_response_model.dart';
import 'package:vicare/utils/app_buttons.dart';

import '../../auth/model/reset_password_response_model.dart';
import '../../auth/model/send_otp_response_model.dart';
import '../../database/app_pref.dart';
import '../../main.dart';
import '../../network/api_calls.dart';
import '../../utils/routes.dart';
import '../model/state_master_response_model.dart';

class ProfileProvider extends ChangeNotifier {
  ApiCalls apiCalls = ApiCalls();

  //edit profile declarations
  bool isNotValidContactNumber(String contactNumber) {
    if (contactNumber.length == 10) {
      return false;
    } else {
      return true;
    }
  }

  Future<void> preFillEditProfile(BuildContext context) async {
    showLoaderDialog(context);
      editProfileDobController.text = "${prefModel.userData!.contact!.doB!.year}-${prefModel.userData!.contact!.doB!.month}-${prefModel.userData!.contact!.doB!.day}";
      editProfileContactNumberController.text = prefModel.userData!.contactNumber!;
      editProfileFirstNameController.text = prefModel.userData!.contact!.firstname.toString();
      editProfileLastNameController.text = prefModel.userData!.contact!.lastName!;
      editProfileStreetController.text=prefModel.userData!.contact!.address!.street!;
      editProfileAreaController.text=prefModel.userData!.contact!.address!.area!;
      editProfileLandMarkController.text=prefModel.userData!.contact!.address!.landmark!;
      editProfileCityController.text=prefModel.userData!.contact!.address!.city!;
      editProfilePinCodeController.text=prefModel.userData!.contact!.address!.pinCode!;
      editProfileBloodGroup = prefModel.userData!.contact!.bloodGroup;
      for (var state in editStateMasterResponse!.result!) {
        if (state.id == prefModel.userData!.contact!.address!.stateId) {
          editProfileStateAs = state.name;
          break;
        }
      }
      editProfileGender = prefModel.userData!.contact!.gender == 1
          ? "Male"
          : prefModel.userData!.contact!.gender == 2
              ? "Female"
              : "Do not wish to specify";

      if(prefModel.userData!.profilePicture!=null){
        editProfileSelectedImage = await apiCalls.downloadImageAndReturnFilePath(
            prefModel.userData!.profilePicture!.url.toString());
      }

      notifyListeners();
      Navigator.pop(context);
      Navigator.pushNamed(context, Routes.editProfileRoute);
  }


  final editProfileFormKey = GlobalKey<FormState>();
  TextEditingController editProfileDobController = TextEditingController();
  TextEditingController editProfileContactNumberController = TextEditingController();
  TextEditingController editProfileFirstNameController = TextEditingController();
  TextEditingController editProfileLastNameController = TextEditingController();
  TextEditingController editProfileStreetController = TextEditingController();
  TextEditingController editProfileAreaController = TextEditingController();
  TextEditingController editProfileCityController = TextEditingController();
  TextEditingController editProfileLandMarkController = TextEditingController();
  TextEditingController editProfilePinCodeController = TextEditingController();
  String? editProfileBloodGroup;
  String? editProfileGender;
  int? selectedGender;
  File? editProfileSelectedImage;
  BuildContext? editProfilePageContext;
  int? editProfileSelectedStateId;
  String? editProfileStateAs;
  StateMasterResponseModel? editStateMasterResponse;

  clearEditProfileForm() {
    editProfileDobController.clear();
    editProfileContactNumberController.clear();
    editProfileFirstNameController.clear();
    editProfileLastNameController.clear();
    editProfileBloodGroup = null;
    editProfileGender = null;
    editProfileStreetController.clear();
    editProfileAreaController.clear();
    editProfileCityController.clear();
    editProfileLandMarkController.clear();
    editProfilePinCodeController.clear();
    editProfileStateAs = null;
    editProfileSelectedImage = null;
    notifyListeners();
  }

  //change password declaration
  final changePasswordFormKey = GlobalKey<FormState>();
  TextEditingController changePasswordOtpController = TextEditingController();
  String? otpReceived;
  bool changePasswordIsShowPassword = true;
  bool changePasswordIsConfirmPassword = true;
  String? resetPasswordOtp;
  BuildContext? changePasswordPageContext;


  Future<void> editProfile() async {
      RegisterResponseModel response = await apiCalls.editProfile(
        editProfileFirstNameController.text,
        editProfileLastNameController.text,
        editProfileContactNumberController.text,
        editProfileBloodGroup!,
        editProfileGender!,
        editProfileDobController.text,
        editProfileSelectedImage!,
        editProfilePageContext!,
        prefModel.userData!.id,
        prefModel.userData!.contactId,
        editProfileStreetController.text,
        editProfileAreaController.text,
        editProfileCityController.text,
        editProfileLandMarkController.text,
        editProfilePinCodeController.text,
        prefModel.userData!.contact!.addressId,
        editProfileSelectedStateId??prefModel.userData!.contact!.address!.stateId
      );
      if (response.result != null) {
        prefModel.userData!.contact!.firstname =response.result!.contact!.firstname;
        prefModel.userData!.contact!.lastName =response.result!.contact!.lastName;
        prefModel.userData!.contactNumber =response.result!.contactNumber;
        prefModel.userData!.contact!.bloodGroup =response.result!.contact!.bloodGroup;
        prefModel.userData!.contact!.gender =response.result!.contact!.gender;
        prefModel.userData!.contact!.doB =response.result!.contact!.doB;
        prefModel.userData!.profilePicture!.url = response.result!.profilePicture!.url;
        prefModel.userData!.id =response.result!.id;
        prefModel.userData!.contactId =response.result!.contactId;
        prefModel.userData!.contact!.address!.street =response.result!.contact!.address!.street;
        prefModel.userData!.contact!.address!.area =response.result!.contact!.address!.area;
        prefModel.userData!.contact!.address!.city =response.result!.contact!.address!.city;
        prefModel.userData!.contact!.address!.landmark =response.result!.contact!.address!.landmark;
        prefModel.userData!.contact!.address!.pinCode =response.result!.contact!.address!.pinCode;
        prefModel.userData!.contact!.addressId =response.result!.contact!.addressId;
        prefModel.userData!.contact!.address!.stateId = response.result!.contact!.address!.stateId;
        AppPref.setPref(prefModel);
        Navigator.pop(editProfilePageContext!);
        showSuccessToast(editProfilePageContext!, response.message!);
      }
  }

  Future<SendOtpResponseModel> changePassword(BuildContext context) async {
    SendOtpResponseModel response = await apiCalls.sendOtpToChangePassword(
        prefModel.userData!.email.toString(),
        context,
        changePasswordIsShowPassword);
    return response;
  }

  Future<void> resetNewPassword(BuildContext context) async {
    ResetPasswordResponseModel response = await apiCalls.resetNewPassword(
        changePasswordIsShowPassword, prefModel.userData!.email, context);
    if (response.result != null && response.result == true) {
      Navigator.pop(changePasswordPageContext!);
      showSuccessToast(changePasswordPageContext!, response.message!);
    } else {
      showErrorToast(changePasswordPageContext!, response.message!);
    }
  }

  Future<void> getStateMaster(BuildContext context) async {
    editStateMasterResponse = await apiCalls.getStateMaster(context);
    if (editStateMasterResponse!.result!.isNotEmpty) {
    } else {
      Navigator.pop(context);
      showErrorToast(context, editStateMasterResponse!.message.toString());
    }
  }
}

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:vicare/auth/model/register_response_model.dart';
import 'package:vicare/auth/model/role_master_response_model.dart';
import 'package:vicare/auth/model/send_otp_response_model.dart';
import 'package:vicare/network/api_calls.dart';

import '../utils/routes.dart';

class AuthProvider extends ChangeNotifier {
  ApiCalls apiCalls = ApiCalls();

  bool isNotValidEmail(String email) {
    const emailRegex =
        r'^[\w-]+(\.[\w-]+)*@[a-zA-Z0-9]+(\.[a-zA-Z0-9]+)*(\.[a-zA-Z]{2,})$';
    final regExp = RegExp(emailRegex);
    return !regExp.hasMatch(email);
  }

  bool isNotValidContactNumber(String contactNumber) {
    if (contactNumber.length == 10) {
      return false;
    } else {
      return true;
    }
  }

  bool isStrongPassword(String password) {
    if (password.length < 8) {
      return false;
    }
    bool hasCapitalLetter = password.contains(RegExp(r'[A-Z]'));
    bool hasSpecialCharacter =
        password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    bool hasNumber = password.contains(RegExp(r'[0-9]'));
    return hasCapitalLetter && hasSpecialCharacter && hasNumber;
  }

  // Login page declarations
  BuildContext? onBoardingScreenContext;
  RoleMasterResponseModel? masterRolesResponse;

  // Login page declarations
  final loginFormKey = GlobalKey<FormState>();
  bool loginIsShowPassword = true;
  TextEditingController loginEmailController = TextEditingController();
  TextEditingController loginPasswordController = TextEditingController();
  BuildContext? loginPageContext;

  // Register page declarations
  final registerFormKey = GlobalKey<FormState>();
  bool registerIsShowPassword = true;
  TextEditingController registerFirstName = TextEditingController();
  TextEditingController registerLastName = TextEditingController();
  TextEditingController registerEmailController = TextEditingController();
  TextEditingController registerPasswordController = TextEditingController();
  TextEditingController registerDobController = TextEditingController();
  TextEditingController registerOtpController = TextEditingController();
  TextEditingController registerContactNumberController = TextEditingController();
  String? registerBloodGroup;
  String? otpReceived;
  int? selectedRoleId;
  int? selectedGender;

  File? registerSelectedImage;
  String? registerAs;
  String? gender;
  BuildContext? registerPageContext;

  // Forgot password page declarations
  final forgotPasswordFormKey = GlobalKey<FormState>();
  bool forgotPasswordIsShowPassword = true;
  bool forgotPasswordIsConfirmPassword = true;
  BuildContext? forgotPageContext;
  TextEditingController forgotPasswordConfirmPasswordController =
      TextEditingController();
  TextEditingController forgotPasswordNewPasswordController =
      TextEditingController();
  TextEditingController forgotPasswordOtpController = TextEditingController();
  TextEditingController forgotPasswordEmailController = TextEditingController();

  clearLoginForm() {
    loginEmailController.clear();
    loginPasswordController.clear();
    notifyListeners();
  }

  clearRegisterForm() {
    registerFirstName.clear();
    registerLastName.clear();
    registerEmailController.clear();
    registerPasswordController.clear();
    registerDobController.clear();
    registerContactNumberController.clear();
    registerSelectedImage = null;
    registerAs = null;
    gender = null;
    registerBloodGroup = null;
    otpReceived = null;
    selectedRoleId = null;
    selectedGender = null;
    notifyListeners();
  }

  clearForgotPasswordForm() {
    forgotPasswordConfirmPasswordController.clear();
    forgotPasswordNewPasswordController.clear();
    forgotPasswordOtpController.clear();
    forgotPasswordEmailController.clear();
    notifyListeners();
  }

  void login() {
    Navigator.pushNamed(loginPageContext!, Routes.dashboardRoute);
  }

  Future<void> register() async {
    RegisterResponseModel response = await apiCalls.registerNewUser(
        profilePic: registerSelectedImage,
        dob: registerDobController.text,
        fName: registerFirstName.text,
        lName: registerLastName.text,
        email: registerEmailController.text,
        gender: selectedGender,
        roleId: selectedRoleId,
        bloodGroup: registerBloodGroup,
        contact: registerContactNumberController.text,
        password: registerPasswordController.text);
    if (response.isSuccess!) {
      Navigator.pushNamed(registerPageContext!, Routes.dashboardRoute);
    }else{
      // show error toast
    }
  }

  Future<SendOtpResponseModel> sendOtp() {
    return apiCalls.sendOtpToRegister(registerEmailController.text);
  }

  Future<void> getRoleMasters(BuildContext relContext) async {
    masterRolesResponse = await apiCalls.getMasterRoles();
    if (masterRolesResponse!.result!.isNotEmpty) {
      clearRegisterForm();
      if (relContext.mounted) {
        Navigator.pushNamed(relContext, Routes.registerRoute);
      }
    } else {
      // show toast
    }
  }
}

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:vicare/create_patients/model/add_individual_profile_response_model.dart';
import 'package:vicare/create_patients/model/country_master_response_model.dart';
import 'package:vicare/create_patients/model/individual_response_model.dart';
import 'package:vicare/dashboard/model/summary_report_response_model.dart';
import 'package:vicare/database/app_pref.dart';
import 'package:vicare/utils/app_buttons.dart';

import '../../auth/model/register_response_model.dart';
import '../../dashboard/model/device_response_model.dart';
import '../../dashboard/model/duration_response_model.dart';
import '../../dashboard/model/my_reports_response_model.dart';
import '../../main.dart';
import '../../network/api_calls.dart';
import '../model/all_enterprise_users_response_model.dart';
import '../model/all_patients_response_model.dart';
import '../model/check_request_count_model.dart';
import '../model/dashboard_count_response_model.dart';
import '../model/enterprise_response_model.dart';
import '../model/state_master_response_model.dart';

class PatientProvider extends ChangeNotifier {
  ApiCalls apiCalls = ApiCalls();

  // IndividualResponseModel? individualPatientData;
  // EnterpriseResponseModel? enterpriseUserData;
  BuildContext? relGetPatientContext;
  Future<AllPatientsResponseModel>? individualPatients;
  Future<AllEnterpriseUsersResponseModel>? enterprisePatients;

  //add New Patient Page declarations
  final addPatientFormKey = GlobalKey<FormState>();
  TextEditingController addNewPatientDobController = TextEditingController();
  TextEditingController addNewPatientMobileController = TextEditingController();
  TextEditingController addNewPatientEmailController = TextEditingController();
  TextEditingController addNewPatientStreetController = TextEditingController();
  TextEditingController addNewPatientAreaController = TextEditingController();
  TextEditingController addNewPatientLandmarkController = TextEditingController();
  TextEditingController addNewPatientCityController = TextEditingController();
  TextEditingController addNewPatientPinCodeController = TextEditingController();
  TextEditingController addNewPatientFirstNameController =
      TextEditingController();
  TextEditingController addNewPatientLastNameController =
      TextEditingController();
  TextEditingController addNewPatientAddressController =
      TextEditingController();
  TextEditingController heightController = TextEditingController();
  TextEditingController weightController = TextEditingController();
  String? addNewPatientGender;
  String? addPatientBloodGroup;
  File? addPatientSelectedImage;
  BuildContext? addNewPatientContext;
  int? selectedStateId;
  int? selectedCountryId;
  String? stateAs;
  String? countryAs;
  StateMasterResponseModel? stateMasterResponse;
  CountryMasterResponseModel? countryMasterResponse;

  clearAddPatientForm() {
    addNewPatientDobController.clear();
    addNewPatientMobileController.clear();
    addNewPatientEmailController.clear();
    addNewPatientFirstNameController.clear();
    addNewPatientLastNameController.clear();
    addNewPatientAddressController.clear();
    addNewPatientStreetController.clear();
    addNewPatientAreaController.clear();
    addNewPatientLandmarkController.clear();
    addNewPatientCityController.clear();
    addNewPatientPinCodeController.clear();
    heightController.clear();
    weightController.clear();
    addNewPatientGender = null;
    stateAs = null;
    countryAs = null;
    addPatientBloodGroup = null;
    addPatientSelectedImage = null;
    notifyListeners();
  }

  //edit patient page declarations
  final editPatientFormKey = GlobalKey<FormState>();
  TextEditingController editPatientDobController = TextEditingController();
  TextEditingController editPatientMobileController = TextEditingController();
  TextEditingController editPatientEmailController = TextEditingController();
  TextEditingController editNewPatientStreetController =
      TextEditingController();
  TextEditingController editNewPatientAreaController = TextEditingController();
  TextEditingController editNewPatientLandmarkController =
      TextEditingController();
  TextEditingController editNewPatientCityController = TextEditingController();
  TextEditingController editNewPatientPinCodeController =
      TextEditingController();
  TextEditingController editPatientFirstNameController =
      TextEditingController();
  TextEditingController editPatientLastNameController = TextEditingController();
  TextEditingController editPatientAddressController = TextEditingController();
  TextEditingController editHeightController = TextEditingController();
  TextEditingController editWeightController = TextEditingController();
  String? editPatientGender;
  String? editPatientBloodGroup;
  int? selectedGender;
  File? editPatientSelectedImage;
  int? editSelectedStateId;
  int? editSelectedCountryId;
  String? editStateAs;
  String? editCountryAs;
  BuildContext? editPatientPageContext;

  clearEditPatientForm() {
    editPatientDobController.clear();
    editPatientMobileController.clear();
    editPatientEmailController.clear();
    editPatientFirstNameController.clear();
    editPatientLastNameController.clear();
    editPatientAddressController.clear();
    editNewPatientStreetController.clear();
    editNewPatientAreaController.clear();
    editNewPatientLandmarkController.clear();
    editNewPatientCityController.clear();
    editNewPatientPinCodeController.clear();
    editHeightController.clear();
    editWeightController.clear();
    // editSelectedCountryId =null;
    // editSelectedStateId =null;
    editPatientGender = null;
    editStateAs = null;
    editCountryAs = null;
    editPatientBloodGroup = null;
    editPatientSelectedImage = null;
    notifyListeners();
  }

  bool isNotValidEmail(String email) {
    const emailRegex =
        r'^[\w-]+(\.[\w-]+)*@[a-zA-Z0-9]+(\.[a-zA-Z0-9]+)*(\.[a-zA-Z]{2,})$';
    final regExp = RegExp(emailRegex);
    return !regExp.hasMatch(email);
  }

  int calculateAge(String dateOfBirthString) {
    DateTime dateOfBirth = DateTime.parse(dateOfBirthString).toUtc();
    DateTime currentDate = DateTime.now().toUtc();
    Duration difference = currentDate.difference(dateOfBirth);
    int ageInYears = (difference.inDays / 365).floor();
    return ageInYears;
  }

  addNewPatient() async {
    showLoaderDialog(addNewPatientContext!);

    DateFormat inputFormat = DateFormat('dd-MM-yyyy');
    DateTime dateTime = inputFormat.parse(addNewPatientDobController.text);

    // Format the date in the desired output format
    DateFormat outputFormat = DateFormat('yyyy-MM-dd');
    String formattedDate = outputFormat.format(dateTime);

    Map<String, String> genderMap = {
      "Male": "0",
      "Female": "1",
    };

    String gender = genderMap.containsKey(addNewPatientGender)
        ? genderMap[addNewPatientGender]!
        : '0';

    if (prefModel.userData!.roleId == 2) {
      AddIndividualProfileResponseModel response =
          await apiCalls.addIndividualProfile(
              formattedDate,
              addNewPatientMobileController.text,
              addNewPatientEmailController.text,
              addNewPatientFirstNameController.text,
              addNewPatientLastNameController.text,
              // genderMap[addNewPatientGender] ?? "unknown",
              gender,
              addPatientSelectedImage,
              addNewPatientContext!,
              addPatientBloodGroup!,
              addNewPatientStreetController.text,
              addNewPatientAreaController.text,
              addNewPatientLandmarkController.text,
              addNewPatientCityController.text,
              addNewPatientPinCodeController.text,
              selectedStateId!,
              selectedCountryId!,
              heightController.text,
              weightController.text);
      if (response.result != null) {
        showSuccessToast(addNewPatientContext!, response.message!);
        Navigator.pop(addNewPatientContext!);
        Navigator.pop(addNewPatientContext!);
      }else{
        showErrorToast(addNewPatientContext!, response.message!);
        Navigator.pop(addNewPatientContext!);
        Navigator.pop(addNewPatientContext!);
      }
    } else {
      AddIndividualProfileResponseModel response =
          await apiCalls.addEnterpriseProfile(
              formattedDate,
              addNewPatientMobileController.text,
              addNewPatientEmailController.text,
              addNewPatientFirstNameController.text,
              addNewPatientLastNameController.text,
              addNewPatientAddressController.text,
              // genderMap[addNewPatientGender] ?? "unknown",
              gender,
              addPatientSelectedImage,
              addNewPatientContext!,
              addPatientBloodGroup!,
              addNewPatientStreetController.text,
              addNewPatientAreaController.text,
              addNewPatientLandmarkController.text,
              addNewPatientCityController.text,
              addNewPatientPinCodeController.text,
              selectedStateId!,
              selectedCountryId!,
              heightController.text,
              weightController.text);
      if (response.result != null) {
        showSuccessToast(addNewPatientContext!, response.message!);
        Navigator.pop(addNewPatientContext!);
        Navigator.pop(addNewPatientContext!);
      } else {
        showErrorToast(addNewPatientContext!, response.message!);
        Navigator.pop(addNewPatientContext!);
        Navigator.pop(addNewPatientContext!);
      }
    }
  }

  Future<void> prefillEditPatientDetails(
      BuildContext context,
      IndividualResponseModel? individualPatientData,
      EnterpriseResponseModel? enterpriseUserData) async {
    showLoaderDialog(context);
    editPatientSelectedImage = null;
    if (prefModel.userData!.roleId == 2) {
      final DateTime dob = DateTime(
        individualPatientData!.result!.contact!.doB!.year,
        individualPatientData.result!.contact!.doB!.month,
        individualPatientData.result!.contact!.doB!.day,
      );
      final String formattedDob = DateFormat('dd-MM-yyyy').format(dob);
      editPatientDobController.text = formattedDob;
      // "${individualPatientData!.result!.contact!.doB!.year}-${individualPatientData.result!.contact!.doB!.month}-${individualPatientData.result!.contact!.doB!.day}";
      editPatientMobileController.text =
          individualPatientData.result!.contact!.contactNumber!;
      editPatientEmailController.text = individualPatientData.result!.email!;
      editPatientFirstNameController.text =
          individualPatientData.result!.firstName!;
      editPatientLastNameController.text =
          individualPatientData.result!.lastName!;
      editPatientAddressController.text =
          individualPatientData.result!.contact!.address.toString();
      editPatientGender = individualPatientData.result!.contact!.gender == 0
          ? "Male"
          :"Female";
      editNewPatientStreetController.text =
          individualPatientData.result!.contact!.address!.street != null
              ? individualPatientData.result!.contact!.address!.street
                  .toString()
              : "";
      editNewPatientAreaController.text =
          individualPatientData.result!.contact!.address!.area != null
              ? individualPatientData.result!.contact!.address!.area!.toString()
              : "";
      editNewPatientLandmarkController.text =
          individualPatientData.result!.contact!.address!.landmark != null
              ? individualPatientData.result!.contact!.address!.landmark
                  .toString()
              : "";
      editNewPatientCityController.text =
          individualPatientData.result!.contact!.address!.city.toString();
      editNewPatientPinCodeController.text =
          individualPatientData.result!.contact!.address!.pinCode != null
              ? individualPatientData.result!.contact!.address!.pinCode
                  .toString()
              : "";
      editHeightController.text = individualPatientData.result!.height == null
          ? ""
          : individualPatientData.result!.height!;
      editWeightController.text = individualPatientData.result!.weight == null
          ? ""
          : individualPatientData.result!.weight!;

      if (individualPatientData.result!.profilePicture != null) {
        final imageUrl = individualPatientData.result!.profilePicture!.url;
        if (imageUrl != null && imageUrl.isNotEmpty) {
          final imagePath =
              await apiCalls.downloadImageAndReturnFilePath(imageUrl);
          if (imagePath != null) {
            editPatientSelectedImage = imagePath;
          } else {
            print('Error: Image file not found at path: $imagePath');
          }
        }
      }
      await getCountryMaster(context);
      if (countryMasterResponse != null &&
          countryMasterResponse!.result!.isNotEmpty) {
        for (var country in countryMasterResponse!.result!) {
          if (country.id ==
              individualPatientData.result!.contact!.address!.countryId) {
            editCountryAs = country.name;
            editSelectedCountryId = country.id;
            await getStateMaster(context, country.uniqueGuid);
            break;
          }
        }
      }
      if (stateMasterResponse != null &&
          stateMasterResponse!.result!.isNotEmpty) {
        for (var state in stateMasterResponse!.result!) {
          if (state.id ==
              individualPatientData.result!.contact!.address!.stateId) {
            editStateAs = state.name;
            editSelectedStateId = state.id;
            break;
          }
        }
      }
      editPatientBloodGroup = individualPatientData.result!.contact!.bloodGroup;
    } else {
      final DateTime dob = DateTime(
        enterpriseUserData!.result!.contact!.doB!.year,
        enterpriseUserData.result!.contact!.doB!.month,
        enterpriseUserData.result!.contact!.doB!.day,
      );
      final String formattedDob = DateFormat('dd-MM-yyyy').format(dob);
      editPatientDobController.text = formattedDob;
      // "${enterpriseUserData!.result!.contact!.doB!.year}-${enterpriseUserData.result!.contact!.doB!.month}-${enterpriseUserData.result!.contact!.doB!.day}";
      editPatientMobileController.text =
          enterpriseUserData.result!.contact!.contactNumber!;
      editPatientEmailController.text = enterpriseUserData.result!.emailId!;
      editPatientFirstNameController.text =
          enterpriseUserData.result!.firstName!;
      editPatientLastNameController.text = enterpriseUserData.result!.lastName!;
      editNewPatientStreetController.text =
          enterpriseUserData.result!.contact!.address!.street != null
              ? enterpriseUserData.result!.contact!.address!.street.toString()
              : "";
      editNewPatientAreaController.text =
          enterpriseUserData.result!.contact!.address!.area != null
              ? enterpriseUserData.result!.contact!.address!.area!.toString()
              : "";
      editNewPatientLandmarkController.text =
          enterpriseUserData.result!.contact!.address!.landmark != null
              ? enterpriseUserData.result!.contact!.address!.landmark.toString()
              : "";
      editNewPatientCityController.text =
          enterpriseUserData.result!.contact!.address!.city.toString();
      editNewPatientPinCodeController.text =
          enterpriseUserData.result!.contact!.address!.pinCode != null
              ? enterpriseUserData.result!.contact!.address!.pinCode.toString()
              : "";
      editHeightController.text = enterpriseUserData.result!.height == null
          ? ""
          : enterpriseUserData.result!.height!;
      editWeightController.text = enterpriseUserData.result!.weight == null
          ? ""
          : enterpriseUserData.result!.weight!;
      if (enterpriseUserData.result!.profilePicture != null) {
        final imageUrl = enterpriseUserData.result!.profilePicture!.url;
        if (imageUrl != null && imageUrl.isNotEmpty) {
          final imagePath =
              await apiCalls.downloadImageAndReturnFilePath(imageUrl);
          if (imagePath != null) {
            editPatientSelectedImage = imagePath;
          } else {
            print('Error: Image file not found at path: $imagePath');
          }
        }
      }
      await getCountryMaster(context);
      if (countryMasterResponse != null &&
          countryMasterResponse!.result!.isNotEmpty) {
        for (var country in countryMasterResponse!.result!) {
          if (country.id ==
              enterpriseUserData.result!.contact!.address!.countryId) {
            editCountryAs = country.name;
            editSelectedCountryId = country.id;
            await getStateMaster(context, country.uniqueGuid);
            break;
          }
        }
      }
      if (stateMasterResponse != null &&
          stateMasterResponse!.result!.isNotEmpty) {
        for (var state in stateMasterResponse!.result!) {
          if (state.id ==
              enterpriseUserData.result!.contact!.address!.stateId) {
            editStateAs = state.name;
            break;
          }
        }
      }
      editPatientGender = enterpriseUserData.result!.contact!.gender == 0
          ? "Male"
          :"Female";
      editPatientBloodGroup = enterpriseUserData.result!.contact!.bloodGroup;
    }
  }

  editPatient(IndividualResponseModel? individualPatientData,
      EnterpriseResponseModel? enterpriseUserData) async {
    showLoaderDialog(editPatientPageContext!);
    DateFormat inputFormat = DateFormat('dd-MM-yyyy');
    DateTime dateTime = inputFormat.parse(editPatientDobController.text);

    // Format the date in the desired output format
    DateFormat outputFormat = DateFormat('yyyy-MM-dd');
    String formattedDate = outputFormat.format(dateTime);

    Map<String, String> genderMap = {
      "Male": "0",
      "Female": "1",
    };
    if (prefModel.userData!.roleId == 2) {
      AddIndividualProfileResponseModel response = await apiCalls.editPatient(
          formattedDate,
          editPatientMobileController.text,
          editPatientEmailController.text,
          editPatientFirstNameController.text,
          editPatientLastNameController.text,
          genderMap[editPatientGender]!,
          editPatientSelectedImage,
          editPatientPageContext!,
          editPatientBloodGroup!,
          individualPatientData!.result!.userId.toString(),
          individualPatientData.result!.contactId.toString(),
          individualPatientData.result!.id.toString(),
          editNewPatientStreetController.text,
          editNewPatientAreaController.text,
          editNewPatientPinCodeController.text,
          editNewPatientCityController.text,
          editNewPatientLandmarkController.text,
          individualPatientData.result!.contact!.addressId.toString(),
          editHeightController.text,
          editWeightController.text,
          editSelectedCountryId!.toString(),
          editSelectedStateId!.toString());
      if (response.result != null) {
        showSuccessToast(editPatientPageContext!, response.message!);
        Navigator.pop(editPatientPageContext!);
        Navigator.pop(editPatientPageContext!);
      }
    } else {
      AddIndividualProfileResponseModel response =
          await apiCalls.editEnterprise(
        editPatientEmailController.text,
        editPatientFirstNameController.text,
        editPatientLastNameController.text,
            formattedDate,
        editPatientAddressController.text,
        editPatientMobileController.text,
        genderMap[editPatientGender]!,
        editPatientSelectedImage,
        editPatientPageContext!,
        editPatientBloodGroup!,
        enterpriseUserData!.result!.enterpriseUserId.toString(),
        enterpriseUserData.result!.id.toString(),
        enterpriseUserData.result!.contactId.toString(),
        editNewPatientStreetController.text,
        editNewPatientAreaController.text,
        editNewPatientPinCodeController.text,
        editNewPatientCityController.text,
        editNewPatientLandmarkController.text,
        editSelectedStateId ??
            enterpriseUserData.result!.contact!.address!.stateId,
        enterpriseUserData.result!.contact!.addressId.toString(),
        editSelectedCountryId ??
            enterpriseUserData.result!.contact!.address!.countryId,
        editHeightController.text,
        editWeightController.text,
      );
      if (response.result != null) {
        showSuccessToast(editPatientPageContext!, response.message!);
        Navigator.pop(editPatientPageContext!);
        Navigator.pop(editPatientPageContext!);
      }
    }
  }

  getMyPatients(BuildContext context) {
    individualPatients = apiCalls.getMyIndividualUsers(context);
  }

  getEnterpriseProfiles(BuildContext context) {
    enterprisePatients = apiCalls.getMyEnterpriseUsers(context);
  }

  Future<IndividualResponseModel>? individualUserData;
  Future<EnterpriseResponseModel>? enterpriseUserData;

  getIndividualUserData(String? pId, BuildContext context) async {
    individualUserData = apiCalls.getIndividualUserData(pId, context);
  }

  getEnterpriseUserData(String? eId, BuildContext context) async {
    enterpriseUserData = apiCalls.getEnterpriseUserData(eId, context);
  }

  Future<void> getStateMaster(BuildContext context, String? uniqueGuid) async {
    stateMasterResponse = await apiCalls.getStateMaster(context, uniqueGuid);
    if (stateMasterResponse!.result!.isEmpty) {
      showErrorToast(context, stateMasterResponse!.message.toString());
    }
  }

  Future<DashboardCountResponseModel> getCounts(int pId, BuildContext context) {
    return apiCalls.getDashboardCounts(pId, context);
  }

  Future<MyReportsResponseModel> getPatientReports(
      int? pId, BuildContext context) async {
    return await apiCalls.getAllReportsByProfileId(pId, context);
  }

  Future<DeviceResponseModel> getMyDevices(BuildContext context) {
    return apiCalls.getMyDevices(context);
  }

  Future<DurationResponseModel> getAllDuration(BuildContext context) async {
    return await apiCalls.getAllDurations(context);
  }

  Future<SummaryReportResponseModel> getSummaryReport(
      BuildContext context, String pId, int type) {
    return apiCalls.getSummaryReports(context, pId, type);
  }

  Future<IndividualResponseModel> selectIndividualUserData(
      String? pId, BuildContext context) async {
    return apiCalls.getIndividualUserData(pId, context);
  }

  Future<EnterpriseResponseModel> selectEnterpriseUserData(
      String? eId, BuildContext context) async {
    return apiCalls.getEnterpriseUserData(eId, context);
  }

  Future<void> getCountryMaster(BuildContext context) async {
    countryMasterResponse = await apiCalls.getCountryMaster(context);
    if (countryMasterResponse!.result!.isEmpty) {
      showErrorToast(context, countryMasterResponse!.message.toString());
    }
  }

  Future<CheckRequestCountModel> checkRequestCount(
      BuildContext context, int? individualId, int? enterpriseId) async {
    return await apiCalls.checkRequestCount(
        context, individualId, enterpriseId);
  }

  checkRequestDuration(
      BuildContext context, int? individualId, int? enterpriseId) async {
    return await apiCalls.checkRequestDuration(
        context, individualId, enterpriseId);
  }

  Future<RegisterResponseModel>? getUserDetails(BuildContext context) async {
    RegisterResponseModel a = await apiCalls.getUserByGuid(context);
    prefModel.userData!.contact!.firstName = a.result!.contact!.firstName;
    prefModel.userData!.contact!.lastName = a.result!.contact!.lastName;
    AppPref.setPref(prefModel);
    return a;
  }

  checkEligibilityToAdd(BuildContext context) {
    return apiCalls.checkUserEligibleToAddMembers(context);
  }

  Future<void> getPrefillData(BuildContext context) async {
    addNewPatientMobileController.text = prefModel.userData!.contact!.contactNumber ?? '';
    addNewPatientEmailController.text = prefModel.userData!.contact!.email ?? '';
    addNewPatientStreetController.text = prefModel.userData!.contact!.address!.street ?? '';
    addNewPatientAreaController.text = prefModel.userData!.contact!.address!.area ?? '';
    addNewPatientLandmarkController.text = prefModel.userData!.contact!.address!.landmark ?? '';
    addNewPatientCityController.text = prefModel.userData!.contact!.address!.city ?? '';
    addNewPatientPinCodeController.text = prefModel.userData!.contact!.address!.pinCode ?? '';
    countryAs = prefModel.userData!.contact!.address!.country!.name;
    await getStateMaster(context, prefModel.userData!.contact!.address!.country!.uniqueGuid);
    stateAs = prefModel.userData!.contact!.address!.state!['name'];
    notifyListeners();
  }
}

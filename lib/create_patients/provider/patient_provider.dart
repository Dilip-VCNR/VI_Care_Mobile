import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:vicare/create_patients/model/add_individual_profile_response_model.dart';
import 'package:vicare/utils/app_buttons.dart';

import '../../network/api_calls.dart';

class PatientProvider extends ChangeNotifier {
  ApiCalls apiCalls = ApiCalls();

  //add New Patient Page declarations
  final addPatientFormKey = GlobalKey<FormState>();
  TextEditingController addNewPatientDobController = TextEditingController();
  TextEditingController addNewPatientMobileController = TextEditingController();
  TextEditingController addNewPatientEmailController = TextEditingController();
  TextEditingController addNewPatientFirstNameController =
      TextEditingController();
  TextEditingController addNewPatientLastNameController =
      TextEditingController();
  TextEditingController addNewPatientAddressController =
      TextEditingController();
  String? addNewPatientGender;
  File? addPatientSelectedImage;
  BuildContext? addNewPatientContext;

  clearAddPatientForm() {
    addNewPatientDobController.clear();
    addNewPatientMobileController.clear();
    addNewPatientEmailController.clear();
    addNewPatientFirstNameController.clear();
    addNewPatientLastNameController.clear();
    addNewPatientAddressController.clear();
    addNewPatientGender = null;
    addPatientSelectedImage = null;
    notifyListeners();
  }

  //edit patient page declarations

  final editPatientFormKey = GlobalKey<FormState>();
  TextEditingController editPatientDobController = TextEditingController();
  TextEditingController editPatientMobileController = TextEditingController();
  TextEditingController editPatientEmailController = TextEditingController();
  TextEditingController editPatientFirstNameController =
      TextEditingController();
  TextEditingController editPatientLastNameController = TextEditingController();
  TextEditingController editPatientAddressController = TextEditingController();
  String? editPatientGender;
  File? editPatientSelectedImage;
  BuildContext? editPatientPageContext;

  clearEditPatientForm() {
    editPatientDobController.clear();
    editPatientMobileController.clear();
    editPatientEmailController.clear();
    editPatientFirstNameController.clear();
    editPatientLastNameController.clear();
    editPatientAddressController.clear();
    editPatientGender = null;
    editPatientSelectedImage = null;
    notifyListeners();
  }
  addNewPatient() async {
    showLoaderDialog(addNewPatientContext!);
    if (prefModel.userData!.roleId == 2) {
      AddIndividualProfileResponseModel response =
          await apiCalls.addIndividualProfile(
              addNewPatientDobController.text,
              addNewPatientMobileController.text,
              addNewPatientEmailController.text,
              addNewPatientFirstNameController.text,
              addNewPatientLastNameController.text,
              addNewPatientAddressController.text,
              addNewPatientGender!,
              addPatientSelectedImage,
              addNewPatientContext!);
      if(response.result!=null){
        showSuccessToast(addNewPatientContext!, response.message!);
        Navigator.pop(addNewPatientContext!);
        Navigator.pop(addNewPatientContext!);
      }
    } else {
      // add enterprise profile
    }
  }

//
// void prefillEditPatientDetails() {
//   editPatientDobController.text = addNewPatientDobController.text;
//   editPatientMobileController.text = addNewPatientMobileController.text;
//   editPatientEmailController.text = addNewPatientEmailController.text;
//   editPatientFirstNameController.text = addNewPatientFirstNameController.text;
//   editPatientLastNameController.text = addNewPatientLastNameController.text;
//   editPatientAddressController.text = addNewPatientAddressController.text;
//   editPatientGender = addNewPatientGender;
//   editPatientSelectedImage = addPatientSelectedImage;
//   notifyListeners();
// }
}
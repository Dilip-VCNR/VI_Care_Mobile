import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vicare/create_patients/model/enterprise_response_model.dart';
import 'package:vicare/create_patients/model/individual_response_model.dart';
import 'package:vicare/create_patients/provider/patient_provider.dart';
import 'package:vicare/dashboard/provider/new_test_le_provider.dart';
import 'package:vicare/database/app_pref.dart';
import 'package:vicare/main.dart';
import 'package:vicare/utils/app_colors.dart';
import 'package:vicare/utils/app_locale.dart';

import '../../create_patients/model/all_enterprise_users_response_model.dart';
import '../../create_patients/model/all_patients_response_model.dart';
import '../../utils/app_buttons.dart';

class OfflineTestScreen extends StatefulWidget {
  const OfflineTestScreen({super.key});

  @override
  State<OfflineTestScreen> createState() => _OfflineTestScreenState();
}

class _OfflineTestScreenState extends State<OfflineTestScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (BuildContext context, NewTestLeProvider newTestLeProvider,
          Widget? child) {
        return OfflineBuilder(
          connectivityBuilder: (BuildContext context,
              ConnectivityResult connectivity, Widget child) {
            final bool connected = connectivity != ConnectivityResult.none;
         return Scaffold(
              appBar: AppBar(
                title: Text(
                  AppLocale.offlineTests.getString(context),
                  style: const TextStyle(color: Colors.white),
                ),
                backgroundColor: AppColors.primaryColor,
                toolbarHeight: 75,
                leading: IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              body:connected? Padding(
                padding: const EdgeInsets.all(15),
                child: prefModel.offlineSavedTests!.isNotEmpty
                    ? ListView.builder(
                        itemCount: prefModel.offlineSavedTests!.length,
                        itemBuilder: (context, index) {
                          if (prefModel.offlineSavedTests![index]
                                      .individualPatientData ==
                                  null &&
                              prefModel.offlineSavedTests![index]
                                      .enterprisePatientData ==
                                  null) {
                            return Container(
                              width: screenSize!.width,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 15),
                              margin: const EdgeInsets.all(5),
                              decoration: const BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      blurRadius: 5,
                                      color: Colors.grey,
                                      offset: Offset(2, 2),
                                    ),
                                  ],
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(12)),
                                  color: Colors.white),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${AppLocale.test.getString(context)} ${AppLocale.created.getString(context)}: ${parseDate(prefModel.offlineSavedTests![index].created.toString())}",
                                    style: const TextStyle(
                                        color: AppColors.fontShadeColor,
                                        fontSize: 14),
                                  ),
                                  Text(
                                   AppLocale.noPatientDate.getString(context),
                                    style: const TextStyle(
                                        color: AppColors.fontShadeColor,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 10),
                                  Row(children: [
                                    GestureDetector(
                                      onTap: () {
                                        _showPatientBottomSheet(context,index,(bool a){
                                          setState(() {

                                          });
                                        });
                                      },
                                      child:  Row(
                                        children: [
                                          const Icon(
                                            Icons.link,
                                            color: AppColors.primaryColor,
                                            size: 18,
                                          ),
                                          const SizedBox(
                                            width: 3,
                                          ),
                                          Text(
                                            AppLocale.linkNow.getString(context),
                                            style: const TextStyle(
                                                fontSize: 12,
                                                color: AppColors.primaryColor),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 20,
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          prefModel.offlineSavedTests!
                                              .removeAt(index);
                                        });
                                      },
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.delete_outline,
                                            color: Colors.red,
                                            size: 18,
                                          ),
                                          Text(
                                            AppLocale.delete.getString(context),
                                            style: const TextStyle(
                                                fontSize: 12, color: Colors.red),
                                          )
                                        ],
                                      ),
                                    ),
                                  ])
                                ],
                              ),
                            );
                          } else {
                            return Column(
                              children: [
                                Container(
                                  width: screenSize!.width,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15, vertical: 15),
                                  margin: const EdgeInsets.all(5),
                                  decoration: const BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                          blurRadius: 5,
                                          color: Colors.grey,
                                          offset: Offset(2, 2),
                                        ),
                                      ],
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(12)),
                                      color: Colors.white),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      CircleAvatar(
                                        backgroundImage: NetworkImage(prefModel
                                                    .offlineSavedTests![index]
                                                    .myRoleId ==
                                                2
                                            ? '${prefModel.offlineSavedTests![index].individualPatientData!.result!.profilePicture?.url}'
                                            : '${prefModel.offlineSavedTests![index].enterprisePatientData!.result!.profilePicture?.url}'),
                                        radius: 30,
                                        backgroundColor: Colors.grey.shade400,
                                        child: (prefModel
                                            .offlineSavedTests![index]
                                            .myRoleId ==
                                            2 && prefModel.offlineSavedTests![index].individualPatientData!.result!.profilePicture?.url == null) ||
                                            (prefModel
                                                .offlineSavedTests![index]
                                                .myRoleId !=
                                                2 && prefModel.offlineSavedTests![index].enterprisePatientData!.result!.profilePicture?.url == null)
                                            ? const Icon(Icons.person, size: 30, color: Colors.white)
                                            : null,
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          prefModel.offlineSavedTests![index]
                                                      .myRoleId ==
                                                  2
                                              ? SizedBox(
                                            width: screenSize!.width / 2,
                                                child: Text(
                                                    "${prefModel.offlineSavedTests![index].individualPatientData!.result!.firstName!} ${prefModel.offlineSavedTests![index].individualPatientData!.result!.lastName!}"),
                                              )
                                              : SizedBox(
                                            width: screenSize!.width / 2,
                                                child: Text(
                                                    "${prefModel.offlineSavedTests![index].enterprisePatientData!.result!.firstName!} ${prefModel.offlineSavedTests![index].enterprisePatientData!.result!.lastName!}"),
                                              ),
                                          const SizedBox(height: 5),
                                          prefModel.offlineSavedTests![index]
                                                      .myRoleId ==
                                                  2
                                              ? Text(
                                                  "${calculateAge("${prefModel.offlineSavedTests![index].individualPatientData!.result!.contact!.doB!}")} ${AppLocale.years.getString(context)}")
                                              : Text(
                                                  "${calculateAge("${prefModel.offlineSavedTests![index].enterprisePatientData!.result!.contact!.doB!}")} ${AppLocale.years.getString(context)}"),
                                          const SizedBox(height: 5),
                                          prefModel.offlineSavedTests![index]
                                              .myRoleId ==
                                              2
                                              ? Text(
                                              "${(prefModel.offlineSavedTests![index].individualPatientData!.result!.contact!.gender==1?"Male":"Female")}")
                                              : Text(
                                              "${(prefModel.offlineSavedTests![index].enterprisePatientData!.result!.contact!.gender==1?"Male":"Female")}"),
                                          const SizedBox(height: 5),

                                          Text(
                                            "${AppLocale.created.getString(context)}: ${parseDate(prefModel.offlineSavedTests![index].created.toString())}",
                                            style: const TextStyle(
                                                color: AppColors.fontShadeColor,
                                                fontSize: 14),
                                          ),
                                          const SizedBox(height: 10),
                                          Row(children: [
                                            GestureDetector(
                                              onTap: () async {
                                                showLoaderDialog(context);
                                                var jsonString = jsonEncode({
                                                  "fileVersion": "IBIPOLAR",
                                                  "appVersion": "ViCare_1.0.0",
                                                  "serialNumber": prefModel
                                                      .offlineSavedTests![index]
                                                      .deviceId,
                                                  "guid":
                                                      "46184141-00c6-46ee-b927-4218085e85fd",
                                                  "age": prefModel
                                                              .userData!.roleId ==
                                                          2
                                                      ? calculateAge(prefModel
                                                          .offlineSavedTests![
                                                              index]
                                                          .individualPatientData!
                                                          .result!
                                                          .contact!
                                                          .doB
                                                          .toString())
                                                      : calculateAge(prefModel
                                                          .offlineSavedTests![
                                                              index]
                                                          .enterprisePatientData!
                                                          .result!
                                                          .contact!
                                                          .doB
                                                          .toString()),
                                                  "gender": prefModel
                                                              .userData!.roleId ==
                                                          2
                                                      ? prefModel
                                                          .offlineSavedTests![
                                                              index]
                                                          .individualPatientData!
                                                          .result!
                                                          .contact!
                                                          .gender
                                                      : prefModel
                                                          .offlineSavedTests![
                                                              index]
                                                          .enterprisePatientData!
                                                          .result!
                                                          .contact!
                                                          .gender,
                                                  "date": DateTime.now()
                                                      .toIso8601String(),
                                                  "countryCode": "IN",
                                                  "intervals": prefModel
                                                      .offlineSavedTests![index]
                                                      .rrIntervalList
                                                });
                                                var directory =
                                                    await getExternalStorageDirectory();
                                                var viCareDirectory = Directory(
                                                    '${directory!.path}/vicare');

                                                if (!(await viCareDirectory
                                                    .exists())) {
                                                  await viCareDirectory.create(
                                                      recursive: true);
                                                }
                                                var now = DateTime.now();
                                                var timestamp =
                                                    now.millisecondsSinceEpoch;
                                                var filename =
                                                    'data_$timestamp.json';
                                                var filePath =
                                                    '${viCareDirectory.path}/$filename';
                                                File payload = File(filePath);
                                                await payload
                                                    .writeAsString(jsonString);
                                                if (await payload.exists()) {
                                                  String pId = prefModel
                                                              .userData!.roleId ==
                                                          2
                                                      ? prefModel
                                                          .offlineSavedTests![
                                                              index]
                                                          .individualPatientData!
                                                          .result!
                                                          .id
                                                          .toString()
                                                      : prefModel
                                                          .offlineSavedTests![
                                                              index]
                                                          .enterprisePatientData!
                                                          .result!
                                                          .id
                                                          .toString();
                                                  await newTestLeProvider
                                                      .requestDeviceData(
                                                          context,
                                                          payload,
                                                          prefModel
                                                              .offlineSavedTests![
                                                                  index]
                                                              .deviceId,
                                                          prefModel
                                                              .offlineSavedTests![
                                                                  index]
                                                              .userAndDeviceId,
                                                          '',
                                                          prefModel
                                                              .offlineSavedTests![
                                                                  index]
                                                              .selectedDurationId,
                                                          prefModel
                                                              .offlineSavedTests![
                                                                  index]
                                                              .scanDurationName,
                                                          pId,
                                                      {
                                                        "MyRoleId": prefModel.userData!.roleId,
                                                        "bpmList": prefModel.offlineSavedTests![index].bpmList,
                                                        "rrIntervalList": prefModel.offlineSavedTests![index].rrIntervalList,
                                                        "scanDuration": prefModel.offlineSavedTests![index].scanDuration,
                                                        "scanDurationName": prefModel.offlineSavedTests![index].scanDurationName,
                                                        "deviceName": prefModel.offlineSavedTests![index].deviceName,
                                                        "deviceId": prefModel.offlineSavedTests![index].deviceId,
                                                        "userAndDeviceId": prefModel.offlineSavedTests![index].userAndDeviceId,
                                                        "selectedDurationId": prefModel.offlineSavedTests![index].selectedDurationId,
                                                        "enterprisePatientData": prefModel.offlineSavedTests![index].enterprisePatientData,
                                                        "individualPatientData": prefModel.offlineSavedTests![index].individualPatientData,
                                                        "created": prefModel.offlineSavedTests![index].created // Convert DateTime to String
                                                      }
                                                  );
                                                  prefModel.offlineSavedTests!
                                                      .removeAt(index);
                                                } else {
                                                  showErrorToast(
                                                      context,
                                                      AppLocale.somethingWentWrong
                                                          .getString(context));
                                                }
                                                Navigator.pop(context);
                                              },
                                              child: Row(
                                                children: [
                                                  const Icon(
                                                    Icons.refresh_outlined,
                                                    color: AppColors.primaryColor,
                                                    size: 18,
                                                  ),
                                                  const SizedBox(
                                                    width: 3,
                                                  ),
                                                  Text(
                                                    AppLocale.upload
                                                        .getString(context),
                                                    style: const TextStyle(
                                                        fontSize: 12,
                                                        color: AppColors
                                                            .primaryColor),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 20,
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  prefModel.offlineSavedTests!
                                                      .removeAt(index);
                                                });
                                              },
                                              child: Row(
                                                children: [
                                                  const Icon(
                                                    Icons.delete_outline,
                                                    color: Colors.red,
                                                    size: 18,
                                                  ),
                                                  Text(
                                                    AppLocale.delete
                                                        .getString(context),
                                                    style: const TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.red),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ])
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                              ],
                            );
                          }
                        },
                      )
                    : Center(
                        child: Text(
                          AppLocale.noSavedYet.getString(context),
                          style: const TextStyle(
                              fontSize: 18, color: AppColors.fontShadeColor),
                        ),
                      ),
              )
                  : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.wifi_off,
                      size: 80,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "No Internet",
                      style: TextStyle(
                          fontSize: 24,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Please check your internet\n connection and try again.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 16, color: Colors.grey.shade500),
                    ),
                  ],
                ),
              ),
         );
          },
          child: const Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}

String parseDate(String timestampString) {
  DateTime parsedDateTime = DateTime.parse(timestampString).toLocal();
  return DateFormat('MMM/dd/yyyy hh:mm aa').format(parsedDateTime);
}

int calculateAge(String dateOfBirthString) {
  DateTime dateOfBirth = DateTime.parse(dateOfBirthString).toUtc();
  DateTime currentDate = DateTime.now().toUtc();
  Duration difference = currentDate.difference(dateOfBirth);
  int ageInYears = (difference.inDays / 365).floor();
  return ageInYears;
}

void _showPatientBottomSheet(BuildContext context, offlineSavedTestIndex, Null Function(bool a) onSelected) {
  showModalBottomSheet(
    context: context,
    builder: (BuildContext bottomSheetContext) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 20,left: 10,bottom: 10,right: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text("Select patient",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),),
                GestureDetector(
                    onTap: (){
                      Navigator.pop(bottomSheetContext);
                    },
                    child: const Icon(Icons.close))
              ],
            ),
          ),
          const Divider(),
          Consumer(
            builder: (BuildContext context, PatientProvider patientProvider,
                Widget? child) {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: prefModel.userData!.roleId == 2
                    ? FutureBuilder(
                        future: patientProvider.individualPatients,
                        builder: (BuildContext context,
                            AsyncSnapshot<AllPatientsResponseModel> snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return SizedBox(
                                width: screenSize!.width,
                                child: Shimmer.fromColors(
                                    baseColor: Colors.grey.shade300,
                                    highlightColor: Colors.grey.shade100,
                                    enabled: true,
                                    child: GridView.builder(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                      itemCount: 9,
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 3,
                                        crossAxisSpacing: 10,
                                        mainAxisSpacing: 10,
                                      ),
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return Container(
                                          width: 100,
                                          height: 100,
                                          color: Colors.grey.shade300,
                                        );
                                      },
                                    )));
                          }
                          if (snapshot.hasData) {
                            return GridView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              itemCount: snapshot.data!.result!.length,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                              ),
                              itemBuilder: (BuildContext gridContext, int index) {
                                return GestureDetector(
                                  onTap: () async {
                                    bool confirm = await showDialog(
                                      context: bottomSheetContext,
                                      builder: (BuildContext dialogContext) {
                                        return AlertDialog(
                                          title: const Text("Confirm assign"),
                                          content: Text("Are you sure you want to assign the test to ${snapshot.data!.result![index].firstName!} ${snapshot.data!.result![index].lastName!} ?"),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(dialogContext).pop(false);
                                              },
                                              child: const Text("Cancel"),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(dialogContext).pop(true);
                                              },
                                              child: const Text("Yes"),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                    if (confirm) {
                                      showLoaderDialog(bottomSheetContext);
                                      IndividualResponseModel userData = await patientProvider.selectIndividualUserData(snapshot.data!.result![index].id.toString(),context);
                                      prefModel.offlineSavedTests![offlineSavedTestIndex].individualPatientData = userData;
                                      await AppPref.setPref(prefModel);
                                      Navigator.pop(bottomSheetContext);
                                      Navigator.pop(bottomSheetContext);
                                      onSelected(true);
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 15, vertical: 5),
                                    height: 100,
                                    width: 100,
                                    decoration: const BoxDecoration(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(12)),
                                      color: AppColors.primaryColor,
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        snapshot.data!.result![index]
                                                    .profilePicture !=
                                                null
                                            ? CircleAvatar(
                                                radius: 22,
                                                backgroundColor: Colors.grey,
                                                backgroundImage: NetworkImage(
                                                  snapshot.data!.result![index]
                                                      .profilePicture!.url
                                                      .toString(),
                                                ),
                                              )
                                            : const CircleAvatar(
                                                radius: 22,
                                                backgroundColor: Colors.grey,
                                                child: Icon(
                                                  Icons.person,
                                                  color: Colors.white,
                                                ),
                                              ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Text(
                                          // maxLines: 1,
                                          "${snapshot.data!.result![index].firstName!} ${snapshot.data!.result![index].lastName!}",
                                          style: const TextStyle(
                                              overflow: TextOverflow.ellipsis,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                              color: Colors.white),
                                        ),
                                        const SizedBox(
                                          height: 3,
                                        ),
                                        Text(
                                          "${patientProvider.calculateAge(snapshot.data!.result![index].contact!.doB.toString())} ${AppLocale.years.getString(context)}",
                                          style: const TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          }
                          if (snapshot.hasError) {
                            return Center(
                              child: Text(snapshot.error.toString()),
                            );
                          } else {
                            return Center(
                                child:
                                    Text(AppLocale.loading.getString(context)));
                          }
                        },
                      )
                    : FutureBuilder(
                        future: patientProvider.enterprisePatients,
                        builder: (BuildContext context,
                            AsyncSnapshot<AllEnterpriseUsersResponseModel>
                                snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return SizedBox(
                                width: screenSize!.width,
                                child: Shimmer.fromColors(
                                    baseColor: Colors.grey.shade300,
                                    highlightColor: Colors.grey.shade100,
                                    enabled: true,
                                    child: GridView.builder(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                      itemCount: 9,
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 3,
                                        crossAxisSpacing: 10,
                                        mainAxisSpacing: 10,
                                      ),
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return Container(
                                          width: 100,
                                          height: 100,
                                          color: Colors.grey.shade300,
                                        );
                                      },
                                    )));
                          }

                          if (snapshot.hasData) {
                            return GridView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              itemCount: snapshot.data!.result!.length,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                              ),
                              itemBuilder: (BuildContext context, int index) {
                                return GestureDetector(
                                  onTap: () async {
                                    bool confirm = await showDialog(
                                      context: bottomSheetContext,
                                      builder: (BuildContext dialogContext) {
                                        return AlertDialog(
                                          title: const Text("Confirm assign"),
                                          content: Text("Are you sure you want to assign the test to ${snapshot.data!.result![index].firstName!} ${snapshot.data!.result![index].lastName!} ?"),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(dialogContext).pop(false);
                                              },
                                              child: const Text("Cancel"),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(dialogContext).pop(true);
                                              },
                                              child: const Text("Yes"),
                                            ),
                                          ],
                                        );
                                      },
                                    );

                                    if (confirm) {
                                      showLoaderDialog(bottomSheetContext);
                                      EnterpriseResponseModel userData = await patientProvider.selectEnterpriseUserData(snapshot.data!.result![index].id.toString(),context);
                                      prefModel.offlineSavedTests![offlineSavedTestIndex].enterprisePatientData = userData;
                                      await AppPref.setPref(prefModel);
                                      Navigator.pop(bottomSheetContext);
                                      Navigator.pop(bottomSheetContext);
                                      onSelected(true);
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 15, vertical: 5),
                                    height: 100,
                                    width: 100,
                                    decoration: const BoxDecoration(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(12)),
                                      color: AppColors.primaryColor,
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        snapshot.data!.result![index]
                                                    .profilePicture !=
                                                null
                                            ? CircleAvatar(
                                                radius: 22,
                                                backgroundColor: Colors.grey,
                                                backgroundImage: NetworkImage(
                                                  snapshot.data!.result![index]
                                                      .profilePicture!.url
                                                      .toString(),
                                                ),
                                              )
                                            : const CircleAvatar(
                                                radius: 22,
                                                backgroundColor: Colors.grey,
                                                child: Icon(
                                                  Icons.person,
                                                  color: Colors.white,
                                                ),
                                              ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Text(
                                          // maxLines: 2,
                                          "${snapshot.data!.result![index].firstName!} ${snapshot.data!.result![index].lastName!}",
                                          style: const TextStyle(
                                              overflow: TextOverflow.ellipsis,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                              color: Colors.white),
                                        ),
                                        const SizedBox(
                                          height: 3,
                                        ),
                                        Text(
                                          "${patientProvider.calculateAge(snapshot.data!.result![index].contact!.doB.toString())} ${AppLocale.years.getString(context)}",
                                          style: const TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          }
                          if (snapshot.hasError) {
                            return Center(
                              child: Text(snapshot.error.toString()),
                            );
                          } else {
                            return Center(
                                child:
                                    Text(AppLocale.loading.getString(context)));
                          }
                        },
                      ),
              );
            },
          ),
        ],
      );
    },
  );
}

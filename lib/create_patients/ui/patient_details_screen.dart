import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vicare/create_patients/provider/patient_provider.dart';
import 'package:vicare/utils/app_colors.dart';
import 'package:vicare/utils/app_locale.dart';

import '../../dashboard/model/device_response_model.dart';
import '../../dashboard/model/duration_response_model.dart';
import '../../dashboard/model/my_reports_response_model.dart';
import '../../dashboard/provider/devices_provider.dart';
import '../../main.dart';
import '../../utils/app_buttons.dart';
import '../../utils/routes.dart';
import '../model/check_request_count_model.dart';
import '../model/dashboard_count_response_model.dart';
import '../model/enterprise_response_model.dart';
import '../model/individual_response_model.dart';

class PatientDetailsScreen extends StatefulWidget {
  const PatientDetailsScreen({super.key});

  @override
  State<PatientDetailsScreen> createState() => _PatientDetailsScreenState();
}

class _PatientDetailsScreenState extends State<PatientDetailsScreen> {
  IndividualResponseModel? individualPatientData;
  EnterpriseResponseModel? enterprisePatientData;
  Future<DashboardCountResponseModel>? countsData;

  String? pId;

  bool isLoaded = false;
  bool isCountsLoaded = false;

  @override
  Widget build(BuildContext context) {
    final arguments = (ModalRoute.of(context)?.settings.arguments ??
        <String, dynamic>{}) as Map;
    pId = arguments['id'].toString();

    return Consumer(
      builder: (BuildContext context, PatientProvider patientProvider,
          Widget? child) {
        if (!isLoaded) {
          if (prefModel.userData!.roleId == 2) {
            patientProvider.getIndividualUserData(pId, context);
          } else {
            patientProvider.getEnterpriseUserData(pId, context);
          }
          isLoaded = true;
        }
        return Scaffold(
            appBar: AppBar(
              title: Text(
                prefModel.userData!.roleId == 2
                    ? AppLocale.memberDetails.getString(context)
                    : prefModel.userData!.roleId == 3
                        ? AppLocale.patientDetails.getString(context)
                        : prefModel.userData!.roleId == 4
                            ? AppLocale.playerDetails.getString(context)
                            : "",
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
              actions: [
                GestureDetector(
                  onTap: () async {
                    // await patientProvider.getStateMaster(context,);
                    // await patientProvider.getCountryMaster(context);
                    if (prefModel.userData!.roleId == 2 &&
                        individualPatientData?.result != null) {
                      await patientProvider.prefillEditPatientDetails(context,
                          individualPatientData, enterprisePatientData);
                    }
                    if (prefModel.userData!.roleId == 3 &&
                        enterprisePatientData?.result != null) {
                      await patientProvider.prefillEditPatientDetails(context,
                          individualPatientData, enterprisePatientData);
                    }

                    if (prefModel.userData!.roleId == 4 &&
                        enterprisePatientData?.result != null) {
                      await patientProvider.prefillEditPatientDetails(context,
                          individualPatientData, enterprisePatientData);
                    }

                    Navigator.pop(context);
                    Navigator.pushNamed(context, Routes.editPatientsRoute,
                        arguments: {
                          "individualUserData": individualPatientData,
                          "enterPriseUserData": enterprisePatientData
                        }).then((value) {
                      setState(() {
                        patientProvider.getUserDetails(context);
                        isLoaded = false;
                        isCountsLoaded = false;
                      });
                      return null;
                    });
                  },
                  child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: const BoxDecoration(
                          color: Color(0xFFD9D9D9),
                          borderRadius: BorderRadius.all(Radius.circular(40))),
                      padding: const EdgeInsets.all(5),
                      child: const Icon(
                        Icons.edit_outlined,
                        color: AppColors.primaryColor,
                        size: 20,
                      )),
                )
              ],
            ),
            body: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: RefreshIndicator(
                  onRefresh: () async {
                    setState(() {
                      isLoaded = false;
                    });
                  },
                  child: prefModel.userData!.roleId == 2
                      ? FutureBuilder(
                          future: patientProvider.individualUserData,
                          builder: (BuildContext f1Context,
                              AsyncSnapshot<IndividualResponseModel> snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(
                                child: SizedBox(
                                  width: 150,
                                  height: 150,
                                  child: Lottie.asset(
                                      'assets/lottie/loading.json'),
                                ),
                              );
                            }
                            if (snapshot.hasData) {
                              individualPatientData = snapshot.data;
                              if (isCountsLoaded != true) {
                                countsData = patientProvider.getCounts(
                                    individualPatientData!.result!.id!,
                                    context);
                                isCountsLoaded = true;
                              }
                              return Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 10),
                                    width: screenSize!.width,
                                    color: AppColors.primaryColor,
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            (snapshot.data!.result!
                                                            .profilePicture !=
                                                        null &&
                                                    snapshot
                                                            .data!
                                                            .result!
                                                            .profilePicture!
                                                            .url !=
                                                        null)
                                                ? CircleAvatar(
                                                    radius: 40,
                                                    backgroundColor:
                                                        Colors.grey,
                                                    backgroundImage:
                                                        NetworkImage(snapshot
                                                            .data!
                                                            .result!
                                                            .profilePicture!
                                                            .url!
                                                            .toString()))
                                                : const CircleAvatar(
                                                    radius: 22,
                                                    backgroundColor:
                                                        Colors.grey,
                                                    child: Icon(
                                                      Icons.person,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                            const SizedBox(
                                              width: 20,
                                            ),
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                SizedBox(
                                                  width: screenSize!.width / 2,
                                                  child: Text(
                                                    "${snapshot.data!.result!.firstName} ${snapshot.data!.result!.lastName}",
                                                    style: const TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontSize: 20),
                                                  ),
                                                ),
                                                Text(
                                                  "${patientProvider.calculateAge(snapshot.data!.result!.contact!.doB.toString())} ${AppLocale.years.getString(context)}",
                                                  style: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 18),
                                                ),
                                                Text(
                                                  snapshot
                                                              .data!
                                                              .result!
                                                              .contact!
                                                              .gender ==
                                                          1
                                                      ? "Male"
                                                      : snapshot
                                                                  .data!
                                                                  .result!
                                                                  .contact!
                                                                  .gender ==
                                                              2
                                                          ? "Female"
                                                          : "Do not wish to specify",
                                                  style: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 18),
                                                ),
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                                // Text(
                                                //   AppLocale.viewCompleteDetails
                                                //       .getString(context),
                                                //   style: const TextStyle(
                                                //       color: Colors.white,
                                                //       fontWeight: FontWeight.w500,
                                                //       fontSize: 12,
                                                //       decoration:
                                                //       TextDecoration.underline,
                                                //       decorationColor:
                                                //       Colors.white),
                                                // ),
                                                const SizedBox(height: 10),
                                                InkWell(
                                                  onTap: () {
                                                    Navigator.pushNamed(context,
                                                        Routes.summaryRoute,
                                                        arguments: {
                                                          'pId': pId
                                                        }).then((value) {
                                                      setState(() {
                                                        patientProvider
                                                            .getUserDetails(
                                                                context);
                                                        isLoaded = false;
                                                        isCountsLoaded = false;
                                                      });
                                                    });
                                                  },
                                                  child: Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 18,
                                                          vertical: 12),
                                                      decoration: const BoxDecoration(
                                                          color:
                                                              Color(0xffdbeeee),
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          10))),
                                                      child: Text(
                                                        AppLocale.viewSummary
                                                            .getString(context),
                                                        style: const TextStyle(
                                                            fontSize: 13,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w600),
                                                      )),
                                                ),
                                                const SizedBox(
                                                  height: 20,
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        FutureBuilder(
                                          future: countsData,
                                          builder: (BuildContext context,
                                              AsyncSnapshot<
                                                      DashboardCountResponseModel>
                                                  countSnapshot) {
                                            if (countSnapshot.connectionState ==
                                                ConnectionState.waiting) {
                                              return SizedBox(
                                                width: screenSize!.width,
                                                child: Shimmer.fromColors(
                                                  baseColor:
                                                      Colors.grey.shade300,
                                                  highlightColor:
                                                      Colors.grey.shade100,
                                                  enabled: true,
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Column(
                                                        children: [
                                                          Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    left: 15,
                                                                    right: 10,
                                                                    top: 10,
                                                                    bottom: 10),
                                                            decoration:
                                                                const BoxDecoration(
                                                              borderRadius: BorderRadius
                                                                  .all(Radius
                                                                      .circular(
                                                                          12)),
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                            height: 100,
                                                            width: screenSize!
                                                                    .width /
                                                                4,
                                                          ),
                                                          const SizedBox(
                                                            height: 5,
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(
                                                        width: 10,
                                                      ),
                                                      Column(
                                                        children: [
                                                          Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(12),
                                                            decoration:
                                                                const BoxDecoration(
                                                              borderRadius: BorderRadius
                                                                  .all(Radius
                                                                      .circular(
                                                                          12)),
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                            height: 100,
                                                            width: screenSize!
                                                                    .width /
                                                                4,
                                                          ),
                                                          const SizedBox(
                                                            height: 5,
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(
                                                        width: 10,
                                                      ),
                                                      Column(
                                                        children: [
                                                          Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(12),
                                                            decoration:
                                                                const BoxDecoration(
                                                              borderRadius: BorderRadius
                                                                  .all(Radius
                                                                      .circular(
                                                                          12)),
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                            height: 100,
                                                            width: screenSize!
                                                                    .width /
                                                                4,
                                                          ),
                                                          const SizedBox(
                                                            height: 5,
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            }
                                            if (countSnapshot.hasData) {
                                              return Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                left: 15,
                                                                right: 10,
                                                                top: 10,
                                                                bottom: 10),
                                                        decoration:
                                                            const BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          12)),
                                                          color: Colors.white,
                                                        ),
                                                        height: 100,
                                                        width:
                                                            screenSize!.width /
                                                                4,
                                                        child: Center(
                                                          child: Text(
                                                            double.parse(
                                                                    countSnapshot
                                                                        .data!
                                                                        .result!
                                                                        .readinessScore!)
                                                                .toStringAsFixed(
                                                                    0),
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: const TextStyle(
                                                                fontSize: 20,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600),
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        height: 5,
                                                      ),
                                                      SizedBox(
                                                        width:
                                                            screenSize!.width /
                                                                4,
                                                        child: Text(
                                                          AppLocale.readiness
                                                              .getString(
                                                                  context),
                                                          style: const TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 13,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis),
                                                          maxLines: 3,
                                                          textAlign:
                                                              TextAlign.center,
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                  const SizedBox(
                                                    width: 10,
                                                  ),
                                                  Column(
                                                    children: [
                                                      Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(12),
                                                        decoration:
                                                            const BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          12)),
                                                          color: Colors.white,
                                                        ),
                                                        height: 100,
                                                        width:
                                                            screenSize!.width /
                                                                4,
                                                        child: Center(
                                                            child: Text(
                                                          countSnapshot
                                                                      .data!
                                                                      .result!
                                                                      .totalTests !=
                                                                  null
                                                              ? countSnapshot
                                                                  .data!
                                                                  .result!
                                                                  .totalTests!
                                                                  .toString()
                                                              : "0",
                                                          style: const TextStyle(
                                                              fontSize: 20,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600),
                                                        )),
                                                      ),
                                                      const SizedBox(
                                                        height: 5,
                                                      ),
                                                      FittedBox(
                                                        child: Text(
                                                          AppLocale.totalTested
                                                              .getString(
                                                                  context),
                                                          style: const TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 13,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                  const SizedBox(
                                                    width: 10,
                                                  ),
                                                  Column(
                                                    children: [
                                                      Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(12),
                                                        decoration:
                                                            const BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          12)),
                                                          color: Colors.white,
                                                        ),
                                                        height: 100,
                                                        width:
                                                            screenSize!.width /
                                                                4,
                                                        child: Center(
                                                            child: Text(
                                                          countSnapshot
                                                                      .data!
                                                                      .result!
                                                                      .reportsCount !=
                                                                  null
                                                              ? countSnapshot
                                                                  .data!
                                                                  .result!
                                                                  .reportsCount!
                                                                  .toString()
                                                              : "0",
                                                          style: const TextStyle(
                                                              fontSize: 20,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600),
                                                        )),
                                                      ),
                                                      const SizedBox(
                                                        height: 5,
                                                      ),
                                                      FittedBox(
                                                        child: Text(
                                                          AppLocale.reports
                                                              .getString(
                                                                  context),
                                                          style: const TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 13,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ],
                                              );
                                            }
                                            if (snapshot.hasError) {
                                              return Center(
                                                child: Text(
                                                    snapshot.error.toString()),
                                              );
                                            } else {
                                              return Center(
                                                  child: Text(AppLocale.loading
                                                      .getString(context)));
                                            }
                                          },
                                        )
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 15, vertical: 10),
                                    child: Column(
                                      children: [
                                        Consumer(
                                          builder:
                                              (BuildContext takeTestContext,
                                                  DeviceProvider deviceProvider,
                                                  Widget? child) {
                                            return Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 8,
                                                        horizontal: 10),
                                                decoration: const BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(12)),
                                                  color: AppColors.primaryColor,
                                                ),
                                                width: screenSize!.width,
                                                height: 100,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    SizedBox(
                                                        width:
                                                            screenSize!.width *
                                                                0.6,
                                                        child: Text(
                                                          "${AppLocale.startNewScan.getString(context)} ${snapshot.data!.result!.firstName} ${snapshot.data!.result!.lastName}",
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize: 16),
                                                        )),
                                                    const SizedBox(width: 5),
                                                    GestureDetector(
                                                      onTap: () async {
                                                        showDialog(
                                                            context: context,
                                                            builder: (BuildContext
                                                                alertContext) {
                                                              return AlertDialog(
                                                                title: Text(AppLocale
                                                                    .conCent
                                                                    .getString(
                                                                        context)),
                                                                content: Text(
                                                                    "${AppLocale.confirmRecordShare.getString(context)} ${prefModel.userData!.roleId == 2 ? "Platform" : prefModel.userData!.roleId == 3 ? "Doctor" : "Coach"}${AppLocale.forImprovements.getString(context)}"),
                                                                actions: [
                                                                  TextButton(
                                                                      onPressed:
                                                                          () {
                                                                        Navigator.pop(
                                                                            context);
                                                                      },
                                                                      child: Text(AppLocale
                                                                          .cancel
                                                                          .getString(
                                                                              context))),
                                                                  TextButton(
                                                                      onPressed:
                                                                          () async {
                                                                        Navigator.pop(
                                                                            alertContext);
                                                                        var locationWhenInUse = await Permission
                                                                            .locationWhenInUse
                                                                            .request();
                                                                        if (locationWhenInUse ==
                                                                            PermissionStatus.granted) {
                                                                          CheckRequestCountModel countRes = await patientProvider.checkRequestCount(
                                                                              context,
                                                                              individualPatientData?.result!.id,
                                                                              enterprisePatientData?.result!.id);
                                                                          CheckRequestCountModel requestDurationRes = await patientProvider.checkRequestDuration(
                                                                              context,
                                                                              individualPatientData?.result!.id,
                                                                              enterprisePatientData?.result!.id);
                                                                          if (countRes.result ==
                                                                              true) {
                                                                            if (requestDurationRes.result ==
                                                                                true) {
                                                                              var bluetoothConnectStatus = await Permission.bluetoothConnect.request();
                                                                              var bluetoothScanStatus = await Permission.bluetoothScan.request();
                                                                              if (bluetoothConnectStatus == PermissionStatus.granted && bluetoothScanStatus == PermissionStatus.granted) {
                                                                                showLoaderDialog(context);
                                                                                DeviceResponseModel myDevices = await patientProvider.getMyDevices(context);
                                                                                DurationResponseModel myDurations = await patientProvider.getAllDuration(context);
                                                                                Navigator.pop(context);
                                                                                if (myDevices.result != null && myDevices.result!.isNotEmpty) {
                                                                                  showTestFormBottomSheet(context, myDevices, myDurations, snapshot.data!, null);
                                                                                } else {
                                                                                  showErrorToast(context, AppLocale.notAddedDevice.getString(context));
                                                                                }
                                                                              }
                                                                            } else {
                                                                              showErrorToast(takeTestContext, requestDurationRes.message!);
                                                                            }
                                                                          } else {
                                                                            showErrorToast(takeTestContext,
                                                                                countRes.message!);
                                                                          }
                                                                        } else {
                                                                          showErrorToast(
                                                                              context,
                                                                              AppLocale.denyLocation.getString(context));
                                                                        }
                                                                      },
                                                                      child: Text(AppLocale
                                                                          .agree
                                                                          .getString(
                                                                              context))),
                                                                ],
                                                              );
                                                            });
                                                      },
                                                      // if (myDevices
                                                      //     .result!.devices!.isEmpty) {
                                                      //   showErrorToast(context,
                                                      //       myDevices.message!);
                                                      // } else {
                                                      //   Navigator.pushNamed(context,
                                                      //       Routes.takeTestRoute,
                                                      //       arguments: {
                                                      //         'individualPatientData':
                                                      //             snapshot.data!,
                                                      //         'deviceData':
                                                      //             myDevices
                                                      //                 .result!.devices![0]
                                                      //       });
                                                      // }
                                                      child: Container(
                                                          height: 50,
                                                          width: screenSize!
                                                                  .width *
                                                              0.2,
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8),
                                                          decoration: const BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .all(Radius
                                                                          .circular(
                                                                              12)),
                                                              color:
                                                                  Colors.white),
                                                          child: Center(
                                                            child: Text(
                                                              AppLocale.start
                                                                  .getString(
                                                                      context),
                                                              style: const TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 12,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600),
                                                            ),
                                                          )),
                                                    )
                                                  ],
                                                ));
                                          },
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              AppLocale.reports
                                                  .getString(context),
                                              style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w700),
                                            ),
                                            InkWell(
                                              onTap: () {
                                                Navigator.pushNamed(context,
                                                    Routes.reportsRoute,
                                                    arguments: {
                                                      "patientId": snapshot
                                                          .data!.result!.id,
                                                    }).then((value) {
                                                  setState(() {
                                                    patientProvider
                                                        .getUserDetails(
                                                            context);
                                                    isLoaded = false;
                                                    isCountsLoaded = false;
                                                  });
                                                });
                                              },
                                              child: Row(
                                                children: [
                                                  Text(
                                                    AppLocale.viewAll
                                                        .getString(context),
                                                    style: const TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w500),
                                                  ),
                                                  const Icon(
                                                      Icons.navigate_next)
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        FutureBuilder(
                                          future:
                                              patientProvider.getPatientReports(
                                                  snapshot.data!.result!.id,
                                                  context),
                                          builder: (BuildContext context,
                                              AsyncSnapshot<
                                                      MyReportsResponseModel>
                                                  patientSnapshot) {
                                            if (snapshot.connectionState ==
                                                ConnectionState.waiting) {
                                              return SizedBox(
                                                width: screenSize!.width,
                                                child: Shimmer.fromColors(
                                                  baseColor:
                                                      Colors.grey.shade300,
                                                  highlightColor:
                                                      Colors.grey.shade100,
                                                  enabled: true,
                                                  child: ListView.builder(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 10),
                                                    itemCount: 3,
                                                    shrinkWrap: true,
                                                    physics:
                                                        const NeverScrollableScrollPhysics(),
                                                    itemBuilder:
                                                        (BuildContext context,
                                                            int index) {
                                                      return Container(
                                                        margin: const EdgeInsets
                                                            .symmetric(
                                                            vertical: 10),
                                                        width: 80,
                                                        height: 100,
                                                        color: Colors
                                                            .grey.shade300,
                                                      );
                                                    },
                                                  ),
                                                ),
                                              );
                                            }
                                            if (patientSnapshot.hasData) {
                                              return patientSnapshot
                                                      .data!.result!.isNotEmpty
                                                  ? ListView.separated(
                                                      itemCount: patientSnapshot
                                                                  .data!
                                                                  .result!
                                                                  .length >
                                                              5
                                                          ? 5
                                                          : patientSnapshot
                                                              .data!
                                                              .result!
                                                              .length,
                                                      shrinkWrap: true,
                                                      physics:
                                                          const NeverScrollableScrollPhysics(),
                                                      separatorBuilder:
                                                          (BuildContext context,
                                                              int index) {
                                                        return const SizedBox();
                                                      },
                                                      itemBuilder:
                                                          (BuildContext context,
                                                              int index) {
                                                        return GestureDetector(
                                                          onTap: () {
                                                            if (patientSnapshot
                                                                    .data!
                                                                    .result![
                                                                        index]
                                                                    .processingStatus ==
                                                                3) {
                                                              Navigator.pushNamed(
                                                                  context,
                                                                  Routes
                                                                      .detailedReportRoute,
                                                                  arguments: {
                                                                    "requestDeviceDataId": patientSnapshot
                                                                        .data!
                                                                        .result![
                                                                            index]
                                                                        .id,
                                                                  }).then(
                                                                  (value) {
                                                                setState(() {
                                                                  patientProvider
                                                                      .getUserDetails(
                                                                          context);
                                                                  isLoaded =
                                                                      false;
                                                                  isCountsLoaded =
                                                                      false;
                                                                });
                                                              });
                                                            } else if (patientSnapshot
                                                                    .data!
                                                                    .result![
                                                                        index]
                                                                    .processingStatus ==
                                                                2) {
                                                              showErrorToast(
                                                                  context,
                                                                  AppLocale
                                                                      .reportsNotReady
                                                                      .getString(
                                                                          context));
                                                            } else {
                                                              showErrorToast(
                                                                  context,
                                                                  AppLocale
                                                                      .reportsFailedGenerate
                                                                      .getString(
                                                                          context));
                                                            }
                                                          },
                                                          child: Column(
                                                            children: [
                                                              Container(
                                                                padding: const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        15,
                                                                    vertical:
                                                                        15),
                                                                margin:
                                                                    const EdgeInsets
                                                                        .all(5),
                                                                decoration: const BoxDecoration(
                                                                    boxShadow: [
                                                                      BoxShadow(
                                                                        blurRadius:
                                                                            2,
                                                                        color: Colors
                                                                            .grey,
                                                                        offset: Offset(
                                                                            1,
                                                                            1),
                                                                      ),
                                                                    ],
                                                                    borderRadius:
                                                                        BorderRadius.all(Radius.circular(
                                                                            12)),
                                                                    color: Colors
                                                                        .white),
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    Row(
                                                                      children: [
                                                                        CircleAvatar(
                                                                          backgroundImage: patientSnapshot.data!.result![index].roleId == 2
                                                                              ? NetworkImage(patientSnapshot.data!.result![index].individualProfile!.profilePicture != null ? patientSnapshot.data!.result![index].individualProfile!.profilePicture!.url! : '')
                                                                              : NetworkImage(patientSnapshot.data!.result![index].enterpriseProfile!.profilePicture != null ? patientSnapshot.data!.result![index].enterpriseProfile!.profilePicture!.url! : ''),
                                                                          radius:
                                                                              30,
                                                                          backgroundColor: Colors
                                                                              .grey
                                                                              .shade400,
                                                                          child: (patientSnapshot.data!.result![index].roleId == 2 && patientSnapshot.data!.result![index].individualProfile!.profilePicture == null) || (patientSnapshot.data!.result![index].roleId != 2 && patientSnapshot.data!.result![index].enterpriseProfile!.profilePicture == null)
                                                                              ? const Icon(Icons.person, size: 30, color: Colors.white)
                                                                              : null,
                                                                        ),
                                                                        const SizedBox(
                                                                          width:
                                                                              20,
                                                                        ),
                                                                        Column(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.center,
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children: [
                                                                            SizedBox(
                                                                              width: screenSize!.width / 3,
                                                                              child: Text(
                                                                                patientSnapshot.data!.result![index].roleId == 2 ? "${patientSnapshot.data!.result![index].individualProfile!.firstName!} ${patientSnapshot.data!.result![index].individualProfile!.lastName!}" : "${patientSnapshot.data!.result![index].enterpriseProfile!.firstName!} ${patientSnapshot.data!.result![index].enterpriseProfile!.lastName!}",
                                                                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                                                              ),
                                                                            ),
                                                                            const SizedBox(height: 5),
                                                                            Text("${patientSnapshot.data!.result![index].durationName!} Test"),
                                                                            // Text(
                                                                            //   patientSnapshot.data!.result![index].roleId==2?
                                                                            //   "${calculateAge(patientSnapshot.data!.result![index].individualProfile!.contact!.doB!)} Years":
                                                                            //   "${calculateAge(patientSnapshot.data!.result![index].enterpriseProfile!.contact!.doB!)} Years",
                                                                            //   style: const TextStyle(
                                                                            //       color: Colors.black, fontSize: 12),
                                                                            // ),
                                                                            // const SizedBox(height: 5),
                                                                            // Text(
                                                                            //   patientReports[index]["description"],
                                                                            //   style: const TextStyle(
                                                                            //       color: Colors.black, fontSize: 12),
                                                                            // ),
                                                                            const SizedBox(height: 5),
                                                                            Text(
                                                                              "${parseDate(patientSnapshot.data!.result![index].requestDateTime!)}",
                                                                              style: const TextStyle(color: Colors.black, fontSize: 12),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    Container(
                                                                      child:
                                                                          // (patientReports[index]["receivedReport"] == true)
                                                                          //     ? Column(
                                                                          //   mainAxisAlignment:
                                                                          //   MainAxisAlignment.center,
                                                                          //   children: [
                                                                          //     SizedBox(
                                                                          //       width: 50,
                                                                          //       height: 50,
                                                                          //       child: Stack(
                                                                          //         children: [
                                                                          //           CircularStepProgressIndicator(
                                                                          //             totalSteps: 200,
                                                                          //             currentStep: int.parse(
                                                                          //                 patientReports[index]
                                                                          //                 ["repData"]["bpm"]),
                                                                          //             stepSize: 5,
                                                                          //             selectedColor:
                                                                          //             patientReports[index]
                                                                          //             ["repData"]["color"],
                                                                          //             unselectedColor:
                                                                          //             Colors.grey[200],
                                                                          //             padding: 0,
                                                                          //             selectedStepSize: 6,
                                                                          //             roundedCap: (_, __) => true,
                                                                          //           ),
                                                                          //           Center(
                                                                          //             child: Text(
                                                                          //               patientReports[index]
                                                                          //               ["repData"]["bpm"],
                                                                          //               style: const TextStyle(
                                                                          //                 color: Colors.black,
                                                                          //                 fontWeight: FontWeight.bold,
                                                                          //                 fontSize: 10,
                                                                          //               ),
                                                                          //             ),
                                                                          //           ),
                                                                          //         ],
                                                                          //       ),
                                                                          //     ),
                                                                          //     const SizedBox(height: 10),
                                                                          //     Text(
                                                                          //       patientReports[index]["repData"]
                                                                          //       ["status"],
                                                                          //       style: TextStyle(
                                                                          //           fontSize: 12,
                                                                          //           color: patientReports[index]
                                                                          //           ["repData"]["color"]),
                                                                          //     )
                                                                          //   ],
                                                                          // )
                                                                          //     :
                                                                          Column(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.center,
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.center,
                                                                        children: [
                                                                          Container(
                                                                            width:
                                                                                MediaQuery.of(context).size.width / 5,
                                                                            height:
                                                                                30,
                                                                            decoration:
                                                                                BoxDecoration(
                                                                              borderRadius: const BorderRadius.all(Radius.circular(20)),
                                                                              color: getChipColor(patientSnapshot.data!.result![index].processingStatus),
                                                                            ),
                                                                            child:
                                                                                Center(
                                                                              child: Text(
                                                                                patientSnapshot.data!.result![index].processingStatus == 1
                                                                                    ? AppLocale.newReport.getString(context)
                                                                                    : patientSnapshot.data!.result![index].processingStatus == 2
                                                                                        ? AppLocale.inProgress.getString(context)
                                                                                        : patientSnapshot.data!.result![index].processingStatus == 3
                                                                                            ? AppLocale.successReport.getString(context)
                                                                                            : patientSnapshot.data!.result![index].processingStatus == 4
                                                                                                ? AppLocale.failReport.getString(context)
                                                                                                : '',
                                                                                style: const TextStyle(
                                                                                  color: Colors.white,
                                                                                  fontSize: 10,
                                                                                  fontWeight: FontWeight.w600,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                height: 10,
                                                              ),
                                                            ],
                                                          ),
                                                        );
                                                      },
                                                    )
                                                  : Center(
                                                      child: Text(AppLocale
                                                          .noReportFound
                                                          .getString(context)),
                                                    );
                                            }
                                            if (snapshot.hasError) {
                                              return Center(
                                                child: Text(
                                                    snapshot.error.toString()),
                                              );
                                            } else {
                                              return Center(
                                                  child: Text(AppLocale.loading
                                                      .getString(context)));
                                            }
                                          },
                                        ),
                                        const SizedBox(
                                          height: 20,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            }
                            if (snapshot.hasError) {
                              return Center(
                                child: Text(snapshot.error.toString()),
                              );
                            } else {
                              return Center(
                                  child: Text(
                                      AppLocale.loading.getString(context)));
                            }
                          },
                        )
                      : FutureBuilder(
                          future: patientProvider.enterpriseUserData,
                          builder: (BuildContext f1Context,
                              AsyncSnapshot<EnterpriseResponseModel> snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(
                                child: SizedBox(
                                  width: 150,
                                  height: 150,
                                  child: Lottie.asset(
                                      'assets/lottie/loading.json'),
                                ),
                              );
                            }
                            if (snapshot.hasData) {
                              enterprisePatientData = snapshot.data;
                              Future<DashboardCountResponseModel>? countsData;
                              if (isCountsLoaded != true) {
                                countsData = patientProvider.getCounts(
                                    snapshot.data!.result!.id!, context);
                                isCountsLoaded = true;
                              }
                              return Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 10),
                                    width: screenSize!.width,
                                    color: AppColors.primaryColor,
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            (snapshot.data!.result!
                                                            .profilePicture !=
                                                        null &&
                                                    snapshot
                                                            .data!
                                                            .result!
                                                            .profilePicture!
                                                            .url !=
                                                        null)
                                                ? CircleAvatar(
                                                    radius: 40,
                                                    backgroundColor:
                                                        Colors.grey,
                                                    backgroundImage:
                                                        NetworkImage(snapshot
                                                            .data!
                                                            .result!
                                                            .profilePicture!
                                                            .url!
                                                            .toString()))
                                                : const CircleAvatar(
                                                    radius: 22,
                                                    backgroundColor:
                                                        Colors.grey,
                                                    child: Icon(
                                                      Icons.person,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                            const SizedBox(
                                              width: 20,
                                            ),
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                SizedBox(
                                                  width: screenSize!.width / 2,
                                                  child: Text(
                                                    "${snapshot.data!.result!.firstName} ${snapshot.data!.result!.lastName}",
                                                    style: const TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontSize: 20),
                                                  ),
                                                ),
                                                Text(
                                                  "${patientProvider.calculateAge(snapshot.data!.result!.contact!.doB.toString())} ${AppLocale.years.getString(context)}",
                                                  style: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 18),
                                                ),
                                                Text(
                                                  snapshot
                                                              .data!
                                                              .result!
                                                              .contact!
                                                              .gender ==
                                                          1
                                                      ? "Male"
                                                      : snapshot
                                                                  .data!
                                                                  .result!
                                                                  .contact!
                                                                  .gender ==
                                                              2
                                                          ? "Female"
                                                          : "Do not wish to specify",
                                                  style: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 18),
                                                ),
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                                // Text(
                                                //   AppLocale.viewCompleteDetails
                                                //       .getString(context),
                                                //   style: const TextStyle(
                                                //       color: Colors.white,
                                                //       fontWeight: FontWeight.w500,
                                                //       fontSize: 12,
                                                //       decoration:
                                                //       TextDecoration.underline,
                                                //       decorationColor:
                                                //       Colors.white),
                                                // ),
                                                const SizedBox(height: 10),
                                                InkWell(
                                                  onTap: () {
                                                    Navigator.pushNamed(context,
                                                        Routes.summaryRoute,
                                                        arguments: {
                                                          'pId': pId
                                                        }).then((value) {
                                                      setState(() {
                                                        patientProvider
                                                            .getUserDetails(
                                                                context);
                                                        isLoaded = false;
                                                        isCountsLoaded = false;
                                                      });
                                                    });
                                                  },
                                                  child: Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 18,
                                                          vertical: 12),
                                                      decoration: const BoxDecoration(
                                                          color:
                                                              Color(0xffdbeeee),
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          10))),
                                                      child: Text(
                                                        AppLocale.viewSummary
                                                            .getString(context),
                                                        style: const TextStyle(
                                                            fontSize: 13,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w600),
                                                      )),
                                                ),
                                                const SizedBox(
                                                  height: 20,
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        FutureBuilder(
                                          future: countsData,
                                          builder: (BuildContext context,
                                              AsyncSnapshot<
                                                      DashboardCountResponseModel>
                                                  countSnapshot) {
                                            if (countSnapshot.connectionState ==
                                                ConnectionState.waiting) {
                                              return SizedBox(
                                                width: screenSize!.width,
                                                child: Shimmer.fromColors(
                                                  baseColor:
                                                      Colors.grey.shade300,
                                                  highlightColor:
                                                      Colors.grey.shade100,
                                                  enabled: true,
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Column(
                                                        children: [
                                                          Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    left: 15,
                                                                    right: 10,
                                                                    top: 10,
                                                                    bottom: 10),
                                                            decoration:
                                                                const BoxDecoration(
                                                              borderRadius: BorderRadius
                                                                  .all(Radius
                                                                      .circular(
                                                                          12)),
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                            height: 100,
                                                            width: screenSize!
                                                                    .width /
                                                                4,
                                                          ),
                                                          const SizedBox(
                                                            height: 5,
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(
                                                        width: 10,
                                                      ),
                                                      Column(
                                                        children: [
                                                          Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(12),
                                                            decoration:
                                                                const BoxDecoration(
                                                              borderRadius: BorderRadius
                                                                  .all(Radius
                                                                      .circular(
                                                                          12)),
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                            height: 100,
                                                            width: screenSize!
                                                                    .width /
                                                                4,
                                                          ),
                                                          const SizedBox(
                                                            height: 5,
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(
                                                        width: 10,
                                                      ),
                                                      Column(
                                                        children: [
                                                          Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(12),
                                                            decoration:
                                                                const BoxDecoration(
                                                              borderRadius: BorderRadius
                                                                  .all(Radius
                                                                      .circular(
                                                                          12)),
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                            height: 100,
                                                            width: screenSize!
                                                                    .width /
                                                                4,
                                                          ),
                                                          const SizedBox(
                                                            height: 5,
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            }
                                            if (countSnapshot.hasData) {
                                              return Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                left: 15,
                                                                right: 10,
                                                                top: 10,
                                                                bottom: 10),
                                                        decoration:
                                                            const BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          12)),
                                                          color: Colors.white,
                                                        ),
                                                        height: 100,
                                                        width:
                                                            screenSize!.width /
                                                                4,
                                                        child: Center(
                                                          child: Text(
                                                            (countSnapshot.data?.result?.readinessScore != null
                                                                ? double.parse(countSnapshot.data!.result!.readinessScore!).toStringAsFixed(0)
                                                                : '0.0'),
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: const TextStyle(
                                                                fontSize: 20,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600),
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        height: 5,
                                                      ),
                                                      FittedBox(
                                                        child: Text(
                                                          textAlign:
                                                              TextAlign.center,
                                                          AppLocale.readiness
                                                              .getString(
                                                                  context),
                                                          style: const TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 13,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                  const SizedBox(
                                                    width: 10,
                                                  ),
                                                  Column(
                                                    children: [
                                                      Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(12),
                                                        decoration:
                                                            const BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          12)),
                                                          color: Colors.white,
                                                        ),
                                                        height: 100,
                                                        width:
                                                            screenSize!.width /
                                                                4,
                                                        child: Center(
                                                            child: Text(
                                                          countSnapshot
                                                                      .data!
                                                                      .result!
                                                                      .totalTests !=
                                                                  null
                                                              ? countSnapshot
                                                                  .data!
                                                                  .result!
                                                                  .totalTests!
                                                                  .toString()
                                                              : "0",
                                                          style: const TextStyle(
                                                              fontSize: 20,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600),
                                                        )),
                                                      ),
                                                      const SizedBox(
                                                        height: 5,
                                                      ),
                                                      Text(
                                                        AppLocale.totalTested
                                                            .getString(context),
                                                        style: const TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 15,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis),
                                                      )
                                                    ],
                                                  ),
                                                  const SizedBox(
                                                    width: 10,
                                                  ),
                                                  Column(
                                                    children: [
                                                      Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(12),
                                                        decoration:
                                                            const BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          12)),
                                                          color: Colors.white,
                                                        ),
                                                        height: 100,
                                                        width:
                                                            screenSize!.width /
                                                                4,
                                                        child: Center(
                                                            child: Text(
                                                          countSnapshot
                                                                      .data!
                                                                      .result!
                                                                      .reportsCount !=
                                                                  null
                                                              ? countSnapshot
                                                                  .data!
                                                                  .result!
                                                                  .reportsCount!
                                                                  .toString()
                                                              : "0",
                                                          style: const TextStyle(
                                                              fontSize: 20,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600),
                                                        )),
                                                      ),
                                                      const SizedBox(
                                                        height: 5,
                                                      ),
                                                      Text(
                                                        AppLocale.reports
                                                            .getString(context),
                                                        style: const TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 15,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis),
                                                      )
                                                    ],
                                                  ),
                                                ],
                                              );
                                            }
                                            if (snapshot.hasError) {
                                              return Center(
                                                child: Text(
                                                    snapshot.error.toString()),
                                              );
                                            } else {
                                              return const Center(
                                                  child: Text("loading"));
                                            }
                                          },
                                        )
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 15, vertical: 10),
                                    child: Column(
                                      children: [
                                        Consumer(
                                          builder:
                                              (BuildContext takeTestContext,
                                                  DeviceProvider deviceProvider,
                                                  Widget? child) {
                                            return Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 8,
                                                        horizontal: 10),
                                                decoration: const BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(12)),
                                                  color: AppColors.primaryColor,
                                                ),
                                                width: screenSize!.width,
                                                height: 100,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    SizedBox(
                                                        width:
                                                            screenSize!.width *
                                                                0.6,
                                                        child: Text(
                                                          "${AppLocale.startNewScan.getString(context)} ${snapshot.data!.result!.firstName} ${snapshot.data!.result!.lastName}",
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize: 16),
                                                        )),
                                                    const SizedBox(width: 5),
                                                    GestureDetector(
                                                      onTap: () async {
                                                        showDialog(
                                                            context: context,
                                                            builder: (BuildContext
                                                                alertContext) {
                                                              return AlertDialog(
                                                                title: const Text(
                                                                    "Consent"),
                                                                content: Text(
                                                                    "By confirming, you agree to share the recorded scan data with ${prefModel.userData!.roleId == 2 ? "Platform" : prefModel.userData!.roleId == 3 ? "Doctor" : "Coach"} for improvements"),
                                                                actions: [
                                                                  TextButton(
                                                                      onPressed:
                                                                          () {
                                                                        Navigator.pop(
                                                                            context);
                                                                      },
                                                                      child: const Text(
                                                                          "Cancel")),
                                                                  TextButton(
                                                                      onPressed:
                                                                          () async {
                                                                        Navigator.pop(
                                                                            alertContext);

                                                                        var locationWhenInUse = await Permission
                                                                            .locationWhenInUse
                                                                            .request();
                                                                        if (locationWhenInUse ==
                                                                            PermissionStatus.granted) {
                                                                          CheckRequestCountModel countRes = await patientProvider.checkRequestCount(
                                                                              context,
                                                                              individualPatientData?.result!.id,
                                                                              enterprisePatientData?.result!.id);
                                                                          CheckRequestCountModel requestDurationRes = await patientProvider.checkRequestDuration(
                                                                              context,
                                                                              individualPatientData?.result!.id,
                                                                              enterprisePatientData?.result!.id);
                                                                          if (countRes.result ==
                                                                              true) {
                                                                            if (requestDurationRes.result ==
                                                                                true) {
                                                                              var bluetoothConnectStatus = await Permission.bluetoothConnect.request();
                                                                              var bluetoothScanStatus = await Permission.bluetoothScan.request();
                                                                              if (bluetoothConnectStatus == PermissionStatus.granted && bluetoothScanStatus == PermissionStatus.granted) {
                                                                                showLoaderDialog(context);
                                                                                DeviceResponseModel myDevices = await patientProvider.getMyDevices(context);
                                                                                DurationResponseModel myDurations = await patientProvider.getAllDuration(context);
                                                                                Navigator.pop(context);
                                                                                if (myDevices.result != null && myDevices.result!.isNotEmpty) {
                                                                                  showTestFormBottomSheet(context, myDevices, myDurations, null, snapshot.data!);
                                                                                } else {
                                                                                  showErrorToast(context, AppLocale.notAddedDevice.getString(context));
                                                                                }
                                                                              }
                                                                            } else {
                                                                              showErrorToast(takeTestContext, requestDurationRes.message!);
                                                                            }
                                                                          } else {
                                                                            showErrorToast(takeTestContext,
                                                                                countRes.message!);
                                                                          }
                                                                        } else {
                                                                          showErrorToast(
                                                                              context,
                                                                              "Location permission is required to proceed. Please enable and try again");
                                                                        }
                                                                      },
                                                                      child: Text(
                                                                          "Agree")),
                                                                ],
                                                              );
                                                            });
                                                      },
                                                      child: Container(
                                                          height: 50,
                                                          width: screenSize!
                                                                  .width *
                                                              0.2,
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8),
                                                          decoration: const BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .all(Radius
                                                                          .circular(
                                                                              12)),
                                                              color:
                                                                  Colors.white),
                                                          child: Center(
                                                            child: Text(
                                                              AppLocale.start
                                                                  .getString(
                                                                      context),
                                                              style: const TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 12,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600),
                                                            ),
                                                          )),
                                                    ),

                                                    // GestureDetector(
                                                    //   onTap: () async {
                                                    //     CheckRequestCountModel
                                                    //         countRes =
                                                    //         await patientProvider.checkRequestCount(
                                                    //             context,
                                                    //             individualPatientData
                                                    //                 ?.result!
                                                    //                 .id,
                                                    //             enterprisePatientData
                                                    //                 ?.result!
                                                    //                 .id);
                                                    //     CheckRequestCountModel
                                                    //         requestDurationRes =
                                                    //         await patientProvider.checkRequestDuration(
                                                    //             context,
                                                    //             individualPatientData
                                                    //                 ?.result!
                                                    //                 .id,
                                                    //             enterprisePatientData
                                                    //                 ?.result!
                                                    //                 .id);
                                                    //     if (countRes
                                                    //             .result ==
                                                    //         true) {
                                                    //       if (requestDurationRes
                                                    //               .result ==
                                                    //           true) {
                                                    //         var bluetoothConnectStatus =
                                                    //             await Permission
                                                    //                 .bluetoothConnect
                                                    //                 .request();
                                                    //         var bluetoothScanStatus =
                                                    //             await Permission
                                                    //                 .bluetoothScan
                                                    //                 .request();
                                                    //         if (bluetoothConnectStatus ==
                                                    //                 PermissionStatus
                                                    //                     .granted &&
                                                    //             bluetoothScanStatus ==
                                                    //                 PermissionStatus
                                                    //                     .granted) {
                                                    //           showLoaderDialog(
                                                    //               context);
                                                    //           DeviceResponseModel
                                                    //               myDevices =
                                                    //               await patientProvider
                                                    //                   .getMyDevices(context);
                                                    //           DurationResponseModel
                                                    //               myDurations =
                                                    //               await patientProvider
                                                    //                   .getAllDuration(context);
                                                    //           Navigator.pop(
                                                    //               context);
                                                    //           if (myDevices.result !=
                                                    //                   null &&
                                                    //               myDevices
                                                    //                   .result!
                                                    //                   .isNotEmpty) {
                                                    //             showTestFormBottomSheet(
                                                    //                 context,
                                                    //                 myDevices,
                                                    //                 myDurations,
                                                    //                 null,
                                                    //                 snapshot
                                                    //                     .data!);
                                                    //           } else {
                                                    //             showErrorToast(
                                                    //                 context,
                                                    //                 AppLocale
                                                    //                     .notAddedDevice
                                                    //                     .getString(context));
                                                    //           }
                                                    //         }
                                                    //       } else {
                                                    //         showErrorToast(
                                                    //             takeTestContext,
                                                    //             requestDurationRes
                                                    //                 .message!);
                                                    //       }
                                                    //     } else {
                                                    //       showErrorToast(
                                                    //           takeTestContext,
                                                    //           countRes
                                                    //               .message!);
                                                    //     }
                                                    //   },
                                                    //   child: Container(
                                                    //       height: 50,
                                                    //       width: screenSize!
                                                    //               .width *
                                                    //           0.2,
                                                    //       padding:
                                                    //           const EdgeInsets
                                                    //               .all(8),
                                                    //       decoration: const BoxDecoration(
                                                    //           borderRadius:
                                                    //               BorderRadius.all(Radius.circular(
                                                    //                   12)),
                                                    //           color: Colors
                                                    //               .white),
                                                    //       child: Center(
                                                    //         child: Text(
                                                    //           AppLocale
                                                    //               .start
                                                    //               .getString(
                                                    //                   context),
                                                    //           style: const TextStyle(
                                                    //               color: Colors
                                                    //                   .black,
                                                    //               fontSize:
                                                    //                   12,
                                                    //               fontWeight:
                                                    //                   FontWeight.w600),
                                                    //         ),
                                                    //       )),
                                                    // )
                                                  ],
                                                ));
                                          },
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              AppLocale.reports
                                                  .getString(context),
                                              style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w700),
                                            ),
                                            InkWell(
                                              onTap: () {
                                                Navigator.pushNamed(context,
                                                    Routes.reportsRoute,
                                                    arguments: {
                                                      "patientId": snapshot
                                                          .data!.result!.id,
                                                    }).then((value) {
                                                  setState(() {
                                                    patientProvider
                                                        .getUserDetails(
                                                            context);
                                                    isLoaded = false;
                                                    isCountsLoaded = false;
                                                  });
                                                });
                                              },
                                              child: Row(
                                                children: [
                                                  Text(
                                                    AppLocale.viewAll
                                                        .getString(context),
                                                    style: const TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w500),
                                                  ),
                                                  const Icon(
                                                      Icons.navigate_next)
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        FutureBuilder(
                                          future:
                                              patientProvider.getPatientReports(
                                                  snapshot.data!.result!.id,
                                                  context),
                                          builder: (BuildContext context,
                                              AsyncSnapshot<
                                                      MyReportsResponseModel>
                                                  patientSnapshot) {
                                            if (snapshot.connectionState ==
                                                ConnectionState.waiting) {
                                              return SizedBox(
                                                width: screenSize!.width,
                                                child: Shimmer.fromColors(
                                                  baseColor:
                                                      Colors.grey.shade300,
                                                  highlightColor:
                                                      Colors.grey.shade100,
                                                  enabled: true,
                                                  child: ListView.builder(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 10),
                                                    itemCount: 3,
                                                    shrinkWrap: true,
                                                    physics:
                                                        const NeverScrollableScrollPhysics(),
                                                    itemBuilder:
                                                        (BuildContext context,
                                                            int index) {
                                                      return Container(
                                                        margin: const EdgeInsets
                                                            .symmetric(
                                                            vertical: 10),
                                                        width: 80,
                                                        height: 100,
                                                        color: Colors
                                                            .grey.shade300,
                                                      );
                                                    },
                                                  ),
                                                ),
                                              );
                                            }
                                            if (patientSnapshot.hasData) {
                                              return patientSnapshot
                                                      .data!.result!.isNotEmpty
                                                  ? ListView.separated(
                                                      itemCount: patientSnapshot
                                                          .data!.result!.length,
                                                      shrinkWrap: true,
                                                      physics:
                                                          const NeverScrollableScrollPhysics(),
                                                      separatorBuilder:
                                                          (BuildContext context,
                                                              int index) {
                                                        return const SizedBox();
                                                      },
                                                      itemBuilder:
                                                          (BuildContext context,
                                                              int index) {
                                                        return GestureDetector(
                                                          onTap: () {
                                                            if (patientSnapshot
                                                                    .data!
                                                                    .result![
                                                                        index]
                                                                    .processingStatus ==
                                                                3) {
                                                              Navigator.pushNamed(
                                                                  context,
                                                                  Routes
                                                                      .detailedReportRoute,
                                                                  arguments: {
                                                                    "requestDeviceDataId": patientSnapshot
                                                                        .data!
                                                                        .result![
                                                                            index]
                                                                        .id,
                                                                  });
                                                            } else if (patientSnapshot
                                                                    .data!
                                                                    .result![
                                                                        index]
                                                                    .processingStatus ==
                                                                2) {
                                                              showErrorToast(
                                                                  context,
                                                                  "Report is not ready yet. Please check back in some time");
                                                            } else {
                                                              showErrorToast(
                                                                  context,
                                                                  "Looks like report failed to generate. Please take a test again");
                                                            }
                                                          },
                                                          child: Column(
                                                            children: [
                                                              Container(
                                                                padding: const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        15,
                                                                    vertical:
                                                                        15),
                                                                margin:
                                                                    const EdgeInsets
                                                                        .all(5),
                                                                decoration: const BoxDecoration(
                                                                    boxShadow: [
                                                                      BoxShadow(
                                                                        blurRadius:
                                                                            2,
                                                                        color: Colors
                                                                            .grey,
                                                                        offset: Offset(
                                                                            1,
                                                                            1),
                                                                      ),
                                                                    ],
                                                                    borderRadius:
                                                                        BorderRadius.all(Radius.circular(
                                                                            12)),
                                                                    color: Colors
                                                                        .white),
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    Row(
                                                                      children: [
                                                                        CircleAvatar(
                                                                          backgroundImage: patientSnapshot.data!.result![index].roleId == 2
                                                                              ? NetworkImage(patientSnapshot.data!.result![index].individualProfile!.profilePicture != null ? patientSnapshot.data!.result![index].individualProfile!.profilePicture!.url! : '')
                                                                              : NetworkImage(patientSnapshot.data!.result![index].enterpriseProfile!.profilePicture != null ? patientSnapshot.data!.result![index].enterpriseProfile!.profilePicture!.url! : ''),
                                                                          radius:
                                                                              30,
                                                                        ),
                                                                        const SizedBox(
                                                                          width:
                                                                              20,
                                                                        ),
                                                                        Column(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.center,
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children: [
                                                                            SizedBox(
                                                                              width: screenSize!.width / 3,
                                                                              child: Text(
                                                                                patientSnapshot.data!.result![index].roleId == 2 ? "${patientSnapshot.data!.result![index].individualProfile!.firstName!} ${patientSnapshot.data!.result![index].individualProfile!.lastName!}" : "${patientSnapshot.data!.result![index].enterpriseProfile!.firstName!} ${patientSnapshot.data!.result![index].enterpriseProfile!.lastName!}",
                                                                                style: const TextStyle(
                                                                                    // overflow: TextOverflow.ellipsis,
                                                                                    fontWeight: FontWeight.bold,
                                                                                    fontSize: 15),
                                                                              ),
                                                                            ),
                                                                            const SizedBox(height: 5),
                                                                            Text("${patientSnapshot.data!.result![index].durationName!} Test"),
                                                                            // Text(
                                                                            //   patientSnapshot.data!.result![index].roleId==2?
                                                                            //   "${calculateAge(patientSnapshot.data!.result![index].individualProfile!.contact!.doB!)} ${AppLocale.years.getString(context)}":
                                                                            //   "${calculateAge(patientSnapshot.data!.result![index].enterpriseProfile!.contact!.doB!)} ${AppLocale.years.getString(context)}",
                                                                            //   style: const TextStyle(
                                                                            //       color: Colors.black, fontSize: 12),
                                                                            // ),
                                                                            // const SizedBox(height: 5),
                                                                            // Text(
                                                                            //   patientReports[index]["description"],
                                                                            //   style: const TextStyle(
                                                                            //       color: Colors.black, fontSize: 12),
                                                                            // ),
                                                                            const SizedBox(height: 5),
                                                                            Text(
                                                                              "${parseDate(patientSnapshot.data!.result![index].requestDateTime!)}",
                                                                              style: const TextStyle(color: Colors.black, fontSize: 12),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    Container(
                                                                      child:
                                                                          // (patientReports[index]["receivedReport"] == true)
                                                                          //     ? Column(
                                                                          //   mainAxisAlignment:
                                                                          //   MainAxisAlignment.center,
                                                                          //   children: [
                                                                          //     SizedBox(
                                                                          //       width: 50,
                                                                          //       height: 50,
                                                                          //       child: Stack(
                                                                          //         children: [
                                                                          //           CircularStepProgressIndicator(
                                                                          //             totalSteps: 200,
                                                                          //             currentStep: int.parse(
                                                                          //                 patientReports[index]
                                                                          //                 ["repData"]["bpm"]),
                                                                          //             stepSize: 5,
                                                                          //             selectedColor:
                                                                          //             patientReports[index]
                                                                          //             ["repData"]["color"],
                                                                          //             unselectedColor:
                                                                          //             Colors.grey[200],
                                                                          //             padding: 0,
                                                                          //             selectedStepSize: 6,
                                                                          //             roundedCap: (_, __) => true,
                                                                          //           ),
                                                                          //           Center(
                                                                          //             child: Text(
                                                                          //               patientReports[index]
                                                                          //               ["repData"]["bpm"],
                                                                          //               style: const TextStyle(
                                                                          //                 color: Colors.black,
                                                                          //                 fontWeight: FontWeight.bold,
                                                                          //                 fontSize: 10,
                                                                          //               ),
                                                                          //             ),
                                                                          //           ),
                                                                          //         ],
                                                                          //       ),
                                                                          //     ),
                                                                          //     const SizedBox(height: 10),
                                                                          //     Text(
                                                                          //       patientReports[index]["repData"]
                                                                          //       ["status"],
                                                                          //       style: TextStyle(
                                                                          //           fontSize: 12,
                                                                          //           color: patientReports[index]
                                                                          //           ["repData"]["color"]),
                                                                          //     )
                                                                          //   ],
                                                                          // )
                                                                          //     :
                                                                          Column(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.center,
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.center,
                                                                        children: [
                                                                          Container(
                                                                            width:
                                                                                MediaQuery.of(context).size.width / 5,
                                                                            height:
                                                                                30,
                                                                            decoration:
                                                                                BoxDecoration(
                                                                              borderRadius: const BorderRadius.all(Radius.circular(20)),
                                                                              color: getChipColor(patientSnapshot.data!.result![index].processingStatus),
                                                                            ),
                                                                            child:
                                                                                Center(
                                                                              child: Text(
                                                                                patientSnapshot.data!.result![index].processingStatus == 1
                                                                                    ? AppLocale.newReport.getString(context)
                                                                                    : patientSnapshot.data!.result![index].processingStatus == 2
                                                                                        ? AppLocale.inProgress.getString(context)
                                                                                        : patientSnapshot.data!.result![index].processingStatus == 3
                                                                                            ? AppLocale.successReport.getString(context)
                                                                                            : patientSnapshot.data!.result![index].processingStatus == 4
                                                                                                ? AppLocale.failReport.getString(context)
                                                                                                : '',
                                                                                style: const TextStyle(
                                                                                  color: Colors.white,
                                                                                  fontSize: 10,
                                                                                  fontWeight: FontWeight.w600,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                height: 10,
                                                              ),
                                                            ],
                                                          ),
                                                        );
                                                      },
                                                    )
                                                  : Center(
                                                      child: Text(AppLocale
                                                          .noReportFound
                                                          .getString(context)),
                                                    );
                                            }
                                            if (snapshot.hasError) {
                                              return Center(
                                                child: Text(
                                                    snapshot.error.toString()),
                                              );
                                            } else {
                                              return Center(
                                                  child: Text(AppLocale.loading
                                                      .getString(context)));
                                            }
                                          },
                                        ),
                                        const SizedBox(
                                          height: 20,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            }
                            if (snapshot.hasError) {
                              return Center(
                                child: Text(snapshot.error.toString()),
                              );
                            } else {
                              return Center(
                                  child: Text(
                                      AppLocale.loading.getString(context)));
                            }
                          },
                        ),
                )));
      },
    );
  }

  int calculateAge(String dateOfBirthString) {
    DateTime dateOfBirth = DateTime.parse(dateOfBirthString).toLocal();
    DateTime currentDate = DateTime.now().toLocal();
    Duration difference = currentDate.difference(dateOfBirth);
    int ageInYears = (difference.inDays / 365).floor();
    return ageInYears;
  }

  parseDate(String timestampString) {
    DateTime parsedDateTime = DateTime.parse(timestampString).toLocal();
    return DateFormat('MMM/dd/yyyy hh:mm aa').format(parsedDateTime);
  }

  parseDateMonth(String timestampString) {
    DateTime parsedDateTime = DateTime.parse(timestampString).toLocal();
    return DateFormat('MMM\ndd\nyyyy').format(parsedDateTime);
  }

  getChipColor(int? processingStatus) {
    return processingStatus == 1
        ? Colors.deepOrange
        : processingStatus == 2
            ? Colors.teal
            : processingStatus == 3
                ? Colors.green
                : processingStatus == 4
                    ? Colors.red
                    : Colors.black;
  }
}

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vicare/create_patients/model/all_patients_response_model.dart';
import 'package:vicare/create_patients/provider/patient_provider.dart';
import 'package:vicare/main.dart';
import 'package:vicare/utils/app_buttons.dart';
import 'package:vicare/utils/url_constants.dart';

import '../../create_patients/model/all_enterprise_users_response_model.dart';
import '../../network/api_calls.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_locale.dart';
import '../../utils/routes.dart';

class ManagePatientsScreen extends StatefulWidget {
  const ManagePatientsScreen({super.key});

  @override
  State<ManagePatientsScreen> createState() => _ManagePatientsScreenState();
}

class _ManagePatientsScreenState extends State<ManagePatientsScreen> {
  List patientData = [
    {
      "patientName": "Tom Luke",
      "age": "25 years",
      "image": "assets/images/img.png"
    },
    {
      "patientName": "Rhea",
      "age": "25 years",
      "image": "assets/images/img_1.png"
    },
    {
      "patientName": "Don dhalim",
      "age": "25 years",
      "image": "assets/images/img.png"
    },
    {
      "patientName": "Kiran deva",
      "age": "25 years",
      "image": "assets/images/img.png"
    },
    {
      "patientName": "Smitha",
      "age": "25 years",
      "image": "assets/images/img_1.png"
    },
    {
      "patientName": "Avinash",
      "age": "25 years",
      "image": "assets/images/img.png"
    },
    {
      "patientName": "Varshini",
      "age": "25 years",
      "image": "assets/images/img_1.png"
    },
    {
      "patientName": "John sully",
      "age": "25 years",
      "image": "assets/images/img.png"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (BuildContext context, PatientProvider patientProvider,
          Widget? child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              prefModel.userData!.roleId == 2
                  ? AppLocale.manageMembers.getString(context)
                  : prefModel.userData!.roleId == 3
                      ? AppLocale.managePatients.getString(context)
                      : prefModel.userData!.roleId == 4
                          ? AppLocale.managePlayers.getString(context)
                          : "",
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: AppColors.primaryColor,
            toolbarHeight: 75,
            automaticallyImplyLeading: false,
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 20),
            child: prefModel.userData!.roleId == 2
                ? FutureBuilder(
                    future: patientProvider.getMyPatients(context),
                    builder: (BuildContext context,
                        AsyncSnapshot<AllPatientsResponseModel> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
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
                                  physics: const NeverScrollableScrollPhysics(),
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
                          itemCount: snapshot.data!.result!.length + 1,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                          ),
                          itemBuilder: (BuildContext context, int index) {
                            if (index == 0) {
                              return InkWell(
                                onTap: () {
                                  patientProvider.clearAddPatientForm();
                                  Navigator.pushNamed(
                                      context, Routes.addNewPatientRoute);
                                },
                                child: DottedBorder(
                                  dashPattern: const [2, 2],
                                  color: Colors.black,
                                  borderType: BorderType.RRect,
                                  radius: const Radius.circular(12),
                                  strokeWidth: 1,
                                  child: Container(
                                    color: Colors.white,
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.add),
                                          Text(
                                            prefModel.userData!.roleId == 2
                                                ? AppLocale.newMember
                                                    .getString(context)
                                                : prefModel.userData!.roleId ==
                                                        3
                                                    ? AppLocale.newPatient
                                                        .getString(context)
                                                    : prefModel.userData!
                                                                .roleId ==
                                                            4
                                                        ? AppLocale.newPlayer
                                                            .getString(context)
                                                        : "",
                                            style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            } else {
                              index = index - 1;
                              return InkWell(
                                onTap: () async {
                                  showLoaderDialog(context);
                                  await patientProvider.getIndividualUserData(snapshot.data!.result![index].user!.uniqueGuid,context);
                                  // Navigator.pushNamed(
                                  //     context, Routes.patientDetailsRoute);
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      CircleAvatar(
                                        radius: 20,
                                        backgroundImage: NetworkImage(
                                          UrlConstants.imageBaseUrl +
                                              snapshot.data!.result![index]
                                                  .user!.profilePicture
                                                  .toString(),
                                        ),
                                        child: Image.network(
                                          UrlConstants.imageBaseUrl +
                                              snapshot.data!.result![index]
                                                  .user!.profilePicture
                                                  .toString(),
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            // Provide a placeholder image when the network image fails to load
                                            return const CircleAvatar(
                                              radius: 20,
                                              backgroundColor: Colors.grey,
                                              // Placeholder background color
                                              child: Icon(
                                                Icons.person,
                                                // You can use any icon or placeholder widget here
                                                color: Colors.white,
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        maxLines: 2,
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
                                        "${snapshot.data!.result![index].id!} Years",
                                        style: const TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }
                          },
                        );
                      }
                      if (snapshot.hasError) {
                        return Center(
                          child: Text(snapshot.error.toString()),
                        );
                      } else {
                        return const Center(child: Text("loading"));
                      }
                    },
                  )
                : FutureBuilder(
                    future: patientProvider.getEnterpriseProfiles(context),
                    builder: (BuildContext context,
                        AsyncSnapshot<AllEnterpriseUsersResponseModel>
                            snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      if (snapshot.hasData) {
                        return GridView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          itemCount: snapshot.data!.result!.length + 1,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                          ),
                          itemBuilder: (BuildContext context, int index) {
                            if (index == 0) {
                              return InkWell(
                                onTap: () {
                                  patientProvider.clearAddPatientForm();
                                  Navigator.pushNamed(
                                      context, Routes.addNewPatientRoute);
                                },
                                child: DottedBorder(
                                  dashPattern: const [2, 2],
                                  color: Colors.black,
                                  borderType: BorderType.RRect,
                                  radius: const Radius.circular(12),
                                  strokeWidth: 1,
                                  child: Container(
                                    color: Colors.white,
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.add),
                                          Text(
                                            prefModel.userData!.roleId == 2
                                                ? AppLocale.newMember
                                                    .getString(context)
                                                : prefModel.userData!.roleId ==
                                                        3
                                                    ? AppLocale.newPatient
                                                        .getString(context)
                                                    : prefModel.userData!
                                                                .roleId ==
                                                            4
                                                        ? AppLocale.newPlayer
                                                            .getString(context)
                                                        : "",
                                            style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            } else {
                              index = index - 1;
                              return InkWell(
                                onTap: () {
                                  Navigator.pushNamed(
                                      context, Routes.patientDetailsRoute);
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      CircleAvatar(
                                        radius: 20,
                                        backgroundImage: NetworkImage(
                                          UrlConstants.imageBaseUrl +
                                              snapshot.data!.result![index]
                                                  .profilePicture
                                                  .toString(),
                                        ),
                                        child: Image.network(
                                          UrlConstants.imageBaseUrl +
                                              snapshot.data!.result![index]
                                                  .profilePicture
                                                  .toString(),
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return const CircleAvatar(
                                              radius: 20,
                                              backgroundColor: Colors.grey,
                                              child: Icon(
                                                Icons.person,
                                                color: Colors.white,
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        maxLines: 2,
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
                                        "${snapshot.data!.result![index].id!} Years",
                                        style: const TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }
                          },
                        );
                      }
                      if (snapshot.hasError) {
                        return Center(
                          child: Text(snapshot.error.toString()),
                        );
                      } else {
                        return const Center(child: Text("loading"));
                      }
                    },
                  ),
          ),
        );
      },
    );
  }
}

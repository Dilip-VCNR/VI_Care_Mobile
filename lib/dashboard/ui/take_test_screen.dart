import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:path_provider/path_provider.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:vicare/create_patients/model/individual_response_model.dart';
import 'package:vicare/dashboard/model/device_response_model.dart';
import 'package:vicare/dashboard/provider/take_test_provider.dart';
import 'package:vicare/database/app_pref.dart';
import 'package:vicare/main.dart';
import 'package:vicare/utils/app_buttons.dart';
import 'package:vicare/utils/app_colors.dart';

import '../../create_patients/model/enterprise_response_model.dart';
import '../../utils/app_locale.dart';
import '../../utils/routes.dart';
import '../model/offline_test_model.dart';

class TakeTestScreen extends StatefulWidget {
  const TakeTestScreen({super.key});

  @override
  State<TakeTestScreen> createState() => _TakeTestScreenState();
}

class _TakeTestScreenState extends State<TakeTestScreen> {
  Timer? timer;
  int secondsRemaining = 0;
  bool isTimerRunning = false;
  int heartRate = 0;
  List<int> bpmList = [];
  List<int> rrIntervalList = [];
  EnterpriseResponseModel? enterprisePatientData;
  IndividualResponseModel? individualPatientData;
  DeviceResult? deviceData;

  final double pWaveDuration = 0.09; // Assuming typical value
  final double qrsComplexDuration = 0.08; // Assuming typical value
  final double tWaveDuration = 0.16; // Assuming typical value

  void startTimer(TakeTestProvider takeTestProvider) {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (secondsRemaining > 0) {
          secondsRemaining--;
        } else {
          for (var subscription in takeTestProvider.subscriptions) {
            subscription.cancel();
          }
          timer.cancel();
          heartRate = 0;
          secondsRemaining = (prefModel.selectedDuration!.durationInMinutes!) * 60;
          isTimerRunning = false;
          if(enterprisePatientData!=null || individualPatientData!=null){
            saveReadings(takeTestProvider);
          }else{
            showSuccessToast(context, "Test complete");
          }
        }
      });
    });
  }

  Future<void> handleStartButtonClick(BuildContext context,
      TakeTestProvider takeTestProvider) async {
    if (!isTimerRunning) {
      await startRecordingReadings(takeTestProvider);
      isTimerRunning = true;
      startTimer(takeTestProvider);
    } else {
      bool userWantsToAbort = await showStopTestWarningDialog(context);
      if (userWantsToAbort) {
        for (var subscription in takeTestProvider.subscriptions) {
          subscription.cancel(); // cancel all subscriptions
        }
        heartRate = 0;
        timer!.cancel();
        secondsRemaining = (prefModel.selectedDuration!.durationInMinutes!) * 60;
        isTimerRunning = false;
        setState(() {});
      }
    }
  }

  @override
  void initState() {
    super.initState();
    if (prefModel.selectedDuration != null) {
      secondsRemaining = (prefModel.selectedDuration!.durationInMinutes!) * 60;
    }
  }

  @override
  void dispose() {
    // for (var subscription in subscriptions) {
    //   subscription.cancel(); // Cancel each subscription
    // }
    if (timer != null) {
      timer!.cancel();
    }
    rrIntervalList.clear();
    bpmList.clear();
    timer?.cancel();
    heartRate = 0;
    secondsRemaining = (prefModel.selectedDuration!.durationInMinutes!) * 60;
    isTimerRunning = false;
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    Provider.of<TakeTestProvider>(context, listen: false).listenToConnectedDevice();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final arguments = (ModalRoute
        .of(context)
        ?.settings
        .arguments ??
        <String, dynamic>{}) as Map;
    enterprisePatientData = arguments['enterprisePatientData'];
    individualPatientData = arguments['individualPatientData'];
    deviceData = arguments['deviceData'];
    return Consumer(
      builder: (BuildContext context, TakeTestProvider takeTestProvider,
          Widget? child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              AppLocale.takeTest.getString(context),
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
          body: takeTestProvider.bluetoothStatus
              ? takeTestProvider.isConnected
              ? prefModel.selectedDuration != null
              ? deviceConnectedWidget(context, takeTestProvider)
              : chooseDurationWidget(context, takeTestProvider)
              : scanBluetoothWidget(context, takeTestProvider)
              : bluetoothOffWarningWidget(context, takeTestProvider),
        );
      },
    );
  }

  Future<void> startRecordingReadings(TakeTestProvider takeTestProvider) async {
    bpmList.clear(); // Clear existing values
    rrIntervalList.clear(); // Clear existing values
    takeTestProvider.subscriptions.clear(); // Clear existing subscriptions

    List<BluetoothService> services = await takeTestProvider.connectedDevice!.discoverServices();
    for (BluetoothService service in services) {
      if (service.uuid.toString() == "0000180d-0000-1000-8000-00805f9b34fb") {
        for (BluetoothCharacteristic characteristic
        in service.characteristics) {
          try {
            await characteristic.setNotifyValue(true);
          } catch (e) {
            log(e.toString());
          }
          StreamSubscription subscription =
          characteristic.value.listen((value) {
            if (value.isNotEmpty) {
              heartRate = value[1];
              bpmList.add(value[1]);
              double rrInterval = 60000 / value[1];
              rrIntervalList.add(rrInterval.toInt());
            }
          });
          takeTestProvider.subscriptions.add(subscription);
        }
      }
    }
  }

  Future<void> saveReadings(TakeTestProvider takeTestProvider) async {
    prefModel.offlineSavedTests!.add(OfflineTestModel(
        myRoleId: prefModel.userData!.roleId,
        bpmList: bpmList,
        rrIntervalList: rrIntervalList,
        scanDuration: prefModel.selectedDuration!.durationInMinutes,
        deviceName: takeTestProvider.connectedDevice!.name,
        deviceId: takeTestProvider.connectedDevice!.id.id,
        patientFirstName: prefModel.userData!.roleId == 2
            ? individualPatientData?.result!.firstName
            : enterprisePatientData?.result!.firstName,
        patientLastName: prefModel.userData!.roleId == 2
            ? individualPatientData?.result!.lastName
            : enterprisePatientData?.result!.lastName,
        patientProfilePic: prefModel.userData!.roleId == 2
            ? individualPatientData?.result!.profilePicture!.path
            : enterprisePatientData?.result!.profilePicture!.path,
        patientId: prefModel.userData!.roleId == 2
            ? individualPatientData?.result!.id
            : enterprisePatientData?.result!.enterpriseUserId,
        created: DateTime.now()));
    AppPref.setPref(prefModel);

    var testData = {
      "fileVersion": "IBIPOLAR",
      "appVersion": "ViCare_1.0.0",
      "serialNumber": deviceData!.deviceSerialNo,
      "guid": "46184141-00c6-46ee-b927-4218085e85fd",
      "age": prefModel.userData!.roleId == 2
          ? calculateAge(individualPatientData!.result!.contact!.doB.toString())
          : calculateAge(enterprisePatientData!.result!.contact!.doB.toString()),
      "gender": prefModel.userData!.roleId == 2
          ? individualPatientData!.result!.contact!.gender
          : enterprisePatientData!.result!.contact!.gender,
      "date": DateTime.now().toIso8601String(),
      "countryCode": "IN",
      "intervals": rrIntervalList
    };


    var jsonString = jsonEncode(testData);

    // Get the internal storage directory
    var directory = await getExternalStorageDirectory();
    var viCareDirectory = Directory('${directory!.path}/vicare');

    if (!(await viCareDirectory.exists())) {
      await viCareDirectory.create(recursive: true);
    }

    var now = DateTime.now();
    var timestamp = now.millisecondsSinceEpoch;
    var filename = 'data_$timestamp.json';
    var filePath = '${viCareDirectory.path}/$filename';

    File payload = File(filePath);
    await payload.writeAsString(jsonString);
    setState(() {
      rrIntervalList.clear();
      bpmList.clear();
    });
    if (await payload.exists()) {
      // File was successfully written
      takeTestProvider.requestDeviceData(context, payload,deviceData!.deviceSerialNo,deviceData!.id,takeTestProvider.connectedDevice!.id.id);
      showSuccessToast(context, "Test successful and saved to offline.");
    } else {
      // Failed to write the file
      showErrorToast(context, "Failed to save test data.");
    }
  }


  Widget deviceConnectedWidget(BuildContext context,
      TakeTestProvider takeTestProvider) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
              width: screenSize!.width,
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  color: AppColors.primaryColor),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: screenSize!.width * 0.6,
                    child: Text(
                      "${AppLocale.connectedTo.getString(
                          context)} : ${takeTestProvider.connectedDevice!
                          .name}",
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      await takeTestProvider.disconnect(context,isTimerRunning,(bool val){
                        if(val){
                          for (var subscription in takeTestProvider.subscriptions) {
                            subscription.cancel();
                          }
                          setState(() {
                            rrIntervalList.clear();
                            bpmList.clear();
                            timer?.cancel();
                            heartRate = 0;
                            secondsRemaining = (prefModel.selectedDuration!.durationInMinutes!) * 60;
                            isTimerRunning = false;
                          });
                        }
                      });
                    },
                    child: Text(
                      AppLocale.disconnect.getString(context),
                      style: const TextStyle(
                          color: AppColors.scaffoldColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              )),
          const SizedBox(
            height: 15,
          ),
          SizedBox(
            width: screenSize!.width,
            height: screenSize!.width * 0.5,
            child: SfCartesianChart(
              primaryXAxis: const CategoryAxis(),
              primaryYAxis: const NumericAxis(
                interval: 40,
                minimum: 500,
                maximum: 800,
              ),
              series: <CartesianSeries<dynamic, dynamic>>[
                LineSeries<ChartData, double>(
                  dataSource: rrIntervalList
                      .asMap()
                      .entries
                      .map(
                        (entry) =>
                        ChartData(
                            entry.key.toDouble(), entry.value.toDouble()),
                  )
                      .toList(),
                  xValueMapper: (ChartData data, _) => data.x,
                  yValueMapper: (ChartData data, _) => data.y,
                ),
              ],
              zoomPanBehavior: ZoomPanBehavior(
                enablePanning: true,
                enablePinching: true,
              ),
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          Center(
            child: CircularPercentIndicator(
              radius: 100.0,
              lineWidth: 15.0,
              percent: ((prefModel.selectedDuration!.durationInMinutes! * 60 -
                  secondsRemaining) /
                  (prefModel.selectedDuration!.durationInMinutes! * 60))
                  .clamp(0.0, 1.0),
              center: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '${(secondsRemaining ~/ 60).toString().padLeft(
                        2, '0')}:${(secondsRemaining % 60).toString().padLeft(
                        2, '0')}',
                    style: const TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  GestureDetector(
                      onTap: () {
                        if (!isTimerRunning) {
                          Navigator.pushNamed(context, Routes.durationsRoute)
                              .then((value) {
                            setState(() {
                              if (prefModel.selectedDuration != null) {
                                secondsRemaining = (prefModel
                                    .selectedDuration!.durationInMinutes!) *
                                    60;
                              }
                            });
                          });
                        } else {
                          showErrorToast(context,
                              AppLocale.waitTillScan.getString(context));
                        }
                      },
                      child: const Icon(
                        Icons.timer_outlined,
                        color: AppColors.primaryColor,
                      ))
                ],
              ),
              circularStrokeCap: CircularStrokeCap.round,
              progressColor: AppColors.primaryColor,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '${heartRate.toString()} ${AppLocale.bpm.getString(context)}',
            style: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () {
              handleStartButtonClick(context, takeTestProvider);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(12)),
                color: Colors.blue.shade300,
              ),
              child: Text(
                isTimerRunning
                    ? AppLocale.stop.getString(context)
                    : AppLocale.start.getString(context),
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget chooseDurationWidget(BuildContext context,
      TakeTestProvider takeTestProvider) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Container(
          padding: const EdgeInsets.all(10),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            color: AppColors.primaryColor,
          ),
          width: screenSize!.width,
          height: 100,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                  width: screenSize!.width * 0.4,
                  child: Text(
                    AppLocale.chooseDurationMessage.getString(context),
                    style: const TextStyle(color: Colors.white),
                  )),
              const SizedBox(width: 5),
              InkWell(
                onTap: () {
                  Navigator.pushNamed(context, Routes.durationsRoute);
                },
                child: Container(
                    height: 50,
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        color: Colors.white),
                    child: Center(
                      child: Text(
                        AppLocale.chooseDuration.getString(context),
                        style: const TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                            fontWeight: FontWeight.bold),
                      ),
                    )),
              )
            ],
          )),
    );
  }

  Widget scanBluetoothWidget(BuildContext context,
      TakeTestProvider takeTestProvider) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Container(
          padding: const EdgeInsets.all(10),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            color: AppColors.primaryColor,
          ),
          width: screenSize!.width,
          height: 100,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                  width: screenSize!.width * 0.6,
                  child: Text(
                    AppLocale.noConnectedDevice.getString(context),
                    style: const TextStyle(color: Colors.white),
                  )),
              const SizedBox(width: 5),
              InkWell(
                onTap: () {
                  Navigator.pushNamed(context, Routes.bluetoothScanRoute);
                },
                child: Container(
                    width: screenSize!.width * 0.20,
                    height: 50,
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        color: Colors.white),
                    child: Center(
                      child: Text(
                        AppLocale.connect.getString(context),
                        style: const TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                            fontWeight: FontWeight.bold),
                      ),
                    )),
              )
            ],
          )),
    );
  }

  Widget bluetoothOffWarningWidget(BuildContext context,
      TakeTestProvider takeTestProvider) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Container(
          padding: const EdgeInsets.all(10),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            color: AppColors.primaryColor,
          ),
          width: screenSize!.width,
          height: 100,
          child: Center(
            child: Text(
              AppLocale.bluetoothIsOff.getString(context),
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
          )),
    );
  }


  int calculateAge(String dateOfBirthString) {
    DateTime dateOfBirth = DateTime.parse(dateOfBirthString);
    DateTime currentDate = DateTime.now();
    Duration difference = currentDate.difference(dateOfBirth);
    int ageInYears = (difference.inDays / 365).floor();
    return ageInYears;
  }
}

class ChartData {
  final double x;
  final double y;

  ChartData(this.x, this.y);
}

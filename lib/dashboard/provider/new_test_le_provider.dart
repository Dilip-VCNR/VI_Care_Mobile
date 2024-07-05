import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:vicare/dashboard/model/device_response_model.dart';
import 'package:vicare/main.dart';
import 'package:vicare/network/api_calls.dart';
import 'package:vicare/utils/app_buttons.dart';

import '../../database/app_pref.dart';
import '../../utils/app_locale.dart';
import '../model/device_data_response_model.dart';
import '../model/offline_test_model.dart';

class NewTestLeProvider extends ChangeNotifier {
  BluetoothDevice? connectedDevice;
  ApiCalls apiCalls = ApiCalls();
  bool isScanning = false;
  List<ScanResult> scanResults = [];

  Future<void> connectToDevice(
      void Function(bool isConnected) onConnectionResult,
      Device? selectedDevice,
      BuildContext consumerContext) async {
    if (await FlutterBluePlus.adapterState.first == BluetoothAdapterState.on) {
      showLoaderDialog(consumerContext);
      for (var device in await FlutterBluePlus.connectedDevices) {
        await device.disconnect();
      }
      connectedDevice = null;

      bool deviceFound = false;

      try {
        FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));

        BluetoothDevice? device;
        FlutterBluePlus.scanResults.listen((scanResult) async {
          for (ScanResult result in scanResult) {
            if (result.device.remoteId.str ==
                selectedDevice!.deviceKey.toString()) {
              device = result.device;
              deviceFound = true;
              FlutterBluePlus.stopScan();
              await device!.connect(autoConnect: false);
              connectedDevice = device;
              onConnectionResult(true);
              showSuccessToast(
                consumerContext,
                "${AppLocale.connectedTo.getString(consumerContext)}: ${device!.platformName}",
              );
              return;
            }
          }
        });

        // Wait for the scan to complete
        await Future.delayed(const Duration(seconds: 5));

        if (!deviceFound) {
          onConnectionResult(false);
          showErrorToast(
            consumerContext,
            AppLocale.deviceNotInTheRange.getString(consumerContext),
          );
        }
      } catch (e) {
        onConnectionResult(false);
        showErrorToast(
          consumerContext,
          AppLocale.couldNotConnect.getString(consumerContext),
        );
      }
    } else {
      showErrorToast(
        consumerContext,
        AppLocale.bluetoothOffTurn.getString(consumerContext),
      );
    }
  }

  requestDeviceData(
      BuildContext dataContext,
      File payload,
      String? deviceSerialNo,
      int? userAndDeviceId,
      String deviceId,
      int? durationId,
      String? durationName,
      String pId,
      Map<String, Object?> jsonData) async {
    List<ConnectivityResult> connectivityResults =
        (await Connectivity().checkConnectivity()) as List<ConnectivityResult>;
    bool isConnected = connectivityResults.any((result) =>
        result == ConnectivityResult.mobile ||
        result == ConnectivityResult.wifi);
    if (isConnected) {
      // Mobile data or WiFi detected
      DeviceDataResponseModel response = await apiCalls.requestDeviceData(
          context: dataContext,
          details: "abc",
          fileType: "1",
          durationName: durationName,
          deviceSerialNumber: deviceSerialNo!,
          ipAddress: "192.168.0.1",
          userAndDeviceId: userAndDeviceId.toString(),
          subscriberGuid: "3fa85f64-5717-4562-b3fc-2c963f66afa6",
          deviceId: deviceId,
          durationId: durationId,
          userId: prefModel.userData!.id,
          roleId: prefModel.userData!.roleId,
          pId: pId,
          uploadFile: payload,
          jsonData: jsonData);
      Navigator.pop(dataContext);
      if (response.result != null) {
        showSuccessToast(
            dataContext, AppLocale.testSuccessSendHRV.getString(dataContext));
      } else {
        showErrorToast(dataContext, response.message!);
        final String jsonString = json.encode(jsonData);
        OfflineTestModel testDetails =
            OfflineTestModel.fromJson(json.decode(jsonString));
        prefModel.offlineSavedTests!.add(testDetails);
        await AppPref.setPref(prefModel);
        showSuccessToast(
            dataContext, AppLocale.testSavedOffline.getString(dataContext));
        // Navigator.pop(dataContext);
      }
    } else {
      final String jsonString = json.encode(jsonData);
      OfflineTestModel testDetails =
          OfflineTestModel.fromJson(json.decode(jsonString));
      prefModel.offlineSavedTests!.add(testDetails);
      await AppPref.setPref(prefModel);
      Navigator.pop(dataContext);
      showErrorToast(
          dataContext, AppLocale.testSavedOffline.getString(dataContext));
    }
  }
}

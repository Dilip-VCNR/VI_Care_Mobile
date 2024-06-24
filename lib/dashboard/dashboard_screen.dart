import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:vicare/dashboard/model/device_response_model.dart';
import 'package:vicare/dashboard/model/duration_response_model.dart';
import 'package:vicare/dashboard/provider/devices_provider.dart';
import 'package:vicare/dashboard/ui/all_reports_screen.dart';
import 'package:vicare/dashboard/ui/home_screen.dart';
import 'package:vicare/dashboard/ui/manage_patients_screen.dart';
import 'package:vicare/dashboard/ui/profile_screen.dart';
import 'package:vicare/utils/app_buttons.dart';

import '../main.dart';
import '../utils/app_colors.dart';
import '../utils/app_locale.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int selectedItemPosition = 0;

  List screens = [];

  @override
  void initState() {
    super.initState();
    screens = [
      HomeScreen(changeScreen: changeScreen),
      const ReportScreen(),
      const ManagePatientsScreen(),
      const ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (selectedItemPosition != 0) {
          changeScreen(0);
          return false;
        } else {
          return true;
        }
      },
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          body: screens[selectedItemPosition],
          // floatingActionButton: _buildFloatingActionButton(),
          // floatingActionButtonLocation:
          //     FloatingActionButtonLocation.centerDocked,
          bottomNavigationBar: _buildBottomNavigationBar(),
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(8),
      child: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent, // Set splash color to transparent
        ),
        child: BottomNavigationBar(
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: AppColors.primaryColor,
          unselectedItemColor: Colors.black,
          showUnselectedLabels: true,
          showSelectedLabels: true,
          currentIndex: selectedItemPosition,
          onTap: (index) {
            if (index == 2) {
              // If "Take Test" is tapped, call changeScreen with the index directly
              changeScreen(index);
            } else {
              // For other tabs, set the selectedItemPosition
              setState(() => selectedItemPosition = index);
            }
          },
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home),
              label: AppLocale.home.getString(context),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.bar_chart),
              label: AppLocale.reports.getString(context),
            ),
            BottomNavigationBarItem(
              icon:  const Icon(Icons.group),
              label: prefModel.userData!.roleId == 2
                  ? AppLocale.members.getString(context)
                  : prefModel.userData!.roleId == 3
                      ? AppLocale.patients.getString(context)
                      : prefModel.userData!.roleId == 4
                          ? AppLocale.player.getString(context)
                          : "",
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person),
              label: AppLocale.profile.getString(context),
            ),
          ],
          selectedLabelStyle: const TextStyle(fontSize: 10),
          unselectedLabelStyle: const TextStyle(fontSize: 10),
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return Consumer(
      builder:
          (BuildContext context, DeviceProvider deviceProvider, Widget? child) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            width: 50.0,
            height: 50.0,
            child: FloatingActionButton(
              onPressed: () async {
                var bluetoothConnectStatus =
                    await Permission.bluetoothConnect.request();
                var bluetoothScanStatus =
                    await Permission.bluetoothScan.request();
                if (bluetoothConnectStatus == PermissionStatus.granted &&
                    bluetoothScanStatus == PermissionStatus.granted) {
                  showLoaderDialog(context);
                  DeviceResponseModel myDevices =
                      await deviceProvider.getMyDevices(context);
                  DurationResponseModel myDurations =
                      await deviceProvider.getAllDuration(context);
                  Navigator.pop(context);
                  if (myDevices.result != null &&
                      myDevices.result!.isNotEmpty) {
                    showTestFormBottomSheet(
                        context, myDevices, myDurations, null, null);
                  } else {
                    showErrorToast(
                        context, AppLocale.deviceNotAdded.getString(context));
                  }
                }
              },
              backgroundColor: AppColors.primaryColor,
              child: const Icon(Icons.monitor_heart_outlined,
                  color: Colors.white, size: 28),
            ),
          ),
        );
      },
    );
  }

  void changeScreen(int index) {
    setState(() {
      selectedItemPosition = index;
    });
  }
}

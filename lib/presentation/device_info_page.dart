import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:timeaccess_qrcode/main.dart';
import 'package:timeaccess_qrcode/utils/extensions.dart';
import 'package:timeaccess_qrcode/utils/helper.dart';

class DeviceInfoPage extends StatefulWidget {
  const DeviceInfoPage({super.key});

  @override
  State<DeviceInfoPage> createState() => _DeviceInfoPageState();
}

class _DeviceInfoPageState extends State<DeviceInfoPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Container(
          constraints: const BoxConstraints.expand(),
          child: GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(FocusNode());
            },
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 30.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SelectableText(
                    "Version: $version",
                    style: TextStyle(fontSize: 15.sp),
                  ),
                  10.height,
                  SelectableText(
                    "Mac Address: $macAddress",
                    style: TextStyle(fontSize: 15.sp),
                  ),
                  10.height,
                  SelectableText(
                    "Device ID: $deviceId",
                    style: TextStyle(fontSize: 15.sp),
                  ),
                  10.height,
                  SelectableText(
                    "Device Brand: $deviceBrand",
                    style: TextStyle(fontSize: 15.sp),
                  ),
                  10.height,
                  SelectableText(
                    "Device Model: $deviceInfoModel",
                    style: TextStyle(fontSize: 15.sp),
                  ),
                  10.height,
                  SelectableText(
                    "Device Name: $deviceInfoDeviceName",
                    style: TextStyle(fontSize: 15.sp),
                  ),
                  10.height,
                  SelectableText(
                    "OS Name: $deviceInfoOSName",
                    style: TextStyle(fontSize: 15.sp),
                  ),
                  10.height,
                  SelectableText(
                    "OS Version: $deviceInfoOSVersion",
                    style: TextStyle(fontSize: 15.sp),
                  ),
                  10.height,
                  SelectableText(
                    "Device Info Platform: $deviceInfoPlatform",
                    style: TextStyle(fontSize: 15.sp),
                  ),
                  10.height,
                  SelectableText(
                    "Device Code: ${deviceCode.toUpperCase()}",
                    style: TextStyle(fontSize: 15.sp),
                  ),
                  40.height,
                  Align(
                    alignment: Alignment.center,
                    child: ElevatedButton(
                      onPressed: () {
                        Helper.startKioskMode();
                        Helper.hideStatusBar();
                      },
                      child: Text(
                        "Start Kiosk Mode",
                        style: TextStyle(fontSize: 15.sp),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: ElevatedButton(
                      onPressed: () {
                        Helper.stopKioskMode();
                        Helper.hideStatusBar();
                      },
                      child: Text(
                        "Stop Kiosk Mode",
                        style: TextStyle(fontSize: 15.sp),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:timeaccess_qrcode/main.dart';
import 'package:timeaccess_qrcode/utils/constants.dart';

class Helper {
  static bool isSignIn() {
    try {
      String cookie = userSettingBox.get(Constants.sharePreferencesKey) ?? "";
      if (cookie == "") {
        clearToken();
        return false;
      }
      return true;
    } catch (err) {
      if (kDebugMode) {
        print("Error: $err");
      }
    }
    clearToken();
    return false;
  }

  static clearToken() {
    try {
      userSettingBox.put(Constants.sharePreferencesKey, "");
      return true;
    } catch (err) {
      if (kDebugMode) {
        print("Error: $err");
      }
    }
    return false;
  }

  static String formatDate(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd').format(dateTime);
  }

  static String formatTime(DateTime dateTime) {
    return DateFormat('HH:mm:ss').format(dateTime);
  }

  static String presentTimeFormat(String date, String time, String name) {
    DateTime datetime = DateTime.parse("$date $time");
    return "${DateFormat('E dd MMM yyyy').format(datetime)} $name \n${DateFormat('hh:mm:ss a').format(datetime)}";
  }

  static Future sleep(int millisecond) {
    return Future.delayed(Duration(milliseconds: millisecond));
  }

  static void showSnakeBar(BuildContext context, String message, bool success) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        dismissDirection: DismissDirection.down,
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
        backgroundColor: success ? Colors.green : Colors.red,
        elevation: 3,
        margin: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
        duration: const Duration(seconds: 5),
      ),
    );
  }

  static void showToast(String msg, bool success) {
    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: success ? Colors.green : Colors.red,
      textColor: Colors.white,
      fontSize: 12,
    );
  }


  static getName(String employeeName) {
    List<String> name = employeeName.split(", ");
    return name.reversed.toList().join(" ");
  }

  static finish(BuildContext context, [Object? result]) {
    if (Navigator.canPop(context)) Navigator.pop(context, result);
  }

  static const platform = MethodChannel('kioskModeLocked');

  static startKioskMode() async {
    await platform.invokeMethod('startKioskMode');
  }

  static stopKioskMode() async {
    await platform.invokeMethod('stopKioskMode');
  }

  static hideStatusBar() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  }
}

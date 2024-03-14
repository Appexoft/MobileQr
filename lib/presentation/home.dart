import 'dart:async';
import 'dart:convert';

import 'package:cron/cron.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:timeaccess_qrcode/hive/employee_hive.dart';
import 'package:timeaccess_qrcode/hive/present_hive.dart';
import 'package:timeaccess_qrcode/main.dart';
import 'package:timeaccess_qrcode/presentation/detect_screen.dart';
import 'package:timeaccess_qrcode/presentation/show_list.dart';
import 'package:timeaccess_qrcode/utils/constants.dart';
import 'package:timeaccess_qrcode/utils/enums.dart';
import 'package:timeaccess_qrcode/utils/extensions.dart';
import 'package:timeaccess_qrcode/utils/helper.dart';
import 'package:timeaccess_qrcode/utils/hive_helper.dart';
import 'package:timeaccess_qrcode/utils/http_helper.dart';
import 'package:timeaccess_qrcode/value_notifier/network_notifier.dart';
import 'package:timeaccess_qrcode/widgets/app_info.dart';
import 'package:timeaccess_qrcode/widgets/clock_widget.dart';
import 'package:timeaccess_qrcode/widgets/network_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  HomeScreenState createState() => HomeScreenState();
}

class Attendance {
  late String? employeeNo;
  late String? date;
  late String? clockedIn;
  late String? clockedOut;
  late String? workedHours;

  Attendance({
    required this.employeeNo,
    required this.date,
    required this.clockedIn,
    required this.clockedOut,
    required this.workedHours,
  });

  factory Attendance.fromJson(Map<String, String> dateUser) {
    return Attendance(
      employeeNo: dateUser['employee_no'],
      date: dateUser['date'],
      clockedIn: dateUser['clocked_in'] as String,
      clockedOut: dateUser['clocked_out'],
      workedHours: dateUser['worked_hours'],
    );
  }
}

enum ActionType {
  clockedId,
  clockedOut,
}

class HomeScreenState extends State<HomeScreen> {
  bool sending = false;
  bool syncing = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    _initCron();
  }

  _initCron() {
    final cron = Cron();
    cron.schedule(Schedule.parse("* * */2 * *"), () async {
      // check network status
      bool network = Provider.of<NetworkNotifier>(context, listen: false).connected;
      if (network) {
        if (syncing || syncInProgress) return;
        syncing = true;
        syncInProgress = true;
        // 1. sync employees data
        int employeeSyncAt = userSettingBox.get("employee_at", defaultValue: 0);
        if (employeeSyncAt < DateTime.now().millisecondsSinceEpoch) {
          // start sync employee
          int currentPage = 1;
          int totalPage = 1;
          while (currentPage <= totalPage) {
            String url = "${Constants.URL}/devices/employees?page=$currentPage";
            var response = await HttpHelper.authGet(url, {});
            if (response != null) {
              var results = json.decode(response.body);
              var data = results["data"];
              totalPage = data["totalPages"];
              currentPage++;
              for (var item in data["employees"]) {
                EmployeeHive newEmployee = EmployeeHive(item["employee_no"], item["name_report"]);
                HiveHelper.insertEmployee(newEmployee);
              }
              if (currentPage > totalPage) {
                userSettingBox.put("employee_at", DateTime.now().add(Constants.syncLimit).millisecondsSinceEpoch);
              }
            } else {
              break;
            }
          }
        }
        // 2. sync attendance data
        List<PresentHive> data = HiveHelper.getData();
        for (int i = 0; i < data.length; i++) {
          PresentHive item = data[i];
          if (item.type == ClockStatus.CLOCK_IN.value) {
            // Clock In
            var params = {
              'employee_no': item.employee_no,
              'date': item.date,
              'clocked_in': item.time,
            };
            String url = "${Constants.URL}/clock-in";
            var response = await HttpHelper.authPost(url, params, {}, false, force: true);
            if (response != null) {
              if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 400) {
                HiveHelper.deleteData(item.id);
              }
            }
            await Helper.sleep(200); // Sleep 200ms
          } else {
            // Clock Out
            var params = {
              'employee_no': item.employee_no,
              'date': item.date,
              'clocked_out': item.time,
            };
            String url = "${Constants.URL}/clock-out";
            var response = await HttpHelper.authPost(url, params, {}, false, force: true);
            if (response != null) {
              if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 400) {
                HiveHelper.deleteData(item.id);
              }
            }
            await Helper.sleep(200); // Sleep 200ms
          }
        }
        syncing = false;
        syncInProgress = false;
      }
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  Future<void> scanQR(ActionType action) async {
    Navigator.of(context)
        .push(
      PageTransition(
        child: DetectScreen(actionType: action),
        curve: Curves.easeIn,
        type: PageTransitionType.rightToLeft,
      ),
    )
        .then((value) {
      if (value != null) {
        if (mounted) {
          if (action == ActionType.clockedId) {
            _clockIn(value);
          } else {
            _clockOut(value);
          }
        }
      }
    });
  }

  Future<void> _clockIn(String employeeNo) async {
    if (sending) return;
    setState(() {
      sending = true;
    });
    String date = Helper.formatDate(DateTime.now());
    String time = Helper.formatTime(DateTime.now());
    EmployeeHive? employee = HiveHelper.getEmployeeByNo(employeeNo);
    if (employee == null) {
      _errorHandler("Unknown Employee");
      return;
    }
    // daily check
    PresentHive? exist = HiveHelper.existPresentCheck(
      employeeNo,
      date,
      ClockStatus.CLOCK_IN.value,
    );
    if (exist != null) {
      _errorHandler("Hi ${Helper.getName(employee.employee_name)}, your clock-in is already registered. Thanks you");
      return;
    } else {
      // add new record to hive
      int id = DateTime.now().millisecondsSinceEpoch;
      PresentHive newRecord = PresentHive(
        id,
        employeeNo,
        employee.employee_name,
        date,
        time,
        ClockStatus.CLOCK_IN.value,
        false,
      );
      await presentBox.add(newRecord);
      bool network = Provider.of<NetworkNotifier>(context, listen: false).connected;
      if (network) {
        var params = {
          'employee_no': employeeNo,
          'date': date,
          'clocked_in': time,
        };
        String url = "${Constants.URL}/clock-in";
        var response = await HttpHelper.authPost(url, params, {}, false, force: true);
        if (response != null) {
          if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 400) {
            HiveHelper.deleteData(id);
          }
        }
      }
      setState(() {
        sending = false;
      });
      if (mounted) {
        Helper.showSnakeBar(context, "Welcome ${Helper.getName(employee.employee_name)}", true);
      }
    }
  }

  Future<void> _clockOut(String employeeNo) async {
    if (sending) return;
    setState(() {
      sending = true;
    });
    String date = Helper.formatDate(DateTime.now());
    String time = Helper.formatTime(DateTime.now());
    // check registered employee
    EmployeeHive? employee = HiveHelper.getEmployeeByNo(employeeNo);
    if (employee == null) {
      _errorHandler("Unknown Employee");
      return;
    }
    // daily check
    PresentHive? exist = HiveHelper.existPresentCheck(
      employeeNo,
      date,
      ClockStatus.CLOCK_OUT.value,
    );
    if (exist != null) {
      _errorHandler("Hi ${Helper.getName(employee.employee_name)}, your clock-out is already registered. Thanks you");
      return;
    } else {
      // check clock-in check
      PresentHive? clockInExist = HiveHelper.existPresentCheck(employeeNo, date, ClockStatus.CLOCK_IN.value);
      if (clockInExist == null) {
        _errorHandler("Attendance does not exist");
        return;
      }
      int id = DateTime.now().millisecondsSinceEpoch;
      // add new record to hive
      PresentHive newRecord = PresentHive(
        id,
        employeeNo,
        employee.employee_name,
        date,
        time,
        ClockStatus.CLOCK_OUT.value,
        false,
      );
      await presentBox.add(newRecord);
      bool network = Provider.of<NetworkNotifier>(context, listen: false).connected;
      if (network) {
        var params = {
          'employee_no': employeeNo,
          'date': date,
          'clocked_out': time,
        };
        String url = "${Constants.URL}/clock-out";
        var response = await HttpHelper.authPost(url, params, {}, false, force: true);
        if (response != null) {
          if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 400) {
            HiveHelper.deleteData(id);
          }
        }
      }
      setState(() {
        sending = false;
      });
      if (mounted) {
        Helper.showSnakeBar(context, "Good bye ${Helper.getName(employee.employee_name)}", true);
      }
    }
  }

  _errorHandler(String error) {
    setState(() {
      sending = false;
    });
    Helper.showSnakeBar(context, error, false);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        body: SafeArea(
          child: Container(
            constraints: const BoxConstraints.expand(),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Column(
                    children: <Widget>[
                      40.height,
                      Image.asset("assets/logo.png", fit: BoxFit.contain, height: 84),
                      10.height,
                      const Text(
                        "PNG Time Access",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.lightBlue,
                        ),
                      ),
                      20.height,
                      const Text("Papua New Guinea National", style: TextStyle(fontSize: 18)),
                      const Text(
                        "Public Service Attendance System",
                        style: TextStyle(fontSize: 18),
                      ),
                      25.height,
                      const Text(
                        "Scan your QR code to register your daily attendance",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      25.height,
                      const ClockWidget(),
                      Container(
                        margin: const EdgeInsets.all(10.0),
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(40),
                          ),
                          onPressed: sending
                              ? null
                              : () {
                                  scanQR(ActionType.clockedId);
                                },
                          child: sending
                              ? const SpinKitDualRing(
                                  color: Colors.white,
                                  size: 20,
                                  lineWidth: 3,
                                )
                              : const Text(
                                  "Clock In",
                                  style: TextStyle(
                                    fontSize: 25,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.all(10.0),
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(40),
                          ),
                          onPressed: sending
                              ? null
                              : () {
                                  scanQR(ActionType.clockedOut);
                                },
                          child: sending
                              ? const SpinKitDualRing(color: Colors.white, size: 20, lineWidth: 3)
                              : const Text(
                                  "Clock Out",
                                  style: TextStyle(
                                    fontSize: 25,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      10.height,
                      Expanded(child: Container()),
                      AppInfo(parent: context),
                    ],
                  ),
                ),
                Positioned(left: 10.w, top: 10.w, child: const NetworkWidget()),
                Positioned(
                  right: 0,
                  top: 0,
                  child: IconButton(
                    style: IconButton.styleFrom(
                      padding: EdgeInsets.zero,
                    ),
                    splashRadius: 20.w,
                    onPressed: () {
                      const ShowList().launch(context, isNewTask: false);
                    },
                    icon: Icon(Icons.list_alt, size: 18.sp),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

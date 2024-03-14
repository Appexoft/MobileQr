import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_animation_progress_bar/flutter_animation_progress_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:sprintf/sprintf.dart';
import 'package:timeaccess_qrcode/hive/employee_hive.dart';
import 'package:timeaccess_qrcode/main.dart';
import 'package:timeaccess_qrcode/utils/constants.dart';
import 'package:timeaccess_qrcode/utils/extensions.dart';
import 'package:timeaccess_qrcode/utils/hive_helper.dart';
import 'package:timeaccess_qrcode/utils/http_helper.dart';

class SyncWorkOverlay extends ModalRoute<void> {
  final VoidCallback onSuccess;
  final VoidCallback onFailed;

  SyncWorkOverlay({required this.onSuccess, required this.onFailed});

  @override
  Color? get barrierColor => Colors.black.withOpacity(0.5);

  @override
  bool get barrierDismissible => true;

  @override
  String? get barrierLabel => "";

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    return Material(
      type: MaterialType.transparency,
      child: SafeArea(
        child: Center(
          child: SizedBox(
            width: 0.7.sw,
            child: Center(
              child: SyncWidget(
                onSuccess: () {
                  Navigator.pop(context);
                  onSuccess();
                },
                onFailed: () {
                  Navigator.pop(context);
                  onFailed();
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  bool get maintainState => true;

  @override
  bool get opaque => false;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 200);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    return FadeTransition(
      opacity: animation,
      child: ScaleTransition(
        scale: animation,
        child: child,
      ),
    );
  }
}

class SyncWidget extends StatefulWidget {
  final VoidCallback onSuccess;
  final VoidCallback onFailed;

  const SyncWidget({
    super.key,
    required this.onSuccess,
    required this.onFailed,
  });

  @override
  State<SyncWidget> createState() => _SyncWidgetState();
}

class _SyncWidgetState extends State<SyncWidget> {
  int _currentProgress = 0;
  int _maxProgress = 0;

  late Timer _timerPeriodic;

  int _employeeInfoSyncTryCount = 3;

  int _stateEmployee = 1; // 1: calculating, 2: show progress, 3: complete

  String _employeePercent = "";

  @override
  void initState() {
    super.initState();
    _timerPeriodic = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (_maxProgress > _currentProgress) {
        if (mounted) {
          setState(() {
            _currentProgress = _currentProgress + 20;
          });
          if (_currentProgress >= 100) {
            _timerPeriodic.cancel();
            Timer(const Duration(seconds: 2), () {
              widget.onSuccess();
            });
          }
        }
      }
    });
    _startSyncWork();
  }

  @override
  void dispose() {
    _timerPeriodic.cancel();
    super.dispose();
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  _reportProgress(int addProgress) {
    _maxProgress = _maxProgress + addProgress;
  }

  _startSyncWork() {
    _startEmployeeInfoSyncWork();
  }

  _startEmployeeInfoSyncWork() {
    _employeeInfoSyncWork().then((value) {
      if (mounted) {
        if (value) {
          _reportProgress(100);
        } else {
          _employeeInfoSyncTryCount--;
          if (_employeeInfoSyncTryCount == 0) {
            _timerPeriodic.cancel();
            Timer(const Duration(seconds: 1), () {
              widget.onFailed();
            });
          } else {
            Timer(const Duration(seconds: 2), () {
              _startEmployeeInfoSyncWork();
            });
          }
        }
      }
    });
  }

  Widget _employeeStateWidget() {
    Widget result = Container();
    switch (_stateEmployee) {
      case 1:
        result = SpinKitThreeBounce(size: 10.w, color: Colors.white, duration: const Duration(milliseconds: 1500));
        break;
      case 2:
        result = Text(_employeePercent, style: const TextStyle(color: Colors.white));
        break;
      case 3:
        result = Icon(Icons.check, size: 15.sp, color: Colors.green);
        break;
    }
    return result;
  }

  Future<bool> _employeeInfoSyncWork() async {
    try {
      int currentPage = 1;
      int totalPage = 1;
      while (currentPage <= totalPage) {
        String url = "${Constants.URL}/employees?page=$currentPage";
        var response = await HttpHelper.authGet(url, {});
        if (mounted) {
          if (response != null) {
            var results = json.decode(response.body);
            var data = results["data"];
            totalPage = data["totalPages"];
            if (_stateEmployee == 1) {
              _stateEmployee = 2;
            }
            setState(() {
              _employeePercent = sprintf("%d%", [((currentPage / totalPage) * 100).round()]);
            });
            currentPage++;
            for (var item in data["employees"]) {
              EmployeeHive newEmployee = EmployeeHive(item["employee_no"], item["name_report"]);
              HiveHelper.insertEmployee(newEmployee);
            }
          } else {
            return false;
          }
          if (currentPage > totalPage) {
            userSettingBox.put("employee_at", DateTime.now().add(Constants.syncLimit).millisecondsSinceEpoch);
            userSettingBox.put(Constants.synced_employees, true);
            Timer(const Duration(seconds: 1), () {
              if (mounted) {
                setState(() {
                  _stateEmployee = 3;
                });
              }
            });
          }
        }
      }
    } catch (err) {
      return false;
    }
    return true;
  }

  Future<bool> _backHandler() async {
    widget.onFailed();
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _backHandler,
      child: Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 42, 42, 42),
          borderRadius: BorderRadius.circular(10.w),
        ),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 15.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Initializing...",
              style: TextStyle(color: Colors.white, fontSize: 15.sp),
            ),
            5.height,
            FAProgressBar(
              currentValue: _currentProgress.toDouble(),
              formatValueFixed: 0,
              maxValue: 100,
              displayText: "%",
              animatedDuration: const Duration(milliseconds: 500),
              direction: Axis.horizontal,
              borderRadius: BorderRadius.circular(10.w),
              backgroundColor: Colors.white,
              size: 30.h,
              progressColor: Colors.blue,
            ),
            10.height,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Employee Info", style: TextStyle(color: Colors.white)),
                _employeeStateWidget(),
              ],
            )
          ],
        ),
      ),
    );
  }
}

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:provider/provider.dart';
import 'package:timeaccess_qrcode/hive/employee_hive.dart';
import 'package:timeaccess_qrcode/hive/present_hive.dart';
import 'package:timeaccess_qrcode/main.dart';
import 'package:timeaccess_qrcode/utils/constants.dart';
import 'package:timeaccess_qrcode/utils/enums.dart';
import 'package:timeaccess_qrcode/utils/helper.dart';
import 'package:timeaccess_qrcode/utils/hive_helper.dart';
import 'package:timeaccess_qrcode/utils/http_helper.dart';
import 'package:timeaccess_qrcode/value_notifier/network_notifier.dart';

class ShowList extends StatefulWidget {
  const ShowList({super.key});

  @override
  State<ShowList> createState() => _ShowListState();
}

class _ShowListState extends State<ShowList> {
  bool syncing = false;

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  _syncWork() async {
    bool network = Provider.of<NetworkNotifier>(context, listen: false).connected;
    if (network) {
      if (syncing || syncInProgress) {
        Helper.showSnakeBar(context, "Sync work in progress", false);
        return;
      }
      setState(() {
        syncing = true;
      });
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
      if (data.isNotEmpty) {
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
      } else {
        if (mounted) {
          Helper.showSnakeBar(context, "There is no data!", true);
        }
      }
      setState(() {
        syncing = false;
      });
      syncInProgress = false;
      if (mounted) {
        Helper.showSnakeBar(context, "Attendance records successfully uploaded into the PNG Time Access WoG Attendance System", true);
      }
    } else {
      Helper.showSnakeBar(context, "No internet!", false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: presentBox.listenable(),
      builder: (BuildContext context, Box box, Widget? child) {
        List<PresentHive> data = HiveHelper.getDateForShow();
        return Scaffold(
          appBar: AppBar(
            actions: [
              Center(
                child: IconButton(
                  onPressed: syncing
                      ? null
                      : () {
                          _syncWork();
                        },
                  icon: syncing
                      ? SpinKitDualRing(
                          color: Colors.white,
                          size: 20.sp,
                          lineWidth: 2.h,
                        )
                      : const Icon(Icons.upload),
                ),
              )
            ],
          ),
          body: SafeArea(
            child: data.isEmpty
                ? Container(
                    constraints: const BoxConstraints.expand(),
                    child: const Center(
                      child: Text(
                        "No Data",
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: data.length,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    reverse: false,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(
                          Helper.presentTimeFormat(data[index].date, data[index].time, Helper.getName(data[index].name_report)),
                        ),
                        leading: Text(data[index].id.toString()),
                        trailing: Container(
                          decoration: BoxDecoration(
                            color: data[index].type == ClockStatus.CLOCK_IN.value ? Colors.green : Colors.red,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: const [
                              BoxShadow(color: Colors.grey, offset: Offset(0, 4), blurRadius: 4),
                            ],
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          child: Text(
                            data[index].type == ClockStatus.CLOCK_IN.value ? ClockStatus.CLOCK_IN.text : ClockStatus.CLOCK_OUT.text,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        );
      },
    );
  }
}

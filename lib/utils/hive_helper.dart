import 'package:collection/collection.dart';
import 'package:timeaccess_qrcode/hive/employee_hive.dart';
import 'package:timeaccess_qrcode/hive/present_hive.dart';
import 'package:timeaccess_qrcode/main.dart';

class HiveHelper {
  static List<PresentHive> getData() {
    List<dynamic> data = presentBox.values.where((element) => !element.uploaded).toList();
    List<PresentHive> result = [];
    data.map((e) {
      if (e.runtimeType == PresentHive) {
        result.add(e);
      }
    }).toList();
    return result;
  }

  static List<PresentHive> getDateForShow() {
    List<dynamic> data = presentBox.values.where((element) => !element.uploaded).toList();
    List<PresentHive> result = [];
    data.map((e) {
      if (e.runtimeType == PresentHive) {
        result.add(e);
      }
    }).toList();
    return result.reversed.toList();
  }

  static deleteData(int id) {
    int index = presentBox.values.toList().indexWhere((element) => element.id == id);
    if (index != -1) {
      PresentHive hive = presentBox.getAt(index);
      hive.uploaded = true;
      presentBox.putAt(index, hive);
    }
  }

  static PresentHive? existPresentCheck(String employeeNo, String date, int type) {
    PresentHive? hive = presentBox.values.firstWhereOrNull((element) => element.employee_no == employeeNo && element.date == date && element.type == type);
    return hive;
  }

  static void insertEmployee(EmployeeHive employee) {
    // check exist
    int index = employeeBox.values.toList().indexWhere((element) => element.employee_no == employee.employee_no);
    if (index != -1) {
      // exist
      employeeBox.deleteAt(index);
      employeeBox.add(employee);
    } else {
      // new employee
      employeeBox.add(employee);
    }
  }

  static EmployeeHive? getEmployeeByNo(String employeeNo) {
    EmployeeHive? hive = employeeBox.values.firstWhereOrNull((element) => element.employee_no == employeeNo);
    return hive;
  }
}

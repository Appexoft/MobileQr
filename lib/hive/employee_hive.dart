// ignore_for_file: non_constant_identifier_names

import 'package:hive/hive.dart';

part 'employee_hive.g.dart';

@HiveType(typeId: 2)
class EmployeeHive extends HiveObject {
  @HiveField(0)
  late String employee_no;
  @HiveField(1)
  late String employee_name;

  EmployeeHive(this.employee_no, this.employee_name);
}

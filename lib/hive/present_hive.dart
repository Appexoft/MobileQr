// ignore_for_file: non_constant_identifier_names

import 'package:hive/hive.dart';

part 'present_hive.g.dart';

@HiveType(typeId: 1)
class PresentHive extends HiveObject {
  @HiveField(0)
  late int id;
  @HiveField(1)
  late String employee_no;
  @HiveField(2)
  late String name_report;
  @HiveField(3)
  late String date;
  @HiveField(4)
  late String time;
  @HiveField(5)
  late int type; // 0: clock in 1: clock out
  @HiveField(6)
  late bool uploaded;

  PresentHive(this.id, this.employee_no, this.name_report, this.date, this.time, this.type, this.uploaded);
}

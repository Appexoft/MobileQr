// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'present_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PresentHiveAdapter extends TypeAdapter<PresentHive> {
  @override
  final int typeId = 1;

  @override
  PresentHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PresentHive(
      fields[0] as int,
      fields[1] as String,
      fields[2] as String,
      fields[3] as String,
      fields[4] as String,
      fields[5] as int,
      fields[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, PresentHive obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.employee_no)
      ..writeByte(2)
      ..write(obj.name_report)
      ..writeByte(3)
      ..write(obj.date)
      ..writeByte(4)
      ..write(obj.time)
      ..writeByte(5)
      ..write(obj.type)
      ..writeByte(6)
      ..write(obj.uploaded);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PresentHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

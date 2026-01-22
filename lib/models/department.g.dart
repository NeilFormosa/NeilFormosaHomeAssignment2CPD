// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'department.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DepartmentAdapter extends TypeAdapter<Department> {
  @override
  final int typeId = 0;

  @override
  Department read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Department(
      name: fields[0] as String,
      description: fields[1] as String,
      latitude: fields[2] as double?,
      longitude: fields[3] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, Department obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.description)
      ..writeByte(2)
      ..write(obj.latitude)
      ..writeByte(3)
      ..write(obj.longitude);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DepartmentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

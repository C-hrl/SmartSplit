// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StudentProjectAdapter extends TypeAdapter<StudentProject> {
  @override
  final int typeId = 2;

  @override
  StudentProject read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StudentProject(
      fields[0] as String,
      fields[1] as double,
      fields[2] as bool,
      fields[3] as bool,
      fields[4] as int,
      fields[5] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, StudentProject obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.gradePoint)
      ..writeByte(2)
      ..write(obj.registered)
      ..writeByte(3)
      ..write(obj.ongoing)
      ..writeByte(4)
      ..write(obj.projectGroupID)
      ..writeByte(5)
      ..write(obj.absent);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StudentProjectAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

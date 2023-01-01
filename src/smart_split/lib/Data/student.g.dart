// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'student.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StudentAdapter extends TypeAdapter<Student> {
  @override
  final int typeId = 1;

  @override
  Student read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Student(
      fields[0] as String,
      fields[1] as String,
      fields[2] as String,
      fields[3] as String,
      (fields[4] as List).cast<StudentProject>(),
      fields[5] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Student obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.surname)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.mailID)
      ..writeByte(3)
      ..write(obj.group)
      ..writeByte(4)
      ..write(obj.projects)
      ..writeByte(5)
      ..write(obj.nbProjectsMissed);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StudentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

import 'package:hive/hive.dart';
import 'package:smart_split/Data/student.dart';

part 'group.g.dart';

@HiveType(typeId: 0)

/// Hive object used to store groups
class Group extends HiveObject {
  @HiveField(0)
  final String name;
  @HiveField(1)
  List<Student> students;

  /// Initialize a group named [name] and with a list of Student objects named [students]
  Group(this.name, this.students);

  /// Adds a [student] in the group
  void addStudent(Student student) {
    students.add(student);
  }
}

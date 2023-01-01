import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';

part 'project.g.dart';

@HiveType(typeId: 2)

/// Hive object used to store a project for a student
class StudentProject extends HiveObject {
  @HiveField(0)
  final String name;
  @HiveField(1)
  double gradePoint;
  @HiveField(2)
  bool registered;
  @HiveField(3)
  bool ongoing;
  @HiveField(4)
  int projectGroupID;
  @HiveField(5)
  bool absent;

  /// Initialize a project for the student named [name] (by default, set [gradePoint] to 0, [participation] is to true, [ongoing] is to true and [projectGroupID] to -1])
  StudentProject(this.name, this.gradePoint, this.registered, this.ongoing,
      this.projectGroupID, this.absent) {
    assert(gradePoint > -1 && gradePoint <= 20, "Invalid grades");
  }

  ///Sets the student's grade for the project to [grades] (can't be below 0 or above 20)
  void setProjectGrades(double grades) {
    if (grades < 0) {
      grades = 0;
    } else if (grades > 20) {
      grades = 20;
    }
    gradePoint = grades;
  }

  ///Sets the student participation/register as true or false ()
  void setRegistration(bool boolean, String debugMessage) {
    registered = boolean;
    //logging messages
    debugPrint("$name was set to $boolean with message $debugMessage");
  }
}

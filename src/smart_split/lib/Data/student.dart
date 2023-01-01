import 'package:hive/hive.dart';
import 'package:smart_split/Data/project.dart';

part 'student.g.dart';

@HiveType(typeId: 1)

///Object used to store students and their data
class Student extends HiveObject {
  @HiveField(0)
  String surname;
  @HiveField(1)
  String name;
  @HiveField(2)
  String mailID;
  @HiveField(3)
  String group;
  @HiveField(4)
  List<StudentProject> projects;
  @HiveField(5)
  int nbProjectsMissed;

  /// Constructor to create a new [Student] object
  Student(this.surname, this.name, this.mailID, this.group, this.projects,
      this.nbProjectsMissed);

  //recalculates how many times a student has not participated to a project/work session
  void recalcProjectsMissed() {
    nbProjectsMissed = 0;
    for (StudentProject project in projects) {
      if (project.absent == true ||
          (project.registered == false && project.ongoing == false)) {
        nbProjectsMissed++;
      }
    }
  }
}

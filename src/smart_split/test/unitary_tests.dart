import 'package:hive/hive.dart';
import 'package:smart_split/Data/group.dart';
import 'package:smart_split/Data/project.dart';
import 'package:smart_split/Data/student.dart';
import 'package:smart_split/Widgets/File%20Manager/file_manager.dart';
import 'package:test/test.dart';

void main() {
  group('Basic Database Tests', () {
    test('Init DB', () async {
      var path = await FileUtils().localPath;
      Hive.init(path);
      Hive.registerAdapter(GroupAdapter());
      Hive.registerAdapter(StudentAdapter());
      Hive.registerAdapter(StudentProjectAdapter());
    });

    test('Open DB', () async {
      await Hive.openBox('groupBox');
    });

    test('clearing DB', () async {
      Box<Group> database = await Hive.openBox('groupBox');
      database.clear();
      //checks if database is empty
      expect(database.isEmpty, true);
    });

    test('adding group to DB', () async {
      Box<Group> database = await Hive.openBox('groupBox');
      database.add(Group("testGroup", []));
      //checks if database is not empty and if the group has no students
      expect(database.isEmpty, false);
      expect(database.getAt(0)!.students.isEmpty, true);
    });

    test('adding student to testGroup', () async {
      Box<Group> database = await Hive.openBox('groupBox');
      database.add(Group(
          "testGroup", [Student("surname", "name", "mailID", "Group", [], 0)]));
      expect(database.getAt(0)!.students.isEmpty, false);
      expect(database.getAt(0)!.students[0].projects.isEmpty, true);
    });

    test('adding project to student', () async {
      Box<Group> database = await Hive.openBox('groupBox');
      database.add(Group("testGroup", [
        Student("surname", "name", "mailID", "Group",
            [StudentProject("name", 0, true, true, 0, false)], 0)
      ]));
      expect(database.getAt(0)!.students[0].projects.isEmpty, false);
      database.getAt(0)!.students[0].recalcProjectsMissed();
      expect(database.getAt(0)!.students[0].nbProjectsMissed, 0);
    });

    test('adding projects to student and testing values', () async {
      Box<Group> database = await Hive.openBox('groupBox');
      database.add(Group(
          "testGroup", [Student("surname", "name", "mailID", "Group", [], 0)]));
      database
          .getAt(0)!
          .students[0]
          .projects
          .add(StudentProject("name", 0, true, false, 0, false));
      database
          .getAt(0)!
          .students[0]
          .projects
          .add(StudentProject("name", 20, true, false, 0, true));

      database.getAt(0)!.students[0].recalcProjectsMissed();
      expect(database.getAt(0)!.students[0].nbProjectsMissed, 1);
    });
  });
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:smart_split/Data/group.dart';
import 'package:smart_split/Data/project.dart';
import 'package:smart_split/Data/student.dart';
import 'package:smart_split/Widgets/Project%20Manager/project_buttons.dart';

///Creates a stateful Student Manager Widget
class ProjectContentWidget extends StatefulWidget {
  //ID of the project that will be displayed
  final int selectedProjectID;
  const ProjectContentWidget(this.selectedProjectID, {Key? key})
      : super(key: key);

  @override
  _ProjectContent createState() => _ProjectContent();
}

//Main body of the student manager display
class _ProjectContent extends State<ProjectContentWidget> {
  //index of the column that is being sorted in the datatable
  int _currentSortedColumn = 3;
  //ascending or descending sorting order
  bool _isAscending = false;
  //list of students displayed in Student Manager
  final List<Student> _studentList = [];
  //ID of the previous selected project (to clear the list of students when switching from a project to another)
  //bool to force a refresh of the widget
  // ignore: unused_field
  bool _hasBeenModified = false;
  int _oldProjectID = -1;
  @override
  Widget build(BuildContext context) {
    //wait for future (hive DB) to be fetched then displays datatable
    return FutureBuilder(
        future: Hive.openBox<Group>('groupBox'),
        builder:
            (BuildContext context, AsyncSnapshot<Box<Group>> openedGroupBox) {
          if (openedGroupBox.hasData) {
            if (_oldProjectID != widget.selectedProjectID) {
              _studentList.clear();
              _oldProjectID = widget.selectedProjectID;
            }
            final Box<Group> groupBox = openedGroupBox.data as Box<Group>;
            final int nbGroups = groupBox.length;
            final String projectName = groupBox
                .getAt(0)!
                .students[0]
                .projects[widget.selectedProjectID]
                .name;
            for (int groupIndex = 0; groupIndex < nbGroups; groupIndex++) {
              final Group group = groupBox.getAt(groupIndex) as Group;
              final int groupSize = group.students.length;

              for (var studentIndex = 0;
                  studentIndex < groupSize;
                  studentIndex++) {
                final student = group.students[studentIndex];
                //checks if the student isn't already in the list and if he/she participates to the current project
                if (!_studentList.contains(student)) {
                  _studentList.add(student);
                }
              }
            }

            return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: 80,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(projectName.toUpperCase(),
                                textAlign: TextAlign.center,
                                textScaleFactor: 3,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green)),
                            projectGroupAlertDisplay(groupBox)
                          ])),
                  SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: 30,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ShuffleProjectGroupsButton(
                              refresh,
                              widget.selectedProjectID,
                              groupBox
                                  .getAt(0)!
                                  .students[0]
                                  .projects[widget.selectedProjectID]
                                  .ongoing),
                          EnableGradingButton(
                              refresh,
                              widget.selectedProjectID,
                              groupBox
                                  .getAt(0)!
                                  .students[0]
                                  .projects[widget.selectedProjectID]
                                  .ongoing)
                        ],
                      )),
                  Expanded(
                      //Enables horizontal and vertical scrolling
                      child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: DataTable(
                                  sortColumnIndex: _currentSortedColumn,
                                  sortAscending: _isAscending,
                                  columns: <DataColumn>[
                                    const DataColumn(label: Text('Registered')),
                                    DataColumn(
                                        label: const Text('Name'),
                                        onSort: (columnIndex, sortAscending) {
                                          setState(() {
                                            _currentSortedColumn = columnIndex;
                                            if (_isAscending == true) {
                                              _isAscending = false;
                                              _studentList.sort(
                                                  (studentA, studentB) =>
                                                      stringSort(
                                                          studentA.name,
                                                          studentB.name,
                                                          false));
                                            } else {
                                              _isAscending = true;
                                              _studentList.sort(
                                                  (studentA, studentB) =>
                                                      stringSort(studentA.name,
                                                          studentB.name, true));
                                            }
                                          });
                                        }),
                                    DataColumn(
                                        label: const Text('Surname'),
                                        onSort: (columnIndex, sortAscending) {
                                          setState(() {
                                            _currentSortedColumn = columnIndex;
                                            if (_isAscending == true) {
                                              _isAscending = false;
                                              _studentList.sort(
                                                  (studentA, studentB) =>
                                                      stringSort(
                                                          studentA.surname,
                                                          studentB.surname,
                                                          false));
                                            } else {
                                              _isAscending = true;
                                              _studentList.sort(
                                                  (studentA, studentB) =>
                                                      stringSort(
                                                          studentA.surname,
                                                          studentB.surname,
                                                          true));
                                            }
                                          });
                                        }),
                                    DataColumn(
                                        label: const Text('Class Group'),
                                        onSort: (columnIndex, sortAscending) {
                                          setState(() {
                                            _currentSortedColumn = columnIndex;
                                            if (_isAscending == true) {
                                              _isAscending = false;
                                              _studentList.sort(
                                                  (studentA, studentB) =>
                                                      stringSort(
                                                          studentA.group,
                                                          studentB.group,
                                                          false));
                                            } else {
                                              _isAscending = true;
                                              _studentList.sort(
                                                  (studentA, studentB) =>
                                                      stringSort(
                                                          studentA.group,
                                                          studentB.group,
                                                          true));
                                            }
                                          });
                                        }),
                                    DataColumn(
                                        label: const Text('Project Group'),
                                        onSort: (columnIndex, ascending) {
                                          setState(() {
                                            _currentSortedColumn = columnIndex;
                                            if (_isAscending == true) {
                                              _isAscending = false;
                                              _studentList.sort((studentA,
                                                      studentB) =>
                                                  studentA
                                                      .projects[widget
                                                          .selectedProjectID]
                                                      .projectGroupID
                                                      .compareTo(studentB
                                                          .projects[widget
                                                              .selectedProjectID]
                                                          .projectGroupID));
                                            } else {
                                              _isAscending = true;
                                              _studentList.sort((studentB,
                                                      studentA) =>
                                                  studentA
                                                      .projects[widget
                                                          .selectedProjectID]
                                                      .projectGroupID
                                                      .compareTo(studentB
                                                          .projects[widget
                                                              .selectedProjectID]
                                                          .projectGroupID));
                                            }
                                            //additionnal sort to make sure students that don't have a group aren't listed first (because they are in group 0)
                                            projectGroupSort();
                                          });
                                        }),
                                    const DataColumn(label: Text('Absent')),
                                    const DataColumn(label: Text('Grades'))
                                  ],
                                  rows: List.generate(_studentList.length,
                                      (index) {
                                    return DataRow(cells: [
                                      //Participation/Registered switch
                                      DataCell(Switch(
                                        activeTrackColor:
                                            Colors.lightGreenAccent,
                                        activeColor: Colors.green,
                                        value: _studentList[index]
                                            .projects[widget.selectedProjectID]
                                            .registered,
                                        onChanged: (check) async {
                                          Student student = _studentList[index];
                                          await setParticipation(
                                              student.group,
                                              student.mailID,
                                              widget.selectedProjectID,
                                              check);
                                          setState(() {
                                            _isAscending = _isAscending;
                                          });
                                        },
                                      )),
                                      //Name
                                      DataCell(Text(_studentList[index].name)),
                                      //Family name
                                      DataCell(
                                          Text(_studentList[index].surname)),
                                      //Class group
                                      DataCell(Text(_studentList[index].group)),

                                      //Project group ID
                                      DataCell(Row(children: [
                                        workGroupDisplay(
                                            _studentList[index].projects[
                                                widget.selectedProjectID]),
                                        WorkGroupEditButton(
                                            refresh,
                                            _studentList[index]
                                                .projects[
                                                    widget.selectedProjectID]
                                                .ongoing,
                                            widget.selectedProjectID,
                                            _studentList[index]
                                                .projects[
                                                    widget.selectedProjectID]
                                                .projectGroupID,
                                            _studentList[index].mailID)
                                      ])),
                                      //Absence switch
                                      DataCell(Switch(
                                        activeTrackColor:
                                            Colors.redAccent.shade100,
                                        activeColor: Colors.red,
                                        value: _studentList[index]
                                            .projects[widget.selectedProjectID]
                                            .absent,
                                        onChanged: (check) async {
                                          Student student = _studentList[index];
                                          await setAbsent(
                                              student.group,
                                              student.mailID,
                                              widget.selectedProjectID,
                                              check);
                                          setState(() {
                                            _isAscending = _isAscending;
                                          });
                                        },
                                      )),
                                      //Grades
                                      DataCell(Row(children: [
                                        gradesDisplay(
                                            _studentList[index].projects[
                                                widget.selectedProjectID]),
                                        GradeEditBUtton(
                                            refresh,
                                            _studentList[index]
                                                .projects[
                                                    widget.selectedProjectID]
                                                .ongoing,
                                            widget.selectedProjectID,
                                            _studentList[index]
                                                .projects[
                                                    widget.selectedProjectID]
                                                .projectGroupID)
                                      ]))
                                    ]);
                                  })))))
                ]);
          } else {
            return const CircularProgressIndicator();
          }
        });
  }

  //putting students with projectGroupID 0 to the end of the list (they don't have a group)
  void projectGroupSort() {
    bool loopAgain = false;
    for (int studentIndex = 0;
        studentIndex < _studentList.length;
        studentIndex++) {
      Student currentStudent = _studentList[studentIndex];
      if (currentStudent.projects[widget.selectedProjectID].projectGroupID ==
          0) {
        _studentList.removeAt(studentIndex);
        _studentList.add(currentStudent);
      } else if (loopAgain == false) {
        loopAgain = true;
      }
    }
    if (_studentList[0].projects[widget.selectedProjectID].projectGroupID ==
            0 &&
        loopAgain) {
      projectGroupSort();
    }
  }

  ///Help a sort function by comparing [optionA] with [optionB] with an ascending or descending order [ascending] (made to sort strings)
  int stringSort(String optionA, String optionB, bool ascending) {
    if (ascending) {
      return optionB.toLowerCase().compareTo(optionA.toLowerCase());
    } else {
      return optionA.toLowerCase().compareTo(optionB.toLowerCase());
    }
  }

  ///Display the ID of the project group the student is assigned to
  Text workGroupDisplay(StudentProject project) {
    int workGroup = project.projectGroupID;
    bool participation = project.registered;
    Color textColor = Colors.grey;
    if (participation) {
      textColor = Colors.red;
    }

    if (workGroup == 0) {
      return Text("N/A", style: TextStyle(color: textColor));
    }
    return Text(workGroup.toString());
  }

  //Displays the grade the student has for the project
  Text gradesDisplay(StudentProject project) {
    double grade = project.gradePoint;
    bool ongoing = project.ongoing;
    bool absent = project.absent;
    Color textColor = Colors.grey;
    if (!ongoing) {
      if (grade < 10) {
        textColor = Colors.red;
      } else {
        textColor = Colors.green;
      }
    }
    if (absent) {
      grade = 0;
      textColor = Colors.black;
    }
    return Text(grade.toString(),
        style: TextStyle(
          color: textColor,
        ));
  }

  ///Displays an alert if students that should have a group aren't in one
  Widget projectGroupAlertDisplay(Box<Group> groupBox) {
    //Counter to track how many students aren't part of a group for the project
    int nbStudentMissingProject = 0;
    for (Group group in groupBox.values) {
      for (Student student in group.students) {
        StudentProject currentProject =
            student.projects[widget.selectedProjectID];
        if (currentProject.registered && currentProject.projectGroupID == 0) {
          nbStudentMissingProject++;
        }
      }
    }

    if (nbStudentMissingProject > 0) {
      return Tooltip(
          message: "$nbStudentMissingProject students are not part of a group",
          child: const Icon(Icons.info_outline, color: Colors.red, size: 25));
    }
    //return "nothing"
    return const SizedBox.shrink();
  }

  Future<void> setParticipation(String groupName, String studentMailID,
      int projectID, bool participation) async {
    Box<Group> groupBox = await Hive.openBox<Group>('groupBox');
    Group? group = groupBox.get(groupName);
    for (Student student in group!.students) {
      if (student.mailID == studentMailID) {
        //sets participation to the specified value of the parameter (true or false)
        student.projects[projectID]
            .setRegistration(participation, "'Manual Switching'");
        student.recalcProjectsMissed();
        debugPrint(
            "${student.name} has now ${student.nbProjectsMissed} projects where he/she didnt participate");
        //breaking out of the loop as soon as the student has been found and the participation set to a new value
        break;
      }
    }
    group.save();
  }

  Future<void> setAbsent(String groupName, String studentMailID, int projectID,
      bool absent) async {
    Box<Group> groupBox = await Hive.openBox<Group>('groupBox');
    Group? group = groupBox.get(groupName);
    for (Student student in group!.students) {
      if (student.mailID == studentMailID) {
        //sets participation to the specified value of the parameter (true or false)
        student.projects[projectID].absent = absent;
        student.recalcProjectsMissed();
        //breaking out of the loop as soon as the student has been found and the participation set to a new value
        break;
      }
    }
    group.save();
  }

  //used to refresh the widget
  void refresh() {
    setState(() {
      _hasBeenModified = true;
    });
  }
}

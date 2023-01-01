import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hive/hive.dart';
import 'package:smart_split/Data/group.dart';
import 'package:smart_split/Data/project.dart';
import 'package:smart_split/Data/student.dart';
import 'package:smart_split/Utils/decorations.dart';

///Creates a stateful Student Manager Widget
class StudentManagerWidget extends StatefulWidget {
  const StudentManagerWidget({Key? key}) : super(key: key);

  @override
  _StudentManager createState() => _StudentManager();
}

//Main body of the student manager display
class _StudentManager extends State<StudentManagerWidget> {
  //index of the column that is being sorted in the datatable
  int _currentSortedColumn = 3;
  //ascending or descending sorting order
  bool _isAscending = false;
  //list of students displayed in Student Manager
  final List<Student> _studentList = [];
  @override
  Widget build(BuildContext context) {
    //wait for future (hive DB) to be fetched then displays datatable
    return FutureBuilder(
        future: Hive.openBox<Group>('groupBox'),
        builder:
            (BuildContext context, AsyncSnapshot<Box<Group>> openedGroupBox) {
          if (openedGroupBox.hasData) {
            final Box<Group> groupBox = openedGroupBox.data as Box<Group>;
            final int nbGroups = groupBox.length;
            if (groupBox.isEmpty) {
              return Text(
                "Import students in File Manager in order to use Student Manager"
                    .toUpperCase(),
                style: const TextStyle(color: Colors.red),
              );
            }
            for (int groupIndex = 0; groupIndex < nbGroups; groupIndex++) {
              final Group group = groupBox.getAt(groupIndex) as Group;
              final int groupSize = group.students.length;

              for (var studentIndex = 0;
                  studentIndex < groupSize;
                  studentIndex++) {
                final student = group.students[studentIndex];
                if (!_studentList.contains(student)) {
                  _studentList.add(student);
                }
              }
            }
            return Column(children: [
              SizedBox(
                width: double.infinity,
                height: 80,
                child: Text(
                  "Student Database".toUpperCase(),
                  textAlign: TextAlign.center,
                  textScaleFactor: 2,
                  style: const TextStyle(color: Colors.blueAccent),
                ),
              ),
              const SeparationBar(
                  fractionSize: 1,
                  inputColor: Colors.blueAccent,
                  inputWidth: 2,
                  isHorizontal: true),
              Expanded(
                  child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: DataTable(
                              sortColumnIndex: _currentSortedColumn,
                              sortAscending: _isAscending,
                              columns: <DataColumn>[
                                DataColumn(
                                    label: const Text('Name'),
                                    onSort: (columnIndex, sortAscending) {
                                      setState(() {
                                        _currentSortedColumn = columnIndex;
                                        if (_isAscending == true) {
                                          _isAscending = false;
                                          _studentList.sort(
                                              (studentA, studentB) =>
                                                  stringSort(studentA.name,
                                                      studentB.name, false));
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
                                                  stringSort(studentA.surname,
                                                      studentB.surname, false));
                                        } else {
                                          _isAscending = true;
                                          _studentList.sort(
                                              (studentA, studentB) =>
                                                  stringSort(studentA.surname,
                                                      studentB.surname, true));
                                        }
                                      });
                                    }),
                                DataColumn(
                                    label: const Text('Mail Adress'),
                                    onSort: (columnIndex, sortAscending) {
                                      setState(() {
                                        _currentSortedColumn = columnIndex;
                                        if (_isAscending == true) {
                                          _isAscending = false;
                                          _studentList.sort(
                                              (studentA, studentB) =>
                                                  stringSort(studentA.mailID,
                                                      studentB.mailID, false));
                                        } else {
                                          _isAscending = true;
                                          _studentList.sort(
                                              (studentA, studentB) =>
                                                  stringSort(studentA.mailID,
                                                      studentB.mailID, true));
                                        }
                                      });
                                    }),
                                DataColumn(
                                    label: const Text('Group'),
                                    onSort: (columnIndex, sortAscending) {
                                      setState(() {
                                        _currentSortedColumn = columnIndex;
                                        if (_isAscending == true) {
                                          _isAscending = false;
                                          _studentList.sort(
                                              (studentA, studentB) =>
                                                  stringSort(studentA.group,
                                                      studentB.group, false));
                                        } else {
                                          _isAscending = true;
                                          _studentList.sort(
                                              (studentA, studentB) =>
                                                  stringSort(studentA.group,
                                                      studentB.group, true));
                                        }
                                      });
                                    }),
                                const DataColumn(
                                    label: Text('Average of Grades'))
                              ],
                              rows: List.generate(_studentList.length, (index) {
                                return DataRow(cells: [
                                  DataCell(Text(_studentList[index].name)),
                                  DataCell(Text(_studentList[index].surname)),
                                  DataCell(Text(_studentList[index].mailID)),
                                  DataCell(Text(_studentList[index].group)),
                                  DataCell(averageGrades(
                                      _studentList[index].projects))
                                ]);
                              })))))
            ]);
          } else {
            return const Center(
                child: SizedBox(
                    child: CircularProgressIndicator(), width: 50, height: 50));
          }
        });
  }

  ///Help a sort function by comparing [optionA] with [optionB] with an ascending or descending order [ascending] (made to sort strings)
  int stringSort(String optionA, String optionB, bool ascending) {
    if (ascending) {
      return optionB.toLowerCase().compareTo(optionA.toLowerCase());
    } else {
      return optionA.toLowerCase().compareTo(optionB.toLowerCase());
    }
  }

  ///Calculates and returns the average grades of the student
  Text averageGrades(List<StudentProject> projectList) {
    //final value for the average of all grades (string because Text widget)
    String result;
    //color of the text that will be displayed in Student Manager
    Color color;
    //sum of all projects in which the student has participated
    double totalGrades = 0;
    //count how many finished projects there were
    int nbOfProjects = 0;
    //iterate over all projects
    for (StudentProject project in projectList) {
      //check if project is over (if it's still ongoing, skip to next project)
      if (project.ongoing) continue;

      //if student participated to the project, add grades to the total
      if (!project.absent && project.registered) {
        totalGrades += project.gradePoint;
      }
      nbOfProjects++;
    }

    //setting return values and colors
    //if there are no project, return a grey "N/A" (also avoids division by zero)
    if (nbOfProjects == 0) {
      result = 'N/A';
      color = Colors.grey;
    }
    //else compute the average and set the color accordingly (red or green)
    else {
      double averageGrade = totalGrades / nbOfProjects;
      result = double.parse((averageGrade).toString()).toStringAsFixed(2);

      if (averageGrade < 10) {
        color = Colors.red;
      } else {
        color = Colors.green;
      }
    }
    return Text(
      result,
      style: TextStyle(color: color),
    );
  }
}

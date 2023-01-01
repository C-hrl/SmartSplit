import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:smart_split/Data/group.dart';
import 'package:smart_split/Data/project.dart';
import 'package:smart_split/Data/student.dart';
import 'package:smart_split/Widgets/File%20Manager/file_manager.dart';

///class containing all alerts and pop-up dialogs
class DialogUtils {
  //Displays an alert because a file with the exact same name has already been imported
  Future<bool> duplicateFileAlertDialog(
      BuildContext context, String fileName) async {
    bool skip = false;
    //skip import button
    Widget skipButton = TextButton(
      child: const Text('Skip file'),
      onPressed: () {
        skip = true;
        //removes the alert dialog
        Navigator.of(context).pop();
      },
    );
    //Button to proceed to import anyway
    Widget proceedButton = TextButton(
      child: const Text('Proceed anyway'),
      onPressed: () {
        //removes the alert dialog
        Navigator.of(context).pop();
      },
    );
    await showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: const Text('Warning'),
              content: RichText(
                text: TextSpan(
                    style: const TextStyle(color: Colors.black),
                    children: <TextSpan>[
                      const TextSpan(text: 'A file named '),
                      TextSpan(
                          text: fileName,
                          style: const TextStyle(color: Colors.red)),
                      const TextSpan(
                          text:
                              ' has already been imported, are you sure you want to proceed?')
                    ]),
              ),
              actions: [skipButton, proceedButton],
            ));
    return skip;
  }

  //displays a confirmation alert to make sure the user wants to delete the specified content
  Future<bool> deletionAlertDialog(BuildContext context) async {
    bool refresh = false;
    //cancel button
    Widget cancelButton = TextButton(
        onPressed: () {
          //removes the alert dialog
          Navigator.of(context).pop();
        },
        child: const Text('Cancel'));
    //confirm deletion button
    Widget deleteDBButton = TextButton(
        onPressed: () async {
          //clears the database
          await Hive.openBox<Group>('groupBox').then((groupBox) async {
            groupBox.clear();
            await Hive.openBox<String>('fileBox').then((fileBox) async {
              await fileBox.clear();
              refresh = true;

              //removes the alert dialog
              Navigator.of(context).pop();
            });
          });
        },
        child: const Text('Confirm'));
    await showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: const Text('Warning'),
              content: const Text(
                  'Are you sure you want to delete the database?\nAll files will be lost'),
              actions: [cancelButton, deleteDBButton],
            ));
    return refresh;
  }

  Future exportDBDialog(BuildContext context) async {
    //future name of the export file
    TextEditingController fileNameController = TextEditingController();
    await showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: const Text("Name your export file"),
              content: TextField(
                controller: fileNameController,
                key: const Key('exportFileDialog'),
              ),
              actions: [
                //cancel button
                TextButton(
                    child: const Text("Cancel Export"),
                    onPressed: () {
                      Navigator.of(context).pop();
                    }),
                TextButton(
                    onPressed: () async {
                      final String fileName = fileNameController.text;
                      //creating file location to write something inside it and create the file
                      var exportFile = await fileCreator(fileName);
                      //converting database into String
                      String database = '';
                      Box groupBox = await Hive.openBox<Group>('groupBox');
                      //Beginning of the first line containing column names
                      database += "Firstname,Surname,Mail";
                      //fetching project names to complete the first line
                      Group firstGroup = groupBox.getAt(0);
                      for (StudentProject project
                          in firstGroup.students[0].projects) {
                        database += ', ${project.name}';
                      }
                      //closing the first line once it contains all column names
                      database += ',Averages\n';
                      for (Group group in groupBox.values) {
                        for (Student student in group.students) {
                          database += student.name;
                          database += ',${student.surname}';
                          database += ',${student.mailID}';
                          int totalGrades = 0;
                          int nbOfProjects = 0;
                          for (StudentProject project in student.projects) {
                            database += ', ${project.gradePoint}';
                            nbOfProjects++;
                          }
                          if (nbOfProjects == 0) {
                            database += ',N/A\n';
                          } else {
                            database +=
                                ',${(totalGrades / nbOfProjects).toString()}\n';
                          }
                        }
                      }
                      //writing database inside the file
                      exportFile.writeAsString(database);
                      Navigator.of(context).pop();
                    },
                    child: const Text("Confirm"))
              ],
            ));
  }

  //Creates the file in local path (documents)
  Future<File> fileCreator(String fileName) async {
    final path = await FileUtils().localPath;
    return File('$path/$fileName.csv');
  }

  Future<bool> projectCreationDialog(
      BuildContext context, TextEditingController projectNameController) async {
    bool refresh = false;
    await showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: const Text(
                "Create a New Project",
                textAlign: TextAlign.center,
              ),
              content: TextField(
                controller: projectNameController,
              ),
              actions: [
                //Button to create the project
                TextButton(
                    onPressed: () async {
                      Box groupBox = await Hive.openBox<Group>('groupBox');
                      int nbGroups = groupBox.length;
                      for (int groupIndex = 0;
                          groupIndex < nbGroups;
                          groupIndex++) {
                        Group selectedGroup = groupBox.getAt(groupIndex);
                        for (Student student in selectedGroup.students) {
                          //keep these parameters for setting a new group project
                          student.projects.add(StudentProject(
                              projectNameController.text,
                              0,
                              false,
                              true,
                              0,
                              false));
                        }
                        selectedGroup.save();
                        //clearing TextField
                        projectNameController.clear();
                      }
                      //removes the alert dialog
                      Navigator.of(context).pop();
                      refresh = true;
                    },
                    child: const Text('Confirm'))
              ],
            ));
    return refresh;
  }

  Future<bool> projectDeletionDialog(
      BuildContext context, int projectIndex) async {
    bool refresh = false;
    await showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: const Text(
                "Are you sure you want to delete this project?",
                textAlign: TextAlign.center,
              ),
              actions: [
                TextButton(
                    child: const Text("Cancel"),
                    onPressed: () {
                      Navigator.of(context).pop();
                    }),
                //Button to delete the project
                TextButton(
                    onPressed: () async {
                      Box groupBox = await Hive.openBox<Group>('groupBox');
                      int nbGroups = groupBox.length;
                      for (int groupIndex = 0;
                          groupIndex < nbGroups;
                          groupIndex++) {
                        Group selectedGroup = groupBox.getAt(groupIndex);
                        for (Student student in selectedGroup.students) {
                          student.projects.removeAt(projectIndex);
                          student.recalcProjectsMissed();
                        }
                        selectedGroup.save();
                      }
                      //removes the alert dialog
                      Navigator.of(context).pop();
                      refresh = true;
                    },
                    child: const Text("Confirm")),
              ],
            ));
    return refresh;
  }

  Future shuffleProjectGroups(BuildContext context, int projectID) async {
    TextEditingController projectGroupSizeController = TextEditingController();
    await showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: const Text(
                "Project Groups Size",
                textAlign: TextAlign.center,
              ),
              content: TextField(
                decoration:
                    const InputDecoration(hintText: 'Please, enter a number'),
                controller: projectGroupSizeController,
                //only allow numbers
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
              ),
              actions: [
                //Button to shuffle the students into projectGroups
                TextButton(
                    child: const Text("Confirm"),
                    onPressed: () async {
                      //Size of the projectGroups
                      int projectGroupSize =
                          int.parse(projectGroupSizeController.text);
                      //can't have a group size of 0
                      if (projectGroupSize == 0) {
                        projectGroupSize = 1;
                      }
                      Box groupBox = await Hive.openBox<Group>('groupBox');
                      int nbGroups = groupBox.length;
                      //ensuring each project group has a unique ID
                      int groupCounter = 0;
                      for (int groupIndex = 0;
                          groupIndex < nbGroups;
                          groupIndex++) {
                        //list containing students who participated to all projects and were never absent
                        List<Student> regularStudents = [];
                        //list containing students who didn't participate to all projects/work session
                        List<Student> irregularStudents = [];
                        //get the current class group
                        Group selectedGroup = groupBox.getAt(groupIndex);
                        debugPrint("Now in group ${selectedGroup.name}");
                        //sorting students according to their participation to previous projects into two separate pools
                        for (Student student in selectedGroup.students) {
                          student.projects[projectID].projectGroupID = 0;
                          if (student.projects[projectID].registered) {
                            if (student.nbProjectsMissed == 0) {
                              regularStudents.add(student);
                            } else {
                              irregularStudents.add(student);
                            }
                          }
                        }
                        //how many regular projectGroups exist
                        int nbRegularprojectGroups =
                            (regularStudents.length / projectGroupSize).ceil();
                        //calculating the remainder and how many irregular students are needed to complete regular projectGroups
                        int remainder = 0;
                        int requiredIrregularStudents = 0;
                        if (regularStudents.length <= projectGroupSize &&
                            regularStudents.isNotEmpty) {
                          //remainder needed to fill regular projectGroups
                          requiredIrregularStudents =
                              projectGroupSize % regularStudents.length;
                          debugPrint(
                              "A $nbRegularprojectGroups regular projectGroups for ${regularStudents.length} students");
                        } else {
                          remainder = regularStudents.length % projectGroupSize;
                          if (remainder == 0) {
                            requiredIrregularStudents = remainder;
                          } else {
                            requiredIrregularStudents =
                                projectGroupSize - remainder;
                          }
                          debugPrint(
                              "A $nbRegularprojectGroups regular projectGroups for ${regularStudents.length} students");
                        }
                        //If there isn't enough irregular students to fill the regular groups, reduce the number of students to transfer
                        if (requiredIrregularStudents >
                            irregularStudents.length) {
                          requiredIrregularStudents = irregularStudents.length;
                          debugPrint(
                              "Required irregular students reduced to $requiredIrregularStudents");
                        }
                        //moving the required number of least irregular students to the pool of regular students
                        if (requiredIrregularStudents > 0) {
                          for (int index = 0;
                              index < requiredIrregularStudents;
                              index++) {
                            Student studentToMove = irregularStudents[0];
                            irregularStudents.removeAt(0);
                            regularStudents.add(studentToMove);
                            debugPrint(
                                "${studentToMove.name} was moved to regulars");
                          }
                        }
                        //Shuffling regular students to randomly put them in groups
                        regularStudents.shuffle();
                        //Shuffling irregulars before sorting to shuffle people with the same amount of projects missed
                        irregularStudents.shuffle();
                        //Sorting irregular students according to the numbers of project they have missed
                        irregularStudents.sort((studentA, studentB) => studentA
                            .nbProjectsMissed
                            .compareTo(studentB.nbProjectsMissed));
                        //Putting regular students in groups
                        groupCounter = groupFiller(
                            regularStudents,
                            groupCounter,
                            projectGroupSize,
                            selectedGroup,
                            projectID);
                        //Adding +1 to separate last regular project group from first irregular project group
                        if (irregularStudents.isNotEmpty) {
                          groupCounter++;
                        }
                        //Putting irregular students in groups
                        groupCounter = groupFiller(
                            irregularStudents,
                            groupCounter,
                            projectGroupSize,
                            selectedGroup,
                            projectID);
                        //Adding +1 to separate the last project group from this class group from the first project group of the next class group
                        groupCounter++;
                      }
                      //clearing TextField
                      projectGroupSizeController.clear();
                      //removes the alert dialog
                      Navigator.of(context).pop();
                    })
              ],
            ));
  }

  String validateProjectGroupSizeValue(int value) {
    if (value == 0) {
      return "At least one student required per group";
    }
    return "";
  }

  ///Creates project groups of size [projectGroupSize] from students in [studentList] (list can be shuffled beforehand) and with group ID [groupIndex]
  ///[projectID] is the ID of the project
  ///[selectedGroup] is the database of a class group
  int groupFiller(List<Student> studentList, int groupIndex,
      int projectGroupSize, Group selectedGroup, int projectID) {
    int groupSizeCounter = 0;
    while (studentList.isNotEmpty) {
      if (groupSizeCounter == projectGroupSize) {
        groupSizeCounter = 0;
        groupIndex++;
      }
      Student currentStudent = studentList[0];
      studentList.removeAt(0);

      for (Student student in selectedGroup.students) {
        if (student.mailID == currentStudent.mailID) {
          // "+ 1" to avoid having a projectGroup with ID 0
          student.projects[projectID].projectGroupID = groupIndex + 1;
          groupSizeCounter++;
          debugPrint(
              "${student.name} is now in projectGroup ${groupIndex + 1} ");
        }
      }
    }
    selectedGroup.save();
    return groupIndex;
  }

  Future setGrades(BuildContext context, int projectID, int workGroupID) async {
    TextEditingController gradeController = TextEditingController();
    await showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: Text(
                "Grades for Group $workGroupID",
                textAlign: TextAlign.center,
              ),
              content: TextField(
                decoration:
                    const InputDecoration(hintText: 'Please, enter a number'),
                controller: gradeController,
                //only allow numbers
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                ],
              ),
              actions: [
                //Button to delete the project
                TextButton(
                    onPressed: () async {
                      //converting input into an integer
                      double gradeValue = double.parse(gradeController.text);
                      //making sure value can't go over 20
                      if (gradeValue > 20) {
                        gradeValue = 20;
                      }
                      Box groupBox = await Hive.openBox<Group>('groupBox');
                      for (Group group in groupBox.values) {
                        for (Student student in group.students) {
                          if (student.projects[projectID].projectGroupID ==
                              workGroupID) {
                            student.projects[projectID].gradePoint = gradeValue;
                          }
                        }
                        group.save();
                      }
                      //removes the alert dialog
                      Navigator.of(context).pop();
                    },
                    child: const Text("Confirm")),
              ],
            ));
  }

  Future setWorkGroup(
      BuildContext context, String mailID, int projectID, int groupID) async {
    TextEditingController workGroupController = TextEditingController();
    await showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: const Text(
                "Insert a group number",
                textAlign: TextAlign.center,
              ),
              content: TextField(
                decoration:
                    const InputDecoration(hintText: 'Please, enter a number'),
                controller: workGroupController,
                //only allow numbers
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
              ),
              actions: [
                //Button to delete the project
                TextButton(
                    onPressed: () async {
                      //tracking how many other students are already in that group
                      int nbOfStudentInGroupCounter = 0;
                      int classGroupCounter = 0;
                      //used to track in which class group are students
                      int classGroupID = -1;
                      bool stop = false;
                      //converting input into an integer
                      int targetWorkGroupID =
                          int.parse(workGroupController.text);
                      //making sure value can't go over 20
                      Box groupBox = await Hive.openBox<Group>('groupBox');
                      //checking if this project group isn't part of another class group (x in group B can't join project group 2 of group A)
                      for (Group group in groupBox.values) {
                        debugPrint("$classGroupCounter");
                        for (Student student in group.students) {
                          //if we find a class group in which a student is part of the targeted project group, count how many students are in the group and set classGroupID
                          if (student.projects[projectID].projectGroupID ==
                              targetWorkGroupID) {
                            debugPrint("match with ${student.name}");
                            nbOfStudentInGroupCounter++;
                            stop = true;
                          }
                        }
                        //If we found a class group with the project group in it we don't need to iterate over other class groups
                        if (stop) {
                          classGroupID = classGroupCounter;
                          debugPrint("class group is $classGroupID");
                          break;
                        }
                        classGroupCounter++;
                      }
                      //setting student to his new group if nothing stopped
                      int targetClassGroup = 0;
                      for (Group group in groupBox.values) {
                        for (Student student in group.students) {
                          if (student.mailID == mailID) {
                            debugPrint(
                                "found targeted student ${student.name}");
                            if (targetClassGroup != classGroupID) {
                              debugPrint("wrong class group");
                              //switches to another dialog and pause the current one
                              return showDialog(
                                  context: context,
                                  builder: (BuildContext context) =>
                                      const AlertDialog(
                                          title: Text("Error"),
                                          content: Text(
                                              "This project group is not in the same class group")));
                            }

                            student.projects[projectID].projectGroupID =
                                targetWorkGroupID;
                            //removes the alert dialog
                            Navigator.of(context).pop();
                            //displaying success message
                            return showDialog(
                                context: context,
                                builder: (BuildContext context) => AlertDialog(
                                    title: const Text("Success"),
                                    content: Text(
                                        "${student.name} is now in group ${student.projects[projectID].projectGroupID} with $nbOfStudentInGroupCounter other students")));
                          }
                        }
                        group.save();
                        targetClassGroup++;
                      }

                      //removes the alert dialog
                      Navigator.of(context).pop();
                    },
                    child: const Text("Confirm")),
              ],
            ));
  }

  Future<bool> enableGrading(BuildContext context, int projectID) async {
    bool refresh = true;
    bool hasChosen = false;
    await Hive.openBox<Group>('groupBox').then((groupBox) async {
      //used later to break out of the two loops
      outerloop:
      for (Group group in groupBox.values) {
        for (Student student in group.students) {
          StudentProject currentProject = student.projects[projectID];
          if (currentProject.registered && currentProject.projectGroupID == 0) {
            refresh = false;
            await showDialog(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                      title: const Text(
                        "Error",
                        textAlign: TextAlign.center,
                      ),
                      content: const Text(
                          "At least one registered student isn't part of a group"),
                      actions: [
                        TextButton(
                            onPressed: () {
                              //removes the alert dialog
                              Navigator.of(context).pop();
                            },
                            child: const Text("Ok"))
                      ],
                    ));
            //breaks out of the two loops
            break outerloop;
          } else if (!hasChosen) {
            await showDialog(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                      title: const Text(
                        "Confirmation Prompt",
                        textAlign: TextAlign.center,
                      ),
                      content: const Text(
                          "This operation will lock all project groups, you will not be able to edit projetct groups or add students into them anymore!"),
                      actions: [
                        TextButton(
                            onPressed: () {
                              refresh = false;
                              hasChosen = true;
                              //removes the alert dialog
                              Navigator.of(context).pop();
                            },
                            child: const Text("Cancel")),
                        TextButton(
                            onPressed: () {
                              refresh = true;
                              hasChosen = true;
                              //removes the alert dialog
                              Navigator.of(context).pop();
                            },
                            child: const Text("Proceed"))
                      ],
                    ));
          }
          currentProject.ongoing = false;
        }
      }
    });
    if (refresh) {
      await showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
                title: const Text(
                  "Operation Successful",
                  textAlign: TextAlign.center,
                ),
                content:
                    const Text("Groups are now locked, you can now grade them"),
                actions: [
                  TextButton(
                      onPressed: () {
                        //removes the alert dialog
                        Navigator.of(context).pop();
                      },
                      child: const Text("Ok"))
                ],
              ));
    }
    return refresh;
  }
}

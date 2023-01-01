import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:smart_split/Data/group.dart';
import 'package:smart_split/Data/student.dart';
import 'package:smart_split/Utils/dialog_utils.dart';

class CreateProjectButton extends StatelessWidget {
  final VoidCallback stateSetter;
  const CreateProjectButton(this.stateSetter, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool refresh = false;
    TextEditingController projectNameController = TextEditingController();
    return TextButton.icon(
      icon: const Icon(Icons.add),
      label: const Text("Create a New Project"),
      onPressed: () async {
        refresh = await DialogUtils().projectCreationDialog(
          context,
          projectNameController,
        );
        if (refresh) stateSetter();
      },
    );
  }
}

class DeleteProjectButton extends StatelessWidget {
  final VoidCallback stateSetter;
  final int projectID;
  const DeleteProjectButton(this.stateSetter, this.projectID, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      icon: const Icon(
        Icons.delete,
        color: Colors.red,
      ),
      label: const Text(
        ("Delete this Project"),
        style: TextStyle(color: Colors.red),
      ),
      onPressed: () async {
        bool refresh =
            await DialogUtils().projectDeletionDialog(context, projectID);
        if (refresh) (stateSetter());
      },
    );
  }
}

class ImportProjectButton extends StatelessWidget {
  final VoidCallback stateSetter;
  final int projectID;
  const ImportProjectButton(this.stateSetter, this.projectID, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      icon: const Icon(
        Icons.add,
        color: Colors.blue,
      ),
      label: const Text(
        ("Import Files"),
        style: TextStyle(color: Colors.blue),
      ),
      onPressed: () async {
        final result = await FilePicker.platform.pickFiles(
            allowMultiple: true,
            type: FileType.custom,
            allowedExtensions: ['csv']);
        //if user cancels, stop picking files and "break"
        if (result == null) return;

        //else, stores file
        final importedFile = result.files.iterator;

        //iterates over the files imported, reads them and copies their content to a savefile
        var dataBox = await Hive.openBox<Group>('groupBox');

        while (importedFile.moveNext()) {
          final File file = File(importedFile.current.path!);
          String fileContent = await file.readAsString();

          var fileLines = fileContent.split('\n');
          fileLines.removeAt(0); //deletes csv header
          const int groupColumnID = 4;
          const int size = 4;
          //parsing csv file to iterate over students
          for (int lineIndex = 0; lineIndex < fileLines.length; lineIndex++) {
            var currentLineContent = fileLines[lineIndex]
                .split(","); //split the csv line into its cells
            if (currentLineContent.length < size) {
              break;
            }
            final String studentID = currentLineContent[2];
            final String groupName = currentLineContent[groupColumnID]
                .replaceAll(RegExp('[^A-Za-z0-9]'), ''); //name of the group
            //checking if the student's group already exists
            if (dataBox.containsKey(groupName)) {
              //set the student as registered to the project
              var group = dataBox.get(groupName);
              for (Student student in group!.students) {
                //search the student in the group
                if (student.mailID == studentID) {
                  String studentName = student.name;
                  student.projects[projectID].setRegistration(
                      true, "'from project import for $studentName'");
                  break;
                }
              }
              group.save();
            }
          }
        }
        stateSetter();
      },
    );
  }
}

class ShuffleProjectGroupsButton extends StatelessWidget {
  final VoidCallback stateSetter;
  final int projectID;
  final bool ongoing;
  const ShuffleProjectGroupsButton(
      this.stateSetter, this.projectID, this.ongoing,
      {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!ongoing) {
      return const SizedBox.shrink();
    }

    return TextButton.icon(
      icon: const Icon(
        Icons.groups,
        color: Colors.green,
      ),
      label: const Text(
        ("Shuffle Students"),
        style: TextStyle(color: Colors.green),
      ),
      onPressed: () async {
        await DialogUtils().shuffleProjectGroups(context, projectID);
        stateSetter();
      },
    );
  }
}

class EnableGradingButton extends StatelessWidget {
  final VoidCallback stateSetter;
  final int projectID;
  final bool ongoing;
  const EnableGradingButton(this.stateSetter, this.projectID, this.ongoing,
      {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!ongoing) {
      return const SizedBox.shrink();
    }

    return TextButton.icon(
      icon: const Icon(
        Icons.pending_actions_outlined,
        color: Colors.blue,
      ),
      label: const Text(
        ("Enable Grading"),
        style: TextStyle(color: Colors.blue),
      ),
      onPressed: () async {
        await DialogUtils().enableGrading(context, projectID).then((refresh) {
          if (refresh) {
            stateSetter();
          }
        });
      },
    );
  }
}

class GradeEditBUtton extends StatelessWidget {
  final VoidCallback stateSetter;
  final bool ongoing;
  final int projectID;
  final int groupID;
  const GradeEditBUtton(
      this.stateSetter, this.ongoing, this.projectID, this.groupID,
      {Key? key})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    if (!ongoing) {
      return IconButton(
          splashRadius: 10,
          splashColor: Colors.redAccent,
          onPressed: () async {
            await DialogUtils().setGrades(context, projectID, groupID);
            stateSetter();
          },
          icon: const Icon(Icons.edit, size: 18),
          color: Colors.blue);
    } else {
      return const SizedBox.shrink();
    }
  }
}

class WorkGroupEditButton extends StatelessWidget {
  final VoidCallback stateSetter;
  final bool ongoing;
  final int projectID;
  final int groupID;
  final String mailID;
  const WorkGroupEditButton(
      this.stateSetter, this.ongoing, this.projectID, this.groupID, this.mailID,
      {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (ongoing) {
      return IconButton(
          splashRadius: 10,
          splashColor: Colors.redAccent,
          onPressed: () async {
            await DialogUtils()
                .setWorkGroup(context, mailID, projectID, groupID);
            stateSetter();
          },
          icon: const Icon(Icons.edit, size: 18),
          color: Colors.blue);
    } else {
      return const SizedBox.shrink();
    }
  }
}

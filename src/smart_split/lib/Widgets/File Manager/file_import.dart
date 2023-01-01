import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:hive/hive.dart';
import 'package:smart_split/Data/student.dart';
import 'package:smart_split/Data/group.dart';
import 'dart:io';

import 'package:smart_split/Utils/dialog_utils.dart';

class FileImport extends StatelessWidget {
  final VoidCallback stateSetter;
  const FileImport(this.stateSetter, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      icon: const Icon(Icons.add),
      label: const Text("Import Files"),
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
        var fileBox = await Hive.openBox<String>('fileBox');

        while (importedFile.moveNext()) {
          final File file = File(importedFile.current.path!);
          //name of the file currently read
          final String fileName = importedFile.current.name;
          //checking if a file with the same name has already been imported
          bool stop = false;
          for (String file in fileBox.values) {
            if (file == fileName) {
              debugPrint("File has probably already been imported");
              //skip will be true if user clicks on button skip, false if clicks on proceed
              await DialogUtils()
                  .duplicateFileAlertDialog(context, fileName)
                  .then((skip) {
                if (skip) {
                  stop = true;
                }
              });
            }
          }
          if (stop) {
            //if user skipped this file, continue will immediately jump to the next iteration of the loop (next file)
            continue;
          }

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
            assert(currentLineContent[0].isNotEmpty &&
                currentLineContent[1].isNotEmpty &&
                currentLineContent[2].isNotEmpty &&
                currentLineContent[4].isNotEmpty);
            final String groupName = currentLineContent[groupColumnID]
                .replaceAll(RegExp('[^A-Za-z0-9]'), ''); //name of the group
            final currentStudent = Student(
                currentLineContent[0],
                currentLineContent[1],
                currentLineContent[2],
                groupName,
                [],
                0); //Student currently being processed
            //checking if the student's group already exists
            if (dataBox.containsKey(groupName)) {
              //add the student to the group
              dataBox.get(groupName)?.addStudent(currentStudent);
            }
            // else, create a new group containing the student and store it in the DB
            else {
              dataBox.put(groupName, Group(groupName, [currentStudent]));
            }
          }
          //saving the name of the file
          fileBox.add(fileName);
          debugPrint("$fileName added to the file DB");
        }
        stateSetter();
      },
    );
  }
}

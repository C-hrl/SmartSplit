import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:smart_split/Utils/decorations.dart';
import 'package:smart_split/Widgets/File%20Manager/file_delete.dart';
import 'package:smart_split/Widgets/File%20Manager/file_export.dart';
import 'dart:io';
import 'package:smart_split/Widgets/File%20Manager/file_import.dart';

//class containing functions related to files
class FileUtils {
  //returns the local path where SmartSplit stores files and data
  Future<String> get localPath async {
    final directory = await getApplicationDocumentsDirectory();
    final String pathname = (directory.path + '\\SmartSplit');

    return pathname;
  }

  //checks if the file used to save data has already been created
  Future<bool> checkExistence(filePath) async {
    debugPrint('Checking file\'s existence');
    return File(filePath).exists();
  }

  //creates the folder containing SmartSplit's data
  void createFolder() async {
    await Directory(await FileUtils().localPath).create(recursive: true);
  }

  //creates the file needed the save the csv's content
  void createFile(filePath) async {
    debugPrint('File Created at $filePath');
    File(filePath).create(recursive: true);
  }
}

//Main body of File Manager
class FileManagerWidget extends StatefulWidget {
  const FileManagerWidget({Key? key}) : super(key: key);

  @override
  //creates a new state of _FileManager
  State<StatefulWidget> createState() => _FileManager();
}

class _FileManager extends State<FileManagerWidget> {
  //if this boolean is set to true, it will tell the widget to refresh
  // ignore: unused_field
  bool _refresh = false;
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      SizedBox(
          //width minus 300 to avoid having buttons too close to the left side
          width: MediaQuery.of(context).size.width - 300,
          height: 80,
          child: Column(
            children: [
              Text(
                "File Manager".toUpperCase(),
                textAlign: TextAlign.center,
                textScaleFactor: 2,
                style: const TextStyle(color: Colors.orange),
              ),
              Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    FileImport(refresh),
                    const ExportData(),
                    ClearStudentData(refresh)
                  ])
            ],
          )),
      const SeparationBar(
          fractionSize: 1,
          inputColor: Colors.orange,
          inputWidth: 2,
          isHorizontal: true),
      Expanded(
          child: FutureBuilder(
              future: Hive.openBox<String>('fileBox'),
              builder: (BuildContext context,
                  AsyncSnapshot<Box<String>> openedFileBox) {
                if (openedFileBox.hasData) {
                  return fileDisplay(openedFileBox);
                } else {
                  return const Center(
                      child: SizedBox(
                          child: CircularProgressIndicator(),
                          width: 50,
                          height: 50));
                }
              }))
    ]);
  }

  void refresh() {
    setState(() {
      _refresh = true;
      debugPrint("refreshing");
    });
  }

  Widget fileDisplay(openedFileBox) {
    Box<String> fileDB = openedFileBox.data as Box<String>;
    int nbOfFiles = fileDB.length;
    return ListView.builder(
        itemCount: nbOfFiles,
        itemBuilder: (context, index) {
          final String fileName = fileDB.getAt(index).toString();
          debugPrint("Displaying $fileName");
          return Card(
              elevation: 2,
              shadowColor: Colors.lightBlue,
              child: ListTile(
                leading: const Icon(
                  Icons.file_copy_outlined,
                  color: Colors.amber,
                  size: 30,
                ),
                title: Text(
                  fileName,
                  style: const TextStyle(fontSize: 15, color: Colors.green),
                ),
              ));
        });
  }
}

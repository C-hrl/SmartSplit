import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:smart_split/Data/group.dart';
import 'package:smart_split/Data/project.dart';
import 'package:smart_split/Utils/decorations.dart';
import 'package:smart_split/Widgets/Project%20Manager/project_buttons.dart';
import 'package:smart_split/Widgets/Project%20Manager/project_content_display.dart';

class ProjectManagerWidget extends StatefulWidget {
  const ProjectManagerWidget({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ProjectManager();
}

class _ProjectManager extends State<ProjectManagerWidget> {
  int _selectedProjectIndex = -1;
  // ignore: unused_field
  bool _hasBeenModified = false;
  TextEditingController projectNameController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      SizedBox(
        width: double.infinity,
        height: 80,
        child: Row(
          children: [
            CreateProjectButton(refreshAndSelectNewestGroup),
            projectDropDown(),
            const Spacer(),
            Builder(builder: (BuildContext context) {
              if (_selectedProjectIndex != -1) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    ImportProjectButton(refresh, _selectedProjectIndex),
                    DeleteProjectButton(
                        refreshAndDeselectGroup, _selectedProjectIndex)
                  ],
                );
              } else {
                //return "nothing"
                return const SizedBox.shrink();
              }
            })
          ],
        ),
      ),
      const SeparationBar(
          fractionSize: 1,
          inputColor: Colors.redAccent,
          inputWidth: 2,
          isHorizontal: true),
      Expanded(
        child: Builder(builder: (BuildContext context) {
          if (_selectedProjectIndex == -1) {
            return const Center(child: Text("No project selected"));
          }
          return ProjectContentWidget(_selectedProjectIndex);
        }),
      ),
    ]);
  }

  //used to refresh the widget
  void refresh() {
    setState(() {
      _hasBeenModified = true;
    });
  }

  //used to refresh the widget and deselect the current group (if it's being deleted for example)
  void refreshAndDeselectGroup() {
    setState(() {
      _selectedProjectIndex = -1;
    });
  }

  //used to refresh and display the newly created group
  void refreshAndSelectNewestGroup() async {
    await Hive.openBox<Group>('groupBox').then((db) {
      int nbOfProjects = db.getAt(0)!.students[0].projects.length;
      setState(() {
        _selectedProjectIndex = nbOfProjects - 1;
      });
    });
  }

  Widget projectDropDown() {
    return FutureBuilder(
        future: Hive.openBox<Group>('groupBox'),
        builder:
            (BuildContext context, AsyncSnapshot<Box<Group>> openedGroupBox) {
          List<DropdownMenuItem<int>> projectList = [];
          if (openedGroupBox.hasData) {
            final Box<Group> groupBox = openedGroupBox.data as Box<Group>;
            if (groupBox.isEmpty) {
              return Text(
                "Import students in File Manager in order to create groups"
                    .toUpperCase(),
                style: const TextStyle(color: Colors.red),
              );
            }
            if (groupBox.isNotEmpty) {
              //Default option/ used to deselect projects
              projectList.add(const DropdownMenuItem(
                  child: Text("No Project Selected",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  value: -1));

              int projectIndexCounter = 0;
              for (StudentProject project
                  in groupBox.getAt(0)!.students[0].projects) {
                projectList.add(DropdownMenuItem(
                    child: Text(
                      project.name.toUpperCase(),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent),
                    ),
                    value: projectIndexCounter));
                projectIndexCounter++;
              }
            }
          } else {
            return const CircularProgressIndicator();
          }
          return DropdownButton<int>(
              value: _selectedProjectIndex,
              items: projectList,
              onChanged: (value) =>
                  setState(() => _selectedProjectIndex = value!.toInt()));
        });
  }
}

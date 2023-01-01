// ignore_for_file: slash_for_doc_comments
import 'package:provider/provider.dart'; //easier management of states and rebuilding of widgets
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:smart_split/Widgets/Project%20Manager/project_manager.dart';
import 'package:smart_split/main.dart';

import 'package:smart_split/Widgets/File%20Manager/file_manager.dart';
import 'package:smart_split/Widgets/Student%20Manager/student_manager.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({Key? key}) : super(key: key);

  //left side menu

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: double.infinity,
      width: 240,
      child: Column(
        children: [
          Stack(
            children: [
              DrawerHeader(
                child: Image.asset(
                  'assets/logo.png',
                  height: 55,
                ),
              ),
              WindowTitleBarBox(child: SizedBox(child: MoveWindow())),
            ],
          ),
          const MenuOption(
              textTitle: 'File Manager',
              icon: Icon(Icons.insert_drive_file_outlined,
                  color: Colors.orangeAccent, size: 40),
              tileIndex: 0),
          const MenuOption(
              textTitle: 'Student Database',
              icon: Icon(Icons.person_pin_outlined,
                  color: Colors.blueAccent, size: 40),
              tileIndex: 1),
          const MenuOption(
              textTitle: 'Project Manager',
              icon: Icon(Icons.grading_rounded,
                  color: Colors.redAccent, size: 40),
              tileIndex: 2)
        ],
      ),
    );
  }
}

class MenuOption extends StatelessWidget {
  //template for tiles used as options in the left side menu
  const MenuOption(
      {required this.textTitle, //title of the tile
      required this.icon, //icon at the beginning of the tile
      required this.tileIndex, //index assigned to the tile
      Key? key})
      : super(key: key);
  final String textTitle;
  final Icon icon;
  final int tileIndex;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      horizontalTitleGap: 20,
      onTap: () {
        //Provider Index is changed and notifies watchers
        context.read<Index>().setIndex = tileIndex;
      },
      hoverColor: Theme.of(context).hintColor,
      leading: icon,
      title: Text(
        textTitle,
        textAlign: TextAlign.left,
        textScaleFactor: 0.9,
      ),
    );
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Column(children: [
      WindowTitleBarBox(
          child: Row(children: [
        Expanded(
          child: MoveWindow(),
        ),
        const WindowButtons()
      ])),
      const Expanded(child: RightWindowContentSelector())
    ]));
  }
}

//changes what has to be displayed in the main screen
class RightWindowContentSelector extends StatelessWidget {
  const RightWindowContentSelector({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //watcher is used to rebuild the main screen widget each time it is notified of a change
    switch (context.watch<Index>().getIndex) {
      case 0:
        return const FileManagerWidget();
      case 1:
        return const StudentManagerWidget();
      case 2:
        return const ProjectManagerWidget();
      default:
        return const Text("This page does not exist");
    }
  }
}

class WindowButtons extends StatelessWidget {
  const WindowButtons({Key? key}) : super(key: key);
  //Buttons at the top right of the app

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        MinimizeWindowButton(colors: buttonColors),
        MaximizeWindowButton(colors: buttonColors),
        CloseWindowButton(
          colors: buttonColors,
        )
      ],
    );
  }
}

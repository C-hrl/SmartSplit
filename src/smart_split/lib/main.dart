// ignore: slash_for_doc_comments
/**
 * @author: Bénimédourène Charles
 * @version: 1.0
 * This file contains the main body of the app
 */

import 'package:bitsdojo_window/bitsdojo_window.dart'; //used to make the top right buttons
import 'package:desktop_window/desktop_window.dart'; //default package to make desktop apps
import 'package:flutter/material.dart'; //default package
import 'package:provider/provider.dart'; //package containing listeners and notifiers
import 'package:smart_split/Data/group.dart';
import 'package:smart_split/Data/project.dart';
import 'package:smart_split/Data/student.dart';
import 'package:smart_split/Utils/decorations.dart'; //package containing decoration widgets
import 'package:smart_split/Widgets/File%20Manager/file_manager.dart';
import 'Widgets/main_app_screen.dart'; //package containing more detailed widgets (SideMenu, MainScreen, ...)
import 'package:hive/hive.dart'; //database

final buttonColors = WindowButtonColors(
    //color schemes for window buttons (top right)
    iconNormal: Colors.white,
    iconMouseOver: Colors.black,
    normal: Colors.grey.shade300,
    mouseOver: Colors.green,
    mouseDown: Colors.red);

class Index with ChangeNotifier {
  //class used to change the index of the selected page
  int selectedIndex = 0; //default index is 0 (Dashboard)

  int get getIndex {
    //getter
    return selectedIndex;
  }

  set setIndex(int newIndex) {
    //setter
    assert(newIndex >= 0);
    selectedIndex = newIndex;
    notifyListeners(); //notifies listenners (watchers) that the index has changed
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DesktopWindow.setMinWindowSize(const Size(1280, 720));

  var path = await FileUtils().localPath;
  Hive.init(path);
  Hive.registerAdapter(GroupAdapter());
  Hive.registerAdapter(StudentAdapter());
  Hive.registerAdapter(StudentProjectAdapter());

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(
          create: (_) => Index()), //setting up the notifier for the index
    ],
    child: const App(),
  ));
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartSplit',
      theme: ThemeData(
        //colors used by the app
        primaryColor: Colors.green.shade300,
        hintColor: Colors.grey.shade300,
        backgroundColor: Colors.white,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  //Main body/layout of the UI

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable, used as a provider for Index readers and watchers
    final appIndex = Provider.of<Index>(context);
    return Scaffold(
      body: Column(
        children: [
          Expanded(
              child: Row(children: [
            const SideMenu(), //dashboard menu on the left
            SeparationBar(
              fractionSize: 0.98,
              inputColor: Theme.of(context).primaryColor,
              isHorizontal: false,
              inputWidth: 3,
            ),
            const MainScreen(), //main screen on the right
          ])),
        ],
      ),
    );
  }
}

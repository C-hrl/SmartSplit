import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smart_split/Utils/dialog_utils.dart';

class ClearStudentData extends StatelessWidget {
  final VoidCallback stateSetter;
  const ClearStudentData(this.stateSetter, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      icon: const Icon(Icons.clear),
      label: const Text("Delete All Data"),
      onPressed: () async {
        await DialogUtils().deletionAlertDialog(context).then((refresh) {
          if (refresh) stateSetter();
        });
      },
    );
  }
}

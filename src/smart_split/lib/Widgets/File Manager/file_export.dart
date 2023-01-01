import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smart_split/Utils/dialog_utils.dart';

class ExportData extends StatelessWidget {
  const ExportData({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      icon: const Icon(Icons.downloading_rounded),
      label: const Text("Export Data"),
      onPressed: () async {
        await DialogUtils().exportDBDialog(context);
      },
    );
  }
}

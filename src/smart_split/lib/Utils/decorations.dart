// ignore: slash_for_doc_comments
/**
 * @author: Bénimédourène Charles
 * @version: 1.0
 * This file contains the following widgets:
 * SeparationBar: used to add decoration bars between widgets
 */

import 'package:flutter/cupertino.dart';

class SeparationBar extends StatelessWidget {
  //bars used to separate UI elements (ex: green bar between the side menu and the main screen)
  const SeparationBar(
      {Key? key,
      required this.fractionSize,
      required this.inputColor,
      required this.inputWidth,
      required this.isHorizontal})
      : super(key: key);

  final double fractionSize, inputWidth;
  final Color inputColor;
  final bool isHorizontal;

  @override
  Widget build(BuildContext context) {
    assert(fractionSize <= 1.0 && fractionSize > 0);
    //ensures the fraction given is accepted

    return FractionallySizedBox(
        widthFactor: isHorizontal ? fractionSize : null,
        heightFactor: isHorizontal ? null : fractionSize,
        child: SizedBox(
            width: isHorizontal ? null : inputWidth,
            height: isHorizontal ? inputWidth : null,
            child: Container(color: inputColor)));
  }
}

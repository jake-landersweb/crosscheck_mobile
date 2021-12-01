import 'package:flutter/material.dart';

extension ViewColors on Colors {
  static Color lightList = const Color.fromRGBO(242, 242, 248, 1);

  static Color darkList = const Color.fromRGBO(48, 48, 50, 1);

  static Color cellColor(BuildContext context) {
    if (MediaQuery.of(context).platformBrightness == Brightness.light) {
      return Colors.white;
    } else {
      return darkList;
    }
  }

  static Color textColor(BuildContext context) {
    if (MediaQuery.of(context).platformBrightness == Brightness.light) {
      return Colors.black;
    } else {
      return Colors.white;
    }
  }

  // static Color subCellColor(BuildContext context) {
  //   if (MediaQuery.of(context).platformBrightness == Brightness.light) {
  //     return lightList;
  //   } else {
  //     return Colors.white.withOpacity(0.05);
  //   }
  // }
}

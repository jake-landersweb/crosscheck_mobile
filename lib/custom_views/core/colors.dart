import 'package:flutter/material.dart';

extension ViewColors on Colors {
  static Color lightList = const Color.fromRGBO(242, 242, 248, 1);

  static Color darkList = const Color.fromRGBO(48, 48, 50, 1);

  static Color cellColor(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.light) {
      return Colors.white;
    } else {
      return darkList;
    }
  }

  static Color textColor(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.light) {
      return Colors.black;
    } else {
      return Colors.white;
    }
  }

  static Color backgroundColor(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.light) {
      return lightList;
    } else {
      return const Color.fromRGBO(30, 30, 33, 1);
    }
  }

  // static Color subCellColor(BuildContext context) {
  //   if (Theme.of(context).brightness == Brightness.light) {
  //     return lightList;
  //   } else {
  //     return Colors.white.withOpacity(0.05);
  //   }
  // }
}

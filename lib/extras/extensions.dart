import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:intl/intl.dart';

import 'root.dart';

extension NullCheck on String? {
  bool isEmpty() {
    if (this == null) {
      return true;
    } else if (this == "") {
      return true;
    } else {
      return false;
    }
  }
}

extension DateFormater on String {
  String getDate() {
    DateTime date = DateTime.parse(this);
    DateFormat format = DateFormat('E, MMM dd');
    return format.format(date);
  }

  String getTime() {
    DateTime date = DateTime.parse(this);
    DateFormat format = DateFormat('hh:mm a');
    return format.format(date);
  }

  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}

extension CustomColors on Colors {
  static Color lightList = const Color.fromRGBO(242, 242, 248, 1);
  static Color subLightList = const Color.fromRGBO(232, 232, 240, 1);

  static Color darkList = const Color.fromRGBO(28, 28, 30, 1);
  static Color subDarkList = const Color.fromRGBO(38, 38, 40, 1);

  static Color textColor(BuildContext context) {
    if (MediaQuery.of(context).platformBrightness == Brightness.light) {
      return Colors.black;
    } else {
      return Colors.white;
    }
  }

  static Color plainBackground(BuildContext context) {
    if (MediaQuery.of(context).platformBrightness == Brightness.light) {
      return Colors.white;
    } else {
      return Colors.black;
    }
  }

  static Color cellColor(BuildContext context) {
    if (MediaQuery.of(context).platformBrightness == Brightness.light) {
      return Colors.white;
    } else {
      return CustomColors.darkList;
    }
  }

  /// String is in the format "aabbcc" or "ffaabbcc" with an optional leading "#".
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  static Color random(String seed) {
    double num = 0;
    for (int i = 0; i < seed.length; i++) {
      num += intFromString(seed[i].toLowerCase()) / 3.2;
    }
    return Color((math.Random(num.toInt()).nextDouble() * 0xFFFFFF).toInt())
        .withOpacity(1.0);
  }

  /// Prefixes a hash sign if [leadingHashSign] is set to `true` (default is `true`).
  // String toHex({bool leadingHashSign = true}) => '${leadingHashSign ? '#' : ''}'
  //     '${alpha.toRadixString(16).padLeft(2, '0')}'
  //     '${red.toRadixString(16).padLeft(2, '0')}'
  //     '${green.toRadixString(16).padLeft(2, '0')}'
  //     '${blue.toRadixString(16).padLeft(2, '0')}';
}

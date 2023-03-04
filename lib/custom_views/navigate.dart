import 'package:crosscheck_sports/crosscheck_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'root.dart' as cv;

class Navigate extends Navigator {
  Navigate(BuildContext context, Widget body) {
    Navigator.push(
      context,
      MaterialWithModalsPageRoute(
        builder: (context) {
          return Scaffold(
            resizeToAvoidBottomInset: false,
            body: body,
          );
        },
      ),
    );
  }
}

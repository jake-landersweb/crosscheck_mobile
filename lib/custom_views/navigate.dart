import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class Navigate extends Navigator {
  Navigate(BuildContext context, Widget body) {
    if (kIsWeb) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Scaffold(
            resizeToAvoidBottomInset: false,
            body: body,
          ),
        ),
      );
    } else if (Platform.isIOS || Platform.isMacOS) {
      Navigator.push(
        context,
        CupertinoPageRoute(
          builder: (context) => Scaffold(
            resizeToAvoidBottomInset: false,
            body: body,
          ),
        ),
      );
    } else {
      // android, windows and linux
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Scaffold(
            resizeToAvoidBottomInset: false,
            body: body,
          ),
        ),
      );
    }
  }
}

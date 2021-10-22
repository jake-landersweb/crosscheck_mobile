import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class LoadingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return const Center(child: CircularProgressIndicator());
    } else {
      if (Platform.isIOS) {
        return const Center(child: CupertinoActivityIndicator());
      } else {
        return const Center(child: CircularProgressIndicator());
      }
    }
  }
}

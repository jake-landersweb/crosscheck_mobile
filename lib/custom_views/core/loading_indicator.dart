import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class LoadingIndicator extends StatelessWidget {
  final Color? color;

  const LoadingIndicator({
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return Center(child: CircularProgressIndicator(color: color));
    } else {
      if (Platform.isIOS) {
        return const Center(child: CupertinoActivityIndicator());
      } else {
        return Center(child: CircularProgressIndicator(color: color));
      }
    }
  }
}

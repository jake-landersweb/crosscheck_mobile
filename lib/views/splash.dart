import 'package:flutter/material.dart';

import '../custom_views/root.dart' as cv;

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: cv.LoadingIndicator()),
    );
  }
}

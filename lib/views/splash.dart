import 'package:flutter/material.dart';

import '../custom_views/root.dart' as cv;

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const SizedBox(
            width: double.infinity,
            height: double.infinity,
          ),
          Center(
              child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Image.asset("assets/launch/x.png", height: 267, width: 267),
          )),
        ],
      ),
    );
  }
}

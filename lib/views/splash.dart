import 'package:flutter/material.dart';

import '../custom_views/root.dart' as cv;

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.white,
          ),
          Center(child: Image.asset("assets/launch/PNTM_icon.png")),
        ],
      ),
    );
  }
}

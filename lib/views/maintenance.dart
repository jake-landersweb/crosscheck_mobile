import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class Maintenance extends StatelessWidget {
  const Maintenance({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset("assets/svg/maintenance.svg"),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "Oh No! Crosscheck Sports is under maintenance",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

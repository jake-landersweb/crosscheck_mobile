import 'package:flutter/material.dart';
import 'package:crosscheck_sports/extras/root.dart';
import '../../custom_views/root.dart' as cv;

class RosterAvatar extends StatelessWidget {
  const RosterAvatar(
      {super.key,
      required this.name,
      this.seed,
      this.size = 50,
      this.fontSize = 32,
      this.overrideColor});
  final String name;
  final String? seed;
  final double size;
  final double fontSize;
  final Color? overrideColor;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        cv.Circle(size,
            overrideColor ?? CustomColors.random(seed == null ? name : seed!)),
        Text(
          name.isNotEmpty ? name[0].toUpperCase() : "-",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: fontSize,
          ),
        ),
      ],
    );
  }
}

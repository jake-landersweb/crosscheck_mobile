import 'package:flutter/material.dart';
import 'package:pnflutter/data/root.dart';
import 'package:pnflutter/extras/root.dart';
import '../../custom_views/root.dart' as cv;
import 'root.dart';

class RosterAvatar extends StatelessWidget {
  const RosterAvatar({
    Key? key,
    required this.name,
    this.seed,
    this.size = 50,
    this.fontSize = 32,
  }) : super(key: key);
  final String name;
  final String? seed;
  final double size;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        cv.Circle(size, CustomColors.random(seed == null ? name : seed!)),
        Text(
          name[0].toUpperCase(),
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

import 'package:flutter/material.dart';

class Circle extends StatelessWidget {
  final double diameter;
  final Color color;
  Circle(this.diameter, this.color);
  @override
  Widget build(BuildContext context) {
    return Container(
      height: diameter,
      width: diameter,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}

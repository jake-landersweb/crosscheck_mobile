import 'package:flutter/material.dart';

class Circle extends StatelessWidget {
  final double diameter;
  final Color color;
  const Circle(this.diameter, this.color, {super.key});
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

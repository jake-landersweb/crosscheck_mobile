import 'package:flutter/material.dart';

class SwiftMaterial extends StatelessWidget {
  SwiftMaterial({
    Key? key,
    required this.color,
    required this.opacity,
  }) : super(key: key);

  SwiftMaterial.light(BuildContext context) {
    color = Theme.of(context).brightness == Brightness.light
        ? Colors.black
        : Colors.white;
    opacity = 0.1;
  }

  SwiftMaterial.regular(BuildContext context) {
    color = Theme.of(context).brightness == Brightness.light
        ? Colors.black
        : Colors.white;
    opacity = 0.2;
  }

  SwiftMaterial.heavy(BuildContext context) {
    color = Theme.of(context).brightness == Brightness.light
        ? Colors.black
        : Colors.white;
    opacity = 0.3;
  }

  late Color color;
  late double opacity;

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

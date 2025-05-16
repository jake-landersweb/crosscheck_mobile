import 'package:flutter/material.dart';

// ignore: must_be_immutable
class SwiftMaterial extends StatelessWidget {
  SwiftMaterial({
    super.key,
    required this.color,
    required this.opacity,
  });

  SwiftMaterial.light(BuildContext context, {super.key}) {
    color = Theme.of(context).brightness == Brightness.light
        ? Colors.black
        : Colors.white;
    opacity = 0.1;
  }

  SwiftMaterial.regular(BuildContext context, {super.key}) {
    color = Theme.of(context).brightness == Brightness.light
        ? Colors.black
        : Colors.white;
    opacity = 0.2;
  }

  SwiftMaterial.heavy(BuildContext context, {super.key}) {
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

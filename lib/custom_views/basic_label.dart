import 'package:flutter/material.dart';

class BasicLabel extends StatelessWidget {
  const BasicLabel({
    Key? key,
    required this.label,
  }) : super(key: key);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Theme.of(context).brightness == Brightness.light
            ? Colors.black.withOpacity(0.7)
            : Colors.white.withOpacity(0.7),
      ),
    );
  }
}
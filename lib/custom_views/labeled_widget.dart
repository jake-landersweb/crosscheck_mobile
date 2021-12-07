import 'package:flutter/material.dart';

class LabeledWidget extends StatelessWidget {
  const LabeledWidget(
    this.label, {
    Key? key,
    required this.child,
  }) : super(key: key);
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        child,
        const Spacer(),
        const SizedBox(height: 50),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: MediaQuery.of(context).platformBrightness == Brightness.light
                ? Colors.black.withOpacity(0.5)
                : Colors.white.withOpacity(0.5),
          ),
        ),
      ],
    );
  }
}

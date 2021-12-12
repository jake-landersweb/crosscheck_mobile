import 'package:flutter/material.dart';

class LabeledWidget extends StatelessWidget {
  const LabeledWidget(
    this.label, {
    Key? key,
    required this.child,
    this.height,
  }) : super(key: key);
  final String label;
  final Widget child;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Row(
        children: [
          child,
          const Spacer(),
          const SizedBox(height: 50),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color:
                  MediaQuery.of(context).platformBrightness == Brightness.light
                      ? Colors.black.withOpacity(0.5)
                      : Colors.white.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }
}

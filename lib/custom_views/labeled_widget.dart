import 'package:flutter/material.dart';

class LabeledWidget extends StatelessWidget {
  const LabeledWidget(
    this.label, {
    Key? key,
    required this.child,
    this.height,
    this.reversed = false,
  }) : super(key: key);
  final String label;
  final Widget child;
  final double? height;
  final bool reversed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: reversed
          ? Row(
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: MediaQuery.of(context).platformBrightness ==
                            Brightness.light
                        ? Colors.black.withOpacity(0.5)
                        : Colors.white.withOpacity(0.5),
                  ),
                ),
                const SizedBox(height: 50),
                Expanded(child: child),
              ],
            )
          : Row(
              children: [
                Expanded(child: child),
                const SizedBox(height: 50),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: MediaQuery.of(context).platformBrightness ==
                            Brightness.light
                        ? Colors.black.withOpacity(0.5)
                        : Colors.white.withOpacity(0.5),
                  ),
                ),
              ],
            ),
    );
  }
}

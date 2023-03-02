import 'package:flutter/material.dart';

class LabeledWidget extends StatelessWidget {
  const LabeledWidget(
    this.label, {
    Key? key,
    required this.child,
    this.height,
    this.reversed = false,
    this.isExpanded = true,
  }) : super(key: key);
  final String label;
  final Widget child;
  final double? height;
  final bool reversed;
  final bool isExpanded;

  @override
  Widget build(BuildContext context) {
    return reversed
        ? Row(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).brightness == Brightness.light
                      ? Colors.black.withOpacity(0.5)
                      : Colors.white.withOpacity(0.5),
                ),
              ),
              const SizedBox(height: 50),
              if (isExpanded)
                Expanded(child: child)
              else
                Row(
                  children: [
                    const Spacer(),
                    child,
                  ],
                ),
            ],
          )
        : Row(
            children: [
              if (isExpanded) Expanded(child: child),
              if (!isExpanded) child,
              if (!isExpanded) const Spacer(),
              const SizedBox(height: 50),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).brightness == Brightness.light
                      ? Colors.black.withOpacity(0.5)
                      : Colors.white.withOpacity(0.5),
                ),
              ),
            ],
          );
  }
}

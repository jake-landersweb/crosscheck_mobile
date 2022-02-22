import 'package:flutter/material.dart';
import 'package:pnflutter/custom_views/core/root.dart';

class LabeledCell extends StatelessWidget {
  const LabeledCell({
    Key? key,
    required this.label,
    required this.value,
    this.height,
    this.padding = const EdgeInsets.fromLTRB(0, 8, 0, 8),
    this.textColor,
  }) : super(key: key);
  final String label;
  final String value;
  final EdgeInsets padding;
  final double? height;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        children: [
          Expanded(
            child: SelectableText(
              value,
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w600, color: textColor),
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: ViewColors.textColor(context).withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }
}

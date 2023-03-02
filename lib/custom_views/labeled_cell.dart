import 'package:flutter/material.dart';
import 'package:crosscheck_sports/custom_views/core/root.dart';

class LabeledCell extends StatelessWidget {
  const LabeledCell({
    Key? key,
    required this.label,
    required this.value,
    this.height = 50,
    this.textColor,
  }) : super(key: key);
  final String label;
  final String value;
  final double height;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SelectableText(
            value,
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.w500, color: textColor),
          ),
        ),
        SizedBox(height: height),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color:
                (textColor == null ? ViewColors.textColor(context) : textColor!)
                    .withOpacity(0.5),
          ),
        ),
      ],
    );
  }
}

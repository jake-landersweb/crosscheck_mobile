import 'package:flutter/material.dart';
import 'package:pnflutter/custom_views/core/root.dart';

class LabeledCell extends StatelessWidget {
  const LabeledCell({
    Key? key,
    required this.label,
    required this.value,
    this.padding = const EdgeInsets.fromLTRB(0, 8, 0, 8),
  }) : super(key: key);
  final String label;
  final String value;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        children: [
          Expanded(
            child: SelectableText(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: ViewColors.textColor(context).withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}

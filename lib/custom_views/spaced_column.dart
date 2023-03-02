import 'package:flutter/material.dart';

class SpacedColumn extends StatelessWidget {
  const SpacedColumn({
    Key? key,
    required this.children,
    this.spacing = 16,
    this.hasTopSpacing = false,
  }) : super(key: key);

  final List<Widget> children;
  final double spacing;
  final bool hasTopSpacing;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (children.length > 0 && hasTopSpacing) SizedBox(height: spacing),
        for (Widget i in children)
          Column(
            children: [
              i,
              if (i != children.last) SizedBox(height: spacing),
            ],
          )
      ],
    );
  }
}

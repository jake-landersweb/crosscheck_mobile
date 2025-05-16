import 'package:flutter/material.dart';

class SpacedColumn extends StatelessWidget {
  const SpacedColumn({
    super.key,
    required this.children,
    this.spacing = 16,
    this.hasTopSpacing = false,
  });

  final List<Widget> children;
  final double spacing;
  final bool hasTopSpacing;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (children.isNotEmpty && hasTopSpacing) SizedBox(height: spacing),
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

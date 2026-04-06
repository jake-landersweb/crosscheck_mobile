import 'package:flutter/material.dart';

/// A gradient overlay that creates a soft fade effect over scrolling content.
///
/// Used behind header bars to smoothly blend the bar area into the content
/// below. The gradient transitions from mostly opaque at the top to fully
/// transparent at the bottom.
///
/// Must be placed inside a [Stack] and positioned by the caller.
class XCHeaderGradient extends StatelessWidget {
  const XCHeaderGradient({super.key, required this.color});

  /// The base color for the gradient (typically the page background).
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              color.withValues(alpha: 0.85),
              color.withValues(alpha: 0.85),
              color.withValues(alpha: 0.5),
              color.withValues(alpha: 0),
            ],
            stops: const [0.0, 0.4, 0.7, 1.0],
          ),
        ),
      ),
    );
  }
}

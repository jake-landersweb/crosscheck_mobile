import 'package:flutter/material.dart';

/// A small adaptive loading spinner in the new UI style.
///
/// Replaces the legacy `cv.LoadingIndicator` from
/// `custom_views/core/loading_indicator.dart`.
class XCLoadingIndicator extends StatelessWidget {
  const XCLoadingIndicator({super.key, this.color, this.size = 18});

  final Color? color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator.adaptive(
          strokeWidth: 2,
          valueColor:
              color == null ? null : AlwaysStoppedAnimation<Color>(color!),
        ),
      ),
    );
  }
}

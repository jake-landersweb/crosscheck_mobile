import 'package:flutter/material.dart';
import 'core/root.dart' as cv;

class ListAppearance extends StatelessWidget {
  const ListAppearance({
    super.key,
    required this.child,
    this.onTap,
    this.minHeight = 50,
    this.childPadding = const EdgeInsets.symmetric(horizontal: 16),
    this.backgroundColor,
  });
  final Widget child;
  final VoidCallback? onTap;
  final double minHeight;
  final EdgeInsets childPadding;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    if (onTap == null) {
      return _wrapper(context);
    } else {
      return cv.BasicButton(
        onTap: onTap,
        child: _wrapper(context),
      );
    }
  }

  Widget _wrapper(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: backgroundColor ?? cv.ViewColors.cellColor(context),
      ),
      width: double.infinity,
      child: Padding(
        padding: childPadding,
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: minHeight),
          child: Center(child: child),
        ),
      ),
    );
  }
}

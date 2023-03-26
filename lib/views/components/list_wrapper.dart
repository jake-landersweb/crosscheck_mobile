import 'package:crosscheck_sports/extras/root.dart';
import 'package:flutter/material.dart';

class ListWrapper extends StatelessWidget {
  const ListWrapper({
    super.key,
    required this.child,
    this.minHeight = 50,
    this.borderRadius = 10,
    this.wrapper,
    this.center = true,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
  });
  final Widget child;
  final double minHeight;
  final double borderRadius;
  final Widget Function(BuildContext context, Widget child)? wrapper;
  final bool center;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
        constraints: BoxConstraints(
          minHeight: minHeight,
        ),
        decoration: BoxDecoration(
          color: CustomColors.cellColor(context),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Padding(
          padding: padding,
          child: wrapper == null
              ? center
                  ? Center(child: child)
                  : child
              : wrapper!(context, child),
        ));
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:sprung/sprung.dart';

/// Shows a floating sheet with padding based on the platform
class FloatingSheet extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;

  const FloatingSheet({
    Key? key,
    required this.child,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double bottomPadding = MediaQuery.of(context).viewPadding.bottom;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      curve: Sprung(36),
      padding: EdgeInsets.only(
          bottom: (MediaQuery.of(context).viewInsets.bottom -
                      MediaQuery.of(context).viewPadding.bottom) <
                  0
              ? 0
              : (MediaQuery.of(context).viewInsets.bottom - bottomPadding)),
      child: Padding(
        padding: EdgeInsets.fromLTRB(10, 0, 10, bottomPadding + 10),
        child: Material(
          color: backgroundColor,
          clipBehavior: Clip.antiAlias,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: child,
        ),
      ),
    );
  }
}

/// Presents a floating model.
Future<T> showFloatingSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  Color? backgroundColor,
  bool useRootNavigator = false,
  Curve? curve,
  bool? isDismissable,
  bool enableDrag = true,
}) async {
  final result = await showCustomModalBottomSheet(
    isDismissible: isDismissable ?? true,
    context: context,
    builder: builder,
    enableDrag: enableDrag,
    animationCurve: curve ?? Sprung(36),
    duration: const Duration(milliseconds: 500),
    containerWidget: (_, animation, child) => FloatingSheet(
      child: child,
      backgroundColor: backgroundColor,
    ),
    expand: false,
    useRootNavigator: useRootNavigator,
  );

  return result;
}

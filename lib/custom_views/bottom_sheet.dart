import 'dart:io';
import 'package:crosscheck_sports/client/root.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:sprung/sprung.dart';
import 'package:provider/provider.dart';

class BottomSheet extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;

  const BottomSheet({
    Key? key,
    required this.child,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      curve: Sprung(36),
      child: child,
    );
  }
}

/// Presents a floating model.
// Future<T> showBottomSheet<T>({
//   required BuildContext context,
//   required WidgetBuilder builder,
//   required TickerProvider vsync,
//   Color? backgroundColor,
//   bool useRootNavigator = false,
//   Curve? curve,
//   bool? isDismissable,
//   bool enableDrag = true,
//   bool? reScaleScreen,
// }) async {
//   AnimationController controller = AnimationController(vsync: vsync);
//   controller.duration = const Duration(milliseconds: 400);
//   controller.reverseDuration = const Duration(milliseconds: 400);
//   controller.drive(CurveTween(curve: Sprung(36)));
//   final result = await showModalBottomSheet(
//     isDismissible: isDismissable ?? true,
//     transitionAnimationController: controller,
//     context: context,
//     builder: builder,
//     enableDrag: enableDrag,
//     isScrollControlled: true,
//     useRootNavigator: useRootNavigator,
//   );

//   return result;
// }

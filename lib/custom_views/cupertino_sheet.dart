import 'dart:math';

import 'package:crosscheck_sports/crosscheck_engine.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:sprung/sprung.dart';

void cupertinoSheet({
  required BuildContext context,
  required Widget Function(BuildContext context) builder,
  bool expand = false,
  bool resizeToAvoidBottomInset = true,
  bool wrapInNavigator = false,
  bool isDismissible = true,
  bool enableDrag = true,
}) {
  showCupertinoModalBottomSheet(
    context: context,
    builder: (context) => wrapInNavigator
        ? Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            resizeToAvoidBottomInset: resizeToAvoidBottomInset,
            body: Navigator(
              onGenerateRoute: (_) => MaterialPageRoute(
                builder: (context) => Builder(builder: builder),
              ),
            ),
          )
        : Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            resizeToAvoidBottomInset: resizeToAvoidBottomInset,
            body: builder(context),
          ),
    expand: expand,
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    animationCurve: Sprung(36),
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    previousRouteAnimationCurve: Sprung(36),
    duration: const Duration(milliseconds: 500),
  );
}

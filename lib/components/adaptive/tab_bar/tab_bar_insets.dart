import 'package:flutter/material.dart';

/// Provides the height of the tab bar overlay to descendant widgets.
///
/// Used by pages inside the tab shell (e.g. chat) to add bottom padding
/// so content isn't obscured by the floating tab bar.
class TabBarInsets extends InheritedWidget {
  const TabBarInsets({
    super.key,
    required this.height,
    required super.child,
  });

  /// Total height of the tab bar (including safe area / home indicator).
  final double height;

  static double of(BuildContext context) {
    final widget = context.dependOnInheritedWidgetOfExactType<TabBarInsets>();
    return widget?.height ?? 0;
  }

  @override
  bool updateShouldNotify(TabBarInsets oldWidget) => height != oldWidget.height;
}

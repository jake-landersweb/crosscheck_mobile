import 'package:flutter/material.dart';
import 'package:stupid_simple_sheet/stupid_simple_sheet.dart';

/// Pushes a snapping sheet route imperatively.
///
/// Use this when you need to show a sheet via [Navigator.push] instead of
/// declarative routing.
Future<T?> showSnappingSheet<T>({
  required BuildContext context,
  required Widget child,
  SheetSnapConfig snapConfig = SheetSnapConfig.full,
  double borderRadius = 40.0,
  bool draggable = true,
  Color? barrierColor = const Color.fromRGBO(0, 0, 0, 0.2),
  bool rootNavigator = false,
}) {
  return Navigator.of(context, rootNavigator: rootNavigator).push<T>(
    _ClampedSheetRoute<T>(
      motion: CupertinoMotion.smooth(),
      snappingConfig: snapConfig.resolve(),
      draggable: draggable,
      barrierColor: barrierColor,
      child: _SafeAreaSheetWrapper(borderRadius: borderRadius, child: child),
    ),
  );
}

/// Configuration for sheet snapping behavior.
class SheetSnapConfig {
  /// Relative snap points as fractions of screen height (e.g., [0.5, 1.0]).
  final List<double> snapPoints;

  /// Initial snap point index.
  final double initialSnap;

  /// When true, [snapPoints] and [initialSnap] are in pixels instead of
  /// relative fractions.
  final bool usePixels;

  const SheetSnapConfig({
    required this.snapPoints,
    required this.initialSnap,
    this.usePixels = false,
  });

  /// Half-screen and full-screen snapping, starting at half.
  static const halfAndFull = SheetSnapConfig(
    snapPoints: [0.5, 1.0],
    initialSnap: 0.5,
  );

  /// Half-screen and full-screen snapping, starting at half.
  static const semiAndFull = SheetSnapConfig(
    snapPoints: [0.7, 1.0],
    initialSnap: 0.7,
  );

  /// Full-screen only.
  static const full = SheetSnapConfig(snapPoints: [1.0], initialSnap: 1.0);

  /// Build the appropriate [SheetSnappingConfig] for the sheet library.
  SheetSnappingConfig resolve() {
    if (usePixels) {
      return SheetSnappingConfig.pixels(snapPoints, initialSnap: initialSnap);
    }
    return SheetSnappingConfig.relative(snapPoints, initialSnap: initialSnap);
  }
}

/// A [Page] that displays content in a snapping sheet anchored to safe area.
///
/// Uses [StupidSimpleSheetRoute] under the hood with proper safe area handling
/// and rounded superellipse clipping.
///
/// Example usage with go_router:
/// ```dart
/// GoRoute(
///   path: 'details/:id',
///   pageBuilder: (context, state) => SnappingSheetPage(
///     key: state.pageKey,
///     child: DetailsContent(),
///     snapConfig: SheetSnapConfig.halfAndFull,
///   ),
/// ),
/// ```
class SnappingSheetPage<T> extends Page<T> {
  final Widget child;
  final SheetSnapConfig snapConfig;
  final double borderRadius;
  final bool draggable;
  final Color? barrierColor;

  const SnappingSheetPage({
    required this.child,
    this.snapConfig = SheetSnapConfig.halfAndFull,
    this.borderRadius = 40.0,
    this.draggable = true,
    this.barrierColor = const Color.fromRGBO(0, 0, 0, 0.2),
    super.key,
    super.name,
    super.arguments,
    super.restorationId,
  });

  @override
  Route<T> createRoute(BuildContext context) {
    return _ClampedSheetRoute<T>(
      settings: this,
      motion: CupertinoMotion.smooth(),
      snappingConfig: snapConfig.resolve(),
      draggable: draggable,
      barrierColor: barrierColor,
      child: _SafeAreaSheetWrapper(borderRadius: borderRadius, child: child),
    );
  }
}

/// A [Page] variant that allows touch pass-through above the sheet.
///
/// Identical to [SnappingSheetPage] in styling, animation, and snapping behavior,
/// but overrides the modal barrier to allow gestures to reach underlying routes
/// (e.g., a map). Used for the recommendation detail sheet on the map view.
class PassThroughSheetPage<T> extends Page<T> {
  final Widget child;
  final SheetSnapConfig snapConfig;
  final double borderRadius;
  final bool draggable;

  const PassThroughSheetPage({
    required this.child,
    this.snapConfig = SheetSnapConfig.halfAndFull,
    this.borderRadius = 40.0,
    this.draggable = true,
    super.key,
    super.name,
    super.arguments,
    super.restorationId,
  });

  @override
  Route<T> createRoute(BuildContext context) {
    return _PassThroughSheetRoute<T>(
      settings: this,
      motion: CupertinoMotion.smooth(),
      snappingConfig: snapConfig.resolve(),
      draggable: draggable,
      child: _SafeAreaSheetWrapper(borderRadius: borderRadius, child: child),
    );
  }
}

/// A [StupidSimpleSheetRoute] that fixes the upstream overshoot recovery bug.
///
/// The library's `_handleDragEnd` creates a spring simulation without an
/// explicit `end` target when recovering from an overshoot drag, causing the
/// sheet to settle at 1.0 instead of the configured max snap point.
///
/// This subclass adds a value listener that detects when a post-release
/// animation is running above maxExtent and replaces it with a correctly
/// targeted animation back to maxExtent. The drag resistance interaction is
/// fully preserved because the listener only acts while `isAnimating` is true
/// (simulation-driven), not during imperative drag updates.
class _ClampedSheetRoute<T> extends StupidSimpleSheetRoute<T> {
  _ClampedSheetRoute({
    required super.child,
    super.motion,
    super.snappingConfig,
    super.draggable,
    super.settings,
    super.barrierColor,
    super.barrierDismissible,
  });

  bool _listenerAttached = false;
  bool _correcting = false;

  @override
  TickerFuture didPush() {
    _attachListener();
    return super.didPush();
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    _attachListener();
    return super.buildTransitions(
      context,
      animation,
      secondaryAnimation,
      child,
    );
  }

  void _attachListener() {
    if (!_listenerAttached && controller != null) {
      _listenerAttached = true;
      controller!.addListener(_onValueChanged);
    }
  }

  void _onValueChanged() {
    // Reset the correction flag when the user starts a new drag (value is
    // being set imperatively, so isAnimating becomes false).
    if (!controller!.isAnimating) {
      _correcting = false;
      return;
    }

    // Already replaced the animation for this overshoot — don't re-trigger.
    if (_correcting) return;

    final ctx = navigator?.context;
    if (ctx == null) return;

    final maxExtent = effectiveSnappingConfig.resolveWith(ctx).maxExtent;

    if (controller!.value > maxExtent + 0.001) {
      _correcting = true;
      // Replace the bad simulation (no end target) with one that targets
      // maxExtent. This fires once per overshoot release.
      controller!.animateWith(
        motion.createSimulation(start: controller!.value, end: maxExtent),
      );
    }
  }

  @override
  void dispose() {
    controller?.removeListener(_onValueChanged);
    super.dispose();
  }
}

/// A [StupidSimpleSheetRoute] that removes the modal barrier entirely,
/// allowing touch events to pass through to underlying routes.
///
/// Inherits overshoot correction from [_ClampedSheetRoute].
class _PassThroughSheetRoute<T> extends _ClampedSheetRoute<T> {
  _PassThroughSheetRoute({
    required super.child,
    super.motion,
    super.snappingConfig,
    super.draggable,
    super.settings,
  }) : super(barrierColor: null, barrierDismissible: false);

  @override
  Widget buildModalBarrier() {
    return const SizedBox.shrink();
  }
}

/// A [Page] that displays content in a dynamically-sized sheet.
///
/// Unlike [SnappingSheetPage], this does not snap to fixed positions. The sheet
/// sizes to its content and can be dragged to dismiss. Ideal for action menus
/// and other compact content.
class DynamicSheetPage<T> extends Page<T> {
  final Widget child;
  final double borderRadius;
  final Color? barrierColor;

  const DynamicSheetPage({
    required this.child,
    this.borderRadius = 40.0,
    this.barrierColor = const Color.fromRGBO(0, 0, 0, 0.2),
    super.key,
    super.name,
    super.arguments,
    super.restorationId,
  });

  @override
  Route<T> createRoute(BuildContext context) {
    return StupidSimpleSheetRoute<T>(
      settings: this,
      motion: CupertinoMotion.smooth(),
      originateAboveBottomViewInset: true,
      draggable: true,
      barrierColor: barrierColor,
      barrierDismissible: true,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
          child: ClipPath(
            clipper: ShapeBorderClipper(
              shape: RoundedSuperellipseBorder(
                borderRadius: BorderRadius.circular(borderRadius),
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Wrapper that sizes the sheet to safe area bounds and applies clipping.
class _SafeAreaSheetWrapper extends StatelessWidget {
  final Widget child;
  final double borderRadius;

  const _SafeAreaSheetWrapper({
    required this.child,
    required this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final height = mediaQuery.size.height - mediaQuery.padding.top;

    return SizedBox(
      height: height,
      child: MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: ClipPath(
          clipper: ShapeBorderClipper(
            shape: RoundedSuperellipseBorder(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(borderRadius),
              ),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

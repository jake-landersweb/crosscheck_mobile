import 'package:crosscheck_sports/components/core/container.dart';
import 'package:flutter/material.dart';
import 'package:motor/motor.dart';

/// An animated variant of [XCContainer] that adds interaction "pop",
/// content cross-fade, and smooth color/size transitions when properties change.
///
/// Swap detection uses [Widget.canUpdate] — provide different keys or widget
/// types to trigger transitions (identical to [AnimatedSwitcher] semantics).
class XCAnimatedContainer extends StatefulWidget {
  const XCAnimatedContainer({
    super.key,
    this.topLeft = XCContainerRadius.large,
    this.topRight = XCContainerRadius.large,
    this.bottomLeft = XCContainerRadius.large,
    this.bottomRight = XCContainerRadius.large,
    required this.child,
    this.onTap,
    this.label,
    this.height,
    this.width,
    this.color,
    this.interactionScale,
    this.padding = EdgeInsets.zero,
    this.innerPadding = EdgeInsets.zero,
    this.customRadius,
    this.interactionMode = XCInteractionMode.scale,
    this.borderColor,
    this.borderWidth = 2.0,
    this.tintColor,
    this.popScale = 1.15,
  });

  const XCAnimatedContainer.custom({
    super.key,
    this.topLeft = XCContainerRadius.custom,
    this.topRight = XCContainerRadius.custom,
    this.bottomLeft = XCContainerRadius.custom,
    this.bottomRight = XCContainerRadius.custom,
    required this.child,
    required this.customRadius,
    this.onTap,
    this.label,
    this.height,
    this.width,
    this.color,
    this.interactionScale,
    this.padding = EdgeInsets.zero,
    this.innerPadding = EdgeInsets.zero,
    this.interactionMode = XCInteractionMode.scale,
    this.borderColor,
    this.borderWidth = 2.0,
    this.tintColor,
    this.popScale = 1.15,
  });

  const XCAnimatedContainer.small({
    super.key,
    this.topLeft = XCContainerRadius.small,
    this.topRight = XCContainerRadius.small,
    this.bottomLeft = XCContainerRadius.small,
    this.bottomRight = XCContainerRadius.small,
    required this.child,
    this.onTap,
    this.label,
    this.height,
    this.width,
    this.color,
    this.interactionScale,
    this.padding = EdgeInsets.zero,
    this.innerPadding = EdgeInsets.zero,
    this.customRadius,
    this.interactionMode = XCInteractionMode.scale,
    this.borderColor,
    this.borderWidth = 2.0,
    this.tintColor,
    this.popScale = 1.15,
  });

  final XCContainerRadius topLeft;
  final XCContainerRadius topRight;
  final XCContainerRadius bottomLeft;
  final XCContainerRadius bottomRight;

  final Widget child;
  final void Function()? onTap;
  final String? label;
  final double? height;
  final double? width;
  final Color? color;
  final double? interactionScale;
  final EdgeInsets padding;
  final EdgeInsets innerPadding;
  final double? customRadius;
  final XCInteractionMode interactionMode;
  final Color? borderColor;
  final double borderWidth;
  final Color? tintColor;

  /// Peak scale during the pop pulse (1.15 = 15% overshoot).
  final double popScale;

  @override
  State<XCAnimatedContainer> createState() => _XCAnimatedContainerState();
}

class _XCAnimatedContainerState extends State<XCAnimatedContainer>
    with SingleTickerProviderStateMixin {
  static const _fadeDuration = Duration(milliseconds: 200);

  /// How long the target stays at [popScale] before releasing back to 1.0.
  /// This gives the spring time to build real velocity so the overshoot
  /// and oscillation are visible and fluid.
  static const _popHoldDuration = Duration(milliseconds: 80);

  // --- Cross-fade ---
  late AnimationController _fadeController;
  late Animation<double> _fadeIn;
  late Animation<double> _fadeOut;
  Widget? _outgoingChild;

  // --- Pop bounce (spring-driven) ---
  double _popTarget = 1.0;
  int _popId = 0;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(vsync: this, duration: _fadeDuration)
      ..addStatusListener(_onFadeStatus);

    _fadeIn = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);
    _fadeOut = CurvedAnimation(
      parent: ReverseAnimation(_fadeController),
      curve: Curves.easeOut,
    );
  }

  @override
  void didUpdateWidget(XCAnimatedContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    bool shouldPop = false;

    // Child change → cross-fade + pop
    if (!Widget.canUpdate(oldWidget.child, widget.child)) {
      _outgoingChild = oldWidget.child;
      _fadeController.forward(from: 0.0);
      shouldPop = true;
    }

    // Color/border/tint change → pop
    if (oldWidget.color != widget.color ||
        oldWidget.borderColor != widget.borderColor ||
        oldWidget.tintColor != widget.tintColor) {
      shouldPop = true;
    }

    // Size change → pop
    if (oldWidget.height != widget.height || oldWidget.width != widget.width) {
      shouldPop = true;
    }

    if (shouldPop) _triggerPop();
  }

  /// Displaces the spring target to [popScale] and holds it there briefly so
  /// the spring builds velocity. When released back to 1.0, the spring
  /// naturally overshoots and oscillates — producing a fluid, bouncy pop.
  void _triggerPop() {
    _popId++;
    final id = _popId;
    setState(() => _popTarget = widget.popScale);
    Future.delayed(_popHoldDuration, () {
      if (mounted && _popId == id) {
        setState(() => _popTarget = 1.0);
      }
    });
  }

  void _onFadeStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      setState(() => _outgoingChild = null);
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Widget _buildChildContent() {
    if (_outgoingChild == null) return widget.child;

    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        // Incoming child — non-positioned, determines the Stack size.
        FadeTransition(opacity: _fadeIn, child: widget.child),
        // Outgoing child — positioned so it doesn't affect Stack sizing.
        // OverflowBox lets it keep its natural width (prevents text wrapping
        // when the Stack shrinks to the incoming child's size).
        Positioned.fill(
          child: OverflowBox(
            alignment: Alignment.center,
            maxWidth: double.infinity,
            child: IgnorePointer(
              child: FadeTransition(opacity: _fadeOut, child: _outgoingChild!),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectiveColor = widget.color;
    final effectiveBorderColor = widget.borderColor;

    // Animate background color
    return MotionBuilder<Color>(
      value: effectiveColor ?? Colors.transparent,
      motion: const Motion.smoothSpring(snapToEnd: true),
      converter: const ColorRgbMotionConverter(),
      builder: (context, animatedColor, _) {
        // Animate border color
        return MotionBuilder<Color>(
          value: effectiveBorderColor ?? Colors.transparent,
          motion: const Motion.smoothSpring(snapToEnd: true),
          converter: const ColorRgbMotionConverter(),
          builder: (context, animatedBorderColor, _) {
            // Pop bounce — real spring physics via motor.
            // The target is displaced to popScale briefly, giving the
            // spring time to accelerate. When released, the spring
            // overshoots and oscillates back to 1.0 naturally.
            return SingleMotionBuilder(
              value: _popTarget,
              motion: const Motion.bouncySpring(),
              builder: (context, scale, _) {
                return Transform.scale(
                  scale: scale,
                  child: AnimatedSize(
                    clipBehavior: Clip.none,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: XCContainer(
                      topLeft: widget.topLeft,
                      topRight: widget.topRight,
                      bottomLeft: widget.bottomLeft,
                      bottomRight: widget.bottomRight,
                      onTap: widget.onTap,
                      label: widget.label,
                      height: widget.height,
                      width: widget.width,
                      color: effectiveColor != null ? animatedColor : null,
                      interactionScale: widget.interactionScale,
                      padding: widget.padding,
                      innerPadding: widget.innerPadding,
                      customRadius: widget.customRadius,
                      interactionMode: widget.interactionMode,
                      borderColor: effectiveBorderColor != null
                          ? animatedBorderColor
                          : null,
                      borderWidth: widget.borderWidth,
                      tintColor: widget.tintColor,
                      child: _buildChildContent(),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

import 'package:crosscheck_sports/style/theme.dart';
import 'package:flutter/material.dart';

/// A reusable tap effect wrapper that provides animated feedback on tap.
///
/// Wraps any widget with a subtle tap animation that includes:
/// - Background color fade
/// - Border appearance
/// - Horizontal padding squeeze
///
/// Use this to add consistent tap feedback to custom buttons or list items.
///
/// Example:
/// ```dart
/// XCTapEffect(
///   onTap: () => print('Tapped!'),
///   borderRadius: 12,
///   child: Padding(
///     padding: EdgeInsets.all(16),
///     child: Text('Tap me'),
///   ),
/// )
/// ```
class XCTapEffect extends StatefulWidget {
  /// The widget to wrap with the tap effect.
  final Widget child;

  /// Callback when the widget is tapped.
  /// If null, the tap effect is disabled.
  final VoidCallback? onTap;

  /// The border radius for the effect decoration.
  /// If null, uses the theme's large radius.
  final double? borderRadius;

  /// Per-corner border radius. When provided, takes precedence over [borderRadius].
  final BorderRadius? customBorderRadius;

  /// Whether to show the border on tap.
  /// Defaults to true.
  final bool showBorder;

  /// Whether to apply the horizontal padding squeeze effect.
  /// Defaults to true.
  final bool showPaddingSqueeze;

  /// Base background color for the container.
  /// When provided, XCTapEffect manages the background color and animates
  /// a highlight overlay on tap.
  final Color? backgroundColor;

  const XCTapEffect({
    super.key,
    required this.child,
    this.onTap,
    this.borderRadius,
    this.customBorderRadius,
    this.showBorder = true,
    this.showPaddingSqueeze = true,
    this.backgroundColor,
  });

  @override
  State<XCTapEffect> createState() => _XCTapEffectState();
}

class _XCTapEffectState extends State<XCTapEffect>
    with TickerProviderStateMixin {
  late AnimationController _bgController;
  late AnimationController _borderController;
  late AnimationController _paddingController;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _borderController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _paddingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 50),
      reverseDuration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _bgController.dispose();
    _borderController.dispose();
    _paddingController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _bgController.value = 1.0;
    if (widget.showBorder) _borderController.value = 1.0;
    if (widget.showPaddingSqueeze) _paddingController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _bgController.reverse();
    if (widget.showBorder) _borderController.reverse();
    if (widget.showPaddingSqueeze) {
      // Ensure padding animation completes before reversing
      _paddingController.forward().then((_) {
        if (mounted) _paddingController.reverse();
      });
    }
  }

  void _handleTapCancel() {
    _bgController.reverse();
    if (widget.showBorder) _borderController.reverse();
    if (widget.showPaddingSqueeze) _paddingController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = XCTheme.of(context);
    final effectiveRadius =
        widget.customBorderRadius ??
        BorderRadius.circular(widget.borderRadius ?? theme.radius.large);

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: widget.onTap != null ? _handleTapDown : null,
      onTapUp: widget.onTap != null ? _handleTapUp : null,
      onTapCancel: widget.onTap != null ? _handleTapCancel : null,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _bgController,
          _borderController,
          _paddingController,
        ]),
        builder: (context, child) {
          // When backgroundColor is provided, blend the tap highlight on top
          final bgColor = widget.backgroundColor != null
              ? Color.lerp(
                  widget.backgroundColor,
                  theme.border,
                  _bgController.value * 0.3,
                )!
              : theme.border.withValues(alpha: _bgController.value);

          Widget result = DecoratedBox(
            decoration: ShapeDecoration(
              color: bgColor,
              shape: RoundedSuperellipseBorder(
                borderRadius: effectiveRadius,
                side: widget.showBorder
                    ? BorderSide(
                        color: theme.border.withValues(
                          alpha: _borderController.value,
                        ),
                        width: 1,
                      )
                    : BorderSide.none,
              ),
            ),
            child: child,
          );

          if (widget.showPaddingSqueeze) {
            final scale = 1.0 - _paddingController.value * 0.01;
            result = Transform.scale(scale: scale, child: result);
          }

          return result;
        },
        child: widget.child,
      ),
    );
  }
}

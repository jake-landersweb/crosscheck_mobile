import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:motor/motor.dart';

/// A widget that provides a pleasant bounce and drag effect to its child
/// based on user interaction.
///
/// Renders entirely inline using a custom render object that paints via
/// [PaintingContext.pushTransform], which naturally extends beyond layout
/// bounds without needing an overlay.
class XCInteractive extends StatefulWidget {
  const XCInteractive({
    required this.child,
    this.interactionScale = 1.05,
    this.stretch = 0.5,
    this.resistance = 0.08,
    this.enabled = true,
    this.borderRadius,
    super.key,
  });

  final double interactionScale;
  final double stretch;
  final double resistance;
  final bool enabled;
  final BorderRadius? borderRadius;
  final Widget child;

  @override
  State<XCInteractive> createState() => _XCInteractiveState();
}

class _XCInteractiveState extends State<XCInteractive> {
  /// Small delay before committing to the interaction so that a quick
  /// scroll gesture doesn't trigger the scale effect.
  static const _activationDelay = Duration(milliseconds: 80);

  /// Minimum time the scale-up effect is visible before reversing, so that
  /// even the quickest taps show the full animation.
  static const _minVisibleDuration = Duration(milliseconds: 150);

  Offset _dragOffset = Offset.zero;
  Offset _touchPosition = Offset.zero;
  bool _isInteracting = false;
  bool _pointerDown = false;
  double _targetScale = 1.0;

  // Glow animation targets
  double _glowAlpha = 0.0;
  double _glowRadiusMultiplier = 0.0;

  // Tracks the current interaction so delayed callbacks can detect staleness.
  int _interactionId = 0;
  DateTime _interactionStartTime = DateTime.now();

  // Scroll position listener for canceling interaction on scroll
  ScrollPosition? _scrollPosition;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _detachScrollListener();
    _scrollPosition = Scrollable.maybeOf(context)?.position;
    _scrollPosition?.addListener(_onScrollPositionChanged);
  }

  void _detachScrollListener() {
    _scrollPosition?.removeListener(_onScrollPositionChanged);
    _scrollPosition = null;
  }

  void _onScrollPositionChanged() {
    if (_pointerDown || _isInteracting) {
      _endInteraction(force: true);
    }
  }

  @override
  void dispose() {
    _detachScrollListener();
    super.dispose();
  }

  void _onPointerDown(PointerDownEvent event) {
    _pointerDown = true;
    final position = event.localPosition;

    Future.delayed(_activationDelay, () {
      if (!mounted || !_pointerDown) return;
      _interactionId++;
      _interactionStartTime = DateTime.now();
      setState(() {
        _isInteracting = true;
        _dragOffset = Offset.zero;
        _touchPosition = position;
        _targetScale = widget.interactionScale;
        _glowAlpha = 1.0;
        _glowRadiusMultiplier = 1.0;
      });
    });
  }

  void _onPointerMove(PointerMoveEvent event) {
    if (!_isInteracting) return;
    setState(() {
      _dragOffset += event.delta;
      _touchPosition += event.delta;
    });
  }

  void _onPointerUp(PointerUpEvent event) {
    if (!_isInteracting && _pointerDown) {
      // Quick tap completed before _activationDelay fired.
      // Force the full animation cycle so visual feedback always accompanies
      // the onTap callback.
      _interactionId++;
      _interactionStartTime = DateTime.now();
      setState(() {
        _isInteracting = true;
        _dragOffset = Offset.zero;
        _touchPosition = event.localPosition;
        _targetScale = widget.interactionScale;
        _glowAlpha = 1.0;
        _glowRadiusMultiplier = 1.0;
      });
    }
    _endInteraction();
  }

  void _onPointerCancel(PointerCancelEvent event) {
    _endInteraction();
  }

  /// Ends the interaction. When [force] is false (pointer up / cancel), the
  /// reversal is deferred until [_minVisibleDuration] has elapsed so that
  /// quick taps still show the full effect. When [force] is true (scroll
  /// interrupted), the animation reverses immediately.
  void _endInteraction({bool force = false}) {
    _pointerDown = false;
    if (!_isInteracting) return;

    if (!force) {
      final elapsed = DateTime.now().difference(_interactionStartTime);
      final remaining = _minVisibleDuration - elapsed;
      if (remaining > Duration.zero) {
        final id = _interactionId;
        Future.delayed(remaining, () {
          if (!mounted || _interactionId != id) return;
          _cancelInteraction();
        });
        return;
      }
    }

    _cancelInteraction();
  }

  /// Immediately reverses all animation targets back to resting state.
  void _cancelInteraction() {
    if (!_isInteracting) return;
    setState(() {
      _isInteracting = false;
      _dragOffset = Offset.zero;
      _targetScale = 1.0;
      _glowAlpha = 0.0;
      _glowRadiusMultiplier = 3.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled ||
        (widget.stretch == 0 && widget.interactionScale == 1.0)) {
      return widget.child;
    }

    // GestureDetector claims pan gestures to prevent parent scroll views
    // from scrolling while interacting.
    // Listener provides immediate pointer feedback for the interaction effects.
    // Scroll cancellation is handled via _scrollPosition listener in
    // didChangeDependencies.
    return GestureDetector(
      onPanStart: (_) {},
      onPanUpdate: (_) {},
      onPanEnd: (_) {},
      onPanCancel: () {},
      child: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: _onPointerDown,
        onPointerMove: _onPointerMove,
        onPointerUp: _onPointerUp,
        onPointerCancel: _onPointerCancel,
        child: SingleMotionBuilder(
          value: _targetScale,
          motion: const Motion.smoothSpring(
            duration: Duration(milliseconds: 300),
            snapToEnd: true,
          ),
          builder: (context, scale, child) {
            return _InteractiveContent(
              dragOffset: _dragOffset,
              touchPosition: _touchPosition,
              stretch: widget.stretch,
              resistance: widget.resistance,
              scale: scale,
              isInteracting: _isInteracting,
              borderRadius: widget.borderRadius,
              glowAlpha: _glowAlpha,
              glowRadiusMultiplier: _glowRadiusMultiplier,
              child: widget.child,
            );
          },
        ),
      ),
    );
  }
}

/// Widget that contains the interactive content with scale, stretch, and glow.
class _InteractiveContent extends StatelessWidget {
  const _InteractiveContent({
    required this.dragOffset,
    required this.touchPosition,
    required this.stretch,
    required this.resistance,
    required this.scale,
    required this.isInteracting,
    required this.child,
    required this.glowAlpha,
    required this.glowRadiusMultiplier,
    this.borderRadius,
  });

  final Offset dragOffset;
  final Offset touchPosition;
  final double stretch;
  final double resistance;
  final double scale;
  final bool isInteracting;
  final BorderRadius? borderRadius;
  final double glowAlpha;
  final double glowRadiusMultiplier;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final resistedOffset = dragOffset._withResistance(resistance);

    return MotionBuilder(
      value: resistedOffset,
      motion: isInteracting
          ? const Motion.interactiveSpring(snapToEnd: true)
          : const Motion.bouncySpring(snapToEnd: true),
      converter: const OffsetMotionConverter(),
      builder: (context, animatedOffset, motionChild) => _RawInteractive(
        stretchPixels: animatedOffset * stretch,
        scale: scale,
        child: Stack(
          fit: StackFit.passthrough,
          clipBehavior: Clip.none,
          children: [
            motionChild!,
            _GlowOverlay(
              touchPosition: touchPosition,
              isInteracting: isInteracting,
              borderRadius: borderRadius,
              glowAlpha: glowAlpha,
              glowRadiusMultiplier: glowRadiusMultiplier,
            ),
          ],
        ),
      ),
      child: child,
    );
  }
}

/// Widget that renders a blurred glow circle following the touch position.
class _GlowOverlay extends StatelessWidget {
  const _GlowOverlay({
    required this.touchPosition,
    required this.isInteracting,
    required this.glowAlpha,
    required this.glowRadiusMultiplier,
    this.borderRadius,
  });

  final Offset touchPosition;
  final bool isInteracting;
  final double glowAlpha;
  final double glowRadiusMultiplier;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      top: 0,
      right: 0,
      bottom: 0,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final actualSize = Size(constraints.maxWidth, constraints.maxHeight);
          // Base radius relative to shortest side (like GlassGlow)
          final baseRadius = math.min(actualSize.width, actualSize.height) * 2;

          final clipWidget = borderRadius != null
              ? (Widget child) => ClipRRect(
                  borderRadius: borderRadius!,
                  clipBehavior: Clip.hardEdge,
                  child: child,
                )
              : (Widget child) =>
                    ClipRect(clipBehavior: Clip.hardEdge, child: child);

          return clipWidget(
            // Position animation
            MotionBuilder(
              value: touchPosition,
              motion: isInteracting
                  ? const Motion.interactiveSpring(snapToEnd: true)
                  : const Motion.smoothSpring(
                      duration: Duration(seconds: 1),
                      snapToEnd: true,
                    ),
              converter: const OffsetMotionConverter(),
              builder: (context, animatedPosition, _) {
                // Alpha animation
                return SingleMotionBuilder(
                  value: glowAlpha,
                  motion: isInteracting
                      ? const Motion.interactiveSpring(snapToEnd: true)
                      : const Motion.smoothSpring(snapToEnd: true),
                  builder: (context, animatedAlpha, _) {
                    // Radius animation
                    return SingleMotionBuilder(
                      value: glowRadiusMultiplier,
                      motion: isInteracting
                          ? const Motion.interactiveSpring(snapToEnd: true)
                          : const Motion.smoothSpring(snapToEnd: true),
                      builder: (context, animatedRadius, _) {
                        return IgnorePointer(
                          child: CustomPaint(
                            size: actualSize,
                            painter: _GlowPainter(
                              center: animatedPosition,
                              radius: baseRadius * animatedRadius,
                              alpha: animatedAlpha,
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}

/// Custom painter that draws a radial glow at the specified center.
class _GlowPainter extends CustomPainter {
  _GlowPainter({
    required this.center,
    required this.radius,
    required this.alpha,
  });

  final Offset center;
  final double radius;
  final double alpha;

  static const _baseColor = Colors.white24;

  @override
  void paint(Canvas canvas, Size size) {
    // Skip painting if invisible or no radius
    if (alpha <= 0 || radius <= 0) return;

    final glowColor = _baseColor.withValues(alpha: _baseColor.a * alpha);

    final paint = Paint()
      ..shader = RadialGradient(
        colors: [glowColor, glowColor.withValues(alpha: 0)],
        stops: const [0.0, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..blendMode = BlendMode.plus; // Additive blending for luminous glow

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(_GlowPainter oldDelegate) {
    return oldDelegate.center != center ||
        oldDelegate.radius != radius ||
        oldDelegate.alpha != alpha;
  }
}

/// Internal widget that applies scale and stretch effects.
class _RawInteractive extends SingleChildRenderObjectWidget {
  const _RawInteractive({
    required this.stretchPixels,
    required this.scale,
    required super.child,
  });

  final Offset stretchPixels;
  final double scale;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderRawInteractive(stretchPixels: stretchPixels, scale: scale);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderRawInteractive renderObject,
  ) {
    renderObject
      ..stretchPixels = stretchPixels
      ..scale = scale;
  }
}

/// Render object that applies scale and squash-and-stretch transformation
/// with volume preservation.
class _RenderRawInteractive extends RenderProxyBox {
  _RenderRawInteractive({required Offset stretchPixels, required double scale})
    : _stretchPixels = stretchPixels,
      _scale = scale;

  Offset _stretchPixels;
  double _scale;

  Offset get stretchPixels => _stretchPixels;
  set stretchPixels(Offset value) {
    if (_stretchPixels == value) return;
    _stretchPixels = value;
    markNeedsPaint();
  }

  double get scale => _scale;
  set scale(double value) {
    if (_scale == value) return;
    _scale = value;
    markNeedsPaint();
  }

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    return hitTestChildren(result, position: position);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    final transform = _getEffectiveTransform();
    if (transform == null) {
      return super.hitTestChildren(result, position: position);
    }

    return result.addWithPaintTransform(
      transform: transform,
      position: position,
      hitTest: (BoxHitTestResult result, Offset position) {
        return super.hitTestChildren(result, position: position);
      },
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child == null) return;

    final transform = _getEffectiveTransform();
    if (transform == null) {
      super.paint(context, offset);
      return;
    }

    // Check if the matrix is singular
    final det = transform.determinant();
    if (det == 0 || !det.isFinite) {
      layer = null;
      return;
    }

    layer = context.pushTransform(
      needsCompositing,
      offset,
      transform,
      super.paint,
      oldLayer: layer is TransformLayer ? layer as TransformLayer? : null,
    );
  }

  @override
  void applyPaintTransform(RenderBox child, Matrix4 transform) {
    final effectiveTransform = _getEffectiveTransform();
    if (effectiveTransform != null) {
      transform.multiply(effectiveTransform);
    }
  }

  Matrix4? _getEffectiveTransform() {
    final hasScale = (_scale - 1.0).abs() > 0.0001;
    final hasStretch = _stretchPixels != Offset.zero;

    if (!hasScale && !hasStretch) return null;

    final matrix = Matrix4.identity();

    // Apply scale from center
    if (hasScale) {
      final centerX = size.width / 2;
      final centerY = size.height / 2;
      // ignore: deprecated_member_use
      matrix
        // ignore: deprecated_member_use
        ..translate(centerX, centerY)
        // ignore: deprecated_member_use
        ..scale(_scale, _scale, 1.0)
        // ignore: deprecated_member_use
        ..translate(-centerX, -centerY);
    }

    // Apply stretch
    if (hasStretch) {
      final stretchScale = _getStretchScale(
        stretchPixels: _stretchPixels,
        size: size,
      );

      matrix
        // ignore: deprecated_member_use
        ..scale(stretchScale.dx, stretchScale.dy, 1.0)
        // ignore: deprecated_member_use
        ..translate(_stretchPixels.dx, _stretchPixels.dy);
    }

    return matrix;
  }

  /// Calculates the scale factors with volume preservation.
  Offset _getStretchScale({required Offset stretchPixels, required Size size}) {
    if (size.isEmpty) return const Offset(1, 1);

    final stretchX = stretchPixels.dx.abs();
    final stretchY = stretchPixels.dy.abs();

    final relativeStretchX = size.width > 0 ? stretchX / size.width : 0.0;
    final relativeStretchY = size.height > 0 ? stretchY / size.height : 0.0;

    const stretchFactor = 1.0;
    const volumeFactor = 0.5;

    final baseScaleX = 1 + relativeStretchX * stretchFactor;
    final baseScaleY = 1 + relativeStretchY * stretchFactor;

    final magnitude = math.sqrt(
      relativeStretchX * relativeStretchX + relativeStretchY * relativeStretchY,
    );
    final targetVolume = 1 + magnitude * volumeFactor;
    final currentVolume = baseScaleX * baseScaleY;
    final volumeCorrection = math.sqrt(targetVolume / currentVolume);

    final finalScaleX = baseScaleX * volumeCorrection;
    final finalScaleY = baseScaleY * volumeCorrection;

    return Offset(finalScaleX, finalScaleY);
  }
}

/// Extension that adds resistance calculation to [Offset].
extension _OffsetResistanceExtension on Offset {
  Offset _withResistance(double resistance) {
    if (resistance == 0) return this;

    final magnitude = math.sqrt(dx * dx + dy * dy);
    if (magnitude == 0) return Offset.zero;

    final resistedMagnitude = magnitude / (1 + magnitude * resistance);
    final scale = resistedMagnitude / magnitude;

    return Offset(dx * scale, dy * scale);
  }
}

import 'dart:io';

import 'package:crosscheck_sports/components/core/interactive.dart';
import 'package:crosscheck_sports/components/core/tap_effect.dart';
import 'package:crosscheck_sports/style/root.dart';
import 'package:flutter/material.dart';

enum XCContainerRadius { small, large, custom, none }

enum XCInteractionMode { scale, tap }

class XCContainer extends StatelessWidget {
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

  /// Optional border color. When set, draws a border around the container.
  final Color? borderColor;

  /// Border width when [borderColor] is set. Defaults to 2.0.
  final double borderWidth;

  /// Optional tint color overlaid on the background.
  final Color? tintColor;

  const XCContainer({
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
  });

  const XCContainer.custom({
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
  });

  const XCContainer.small({
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
  });

  const XCContainer.top({
    super.key,
    this.topLeft = XCContainerRadius.large,
    this.topRight = XCContainerRadius.large,
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
  });

  const XCContainer.bottom({
    super.key,
    this.topLeft = XCContainerRadius.small,
    this.topRight = XCContainerRadius.small,
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
  });

  const XCContainer.left({
    super.key,
    this.topLeft = XCContainerRadius.large,
    this.topRight = XCContainerRadius.small,
    this.bottomLeft = XCContainerRadius.large,
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
  });

  const XCContainer.right({
    super.key,
    this.topLeft = XCContainerRadius.small,
    this.topRight = XCContainerRadius.large,
    this.bottomLeft = XCContainerRadius.small,
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
  });

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS || Platform.isMacOS) {
      return _ios(context);
    }
    if (Platform.isAndroid || Platform.isFuchsia) {
      return _android(context);
    }
    return _default(context);
  }

  Widget _base(BuildContext context, Widget child) {
    // XCTapEffect handles its own GestureDetector, so skip wrapping here
    if (onTap != null && interactionMode != XCInteractionMode.tap) {
      return GestureDetector(
        onTap: onTap!,
        behavior: HitTestBehavior.opaque,
        child: Padding(padding: padding, child: child),
      );
    }
    return Padding(padding: padding, child: child);
  }

  Widget _default(BuildContext context) {
    final borderRadius = _getBorderRadius(context);
    final cellColor = color ?? XCTheme.of(context).cell;
    final innerChild = innerPadding == EdgeInsets.zero
        ? child
        : Padding(padding: innerPadding, child: child);

    // When using tap mode, XCTapEffect manages the background color
    final useTapMode =
        onTap != null && interactionMode == XCInteractionMode.tap;

    // Determine if we need decoration (border or tint)
    final hasBorder = borderColor != null;
    final hasTint = tintColor != null;
    final needsDecoration = hasBorder || hasTint;

    // Build the background color (base + optional tint)
    final effectiveColor = hasTint
        ? Color.alphaBlend(tintColor!, cellColor)
        : cellColor;

    // Build the shape with optional border
    final shape = RoundedSuperellipseBorder(
      borderRadius: borderRadius,
      side: hasBorder
          ? BorderSide(color: borderColor!, width: borderWidth)
          : BorderSide.none,
    );

    // Inner content sized box
    final sizedContent = SizedBox(
      height: height,
      width: width,
      child: innerChild,
    );

    Widget containerContent;
    if (useTapMode) {
      containerContent = sizedContent;
    } else if (needsDecoration) {
      // Clip content first, then apply decoration on top
      // This ensures images are clipped to the border shape
      containerContent = DecoratedBox(
        decoration: ShapeDecoration(color: effectiveColor, shape: shape),
        child: ClipPath(
          clipper: ShapeBorderClipper(
            shape: RoundedSuperellipseBorder(borderRadius: borderRadius),
          ),
          child: sizedContent,
        ),
      );
    } else {
      // Simple case: just colored box with clip
      containerContent = ClipPath(
        clipper: ShapeBorderClipper(shape: shape),
        child: ColoredBox(color: cellColor, child: sizedContent),
      );
    }

    final container = Semantics(button: onTap != null, child: containerContent);

    return _base(
      context,
      onTap != null
          ? _wrapWithInteraction(container, borderRadius, cellColor)
          : container,
    );
  }

  Widget _wrapWithInteraction(
    Widget child,
    BorderRadius borderRadius,
    Color cellColor,
  ) {
    switch (interactionMode) {
      case XCInteractionMode.scale:
        return XCInteractive(
          interactionScale: interactionScale ?? 1.1,
          borderRadius: borderRadius,
          child: child,
        );
      case XCInteractionMode.tap:
        return XCTapEffect(
          onTap: onTap,
          borderRadius: borderRadius.topLeft.x,
          backgroundColor: cellColor,
          child: child,
        );
    }
  }

  Widget _ios(BuildContext context) {
    return _default(context);
  }

  Widget _android(BuildContext context) {
    return _default(context);
  }

  BorderRadius _getBorderRadius(BuildContext context) {
    return BorderRadius.only(
      topLeft: Radius.circular(_radiusTopLeft(context)),
      topRight: Radius.circular(_radiusTopRight(context)),
      bottomLeft: Radius.circular(_radiusBottomLeft(context)),
      bottomRight: Radius.circular(_radiusBottomRight(context)),
    );
  }

  double _resolveRadius(BuildContext context, XCContainerRadius radius) {
    switch (radius) {
      case XCContainerRadius.small:
        return XCTheme.of(context).radius.small;
      case XCContainerRadius.large:
        return XCTheme.of(context).radius.large;
      case XCContainerRadius.custom:
        return customRadius ?? XCTheme.of(context).radius.large;
      case XCContainerRadius.none:
        return 0;
    }
  }

  double _radiusTopLeft(BuildContext context) =>
      _resolveRadius(context, topLeft);

  double _radiusTopRight(BuildContext context) =>
      _resolveRadius(context, topRight);

  double _radiusBottomLeft(BuildContext context) =>
      _resolveRadius(context, bottomLeft);

  double _radiusBottomRight(BuildContext context) =>
      _resolveRadius(context, bottomRight);
}

import 'package:crosscheck_sports/components/core/tap_effect.dart';
import 'package:crosscheck_sports/style/theme.dart';
import 'package:flutter/material.dart';

/// Per-item decoration overrides (for selection state).
class CellGroupDecoration {
  final Color? borderColor;
  final Color? tintColor;

  const CellGroupDecoration({this.borderColor, this.tintColor});
}

/// Position of an item within the cell group.
enum _CellPosition { only, first, middle, last }

/// Sliver variant of CellGroup for use in CustomScrollView/HeaderBar slivers.
///
/// Visually merges items into a single continuous rounded container while
/// rendering lazily. Each item independently paints its own background slice.
class SliverCellGroup extends StatelessWidget {
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final String? title;
  final EdgeInsets padding;
  final VoidCallback? Function(int index)? onItemTap;
  final CellGroupDecoration? Function(int index)? itemDecoration;

  const SliverCellGroup({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.title,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
    this.onItemTap,
    this.itemDecoration,
  });

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: padding,
      sliver: SliverMainAxisGroup(
        slivers: [
          if (title != null)
            SliverToBoxAdapter(child: _CellGroupTitle(title: title!)),
          SliverList.builder(
            itemCount: itemCount,
            itemBuilder: (context, index) {
              final position = _resolvePosition(index, itemCount);
              final decoration = itemDecoration?.call(index);
              final onTap = onItemTap?.call(index);

              return _CellGroupItem(
                position: position,
                onTap: onTap,
                decoration: decoration,
                child: itemBuilder(context, index),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Non-sliver variant of CellGroup for use in Column/ScrollView contexts.
class CellGroup extends StatelessWidget {
  final List<Widget> children;
  final List<VoidCallback?>? onItemTaps;
  final String? title;
  final EdgeInsets padding;

  const CellGroup({
    super.key,
    required this.children,
    this.onItemTaps,
    this.title,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null) _CellGroupTitle(title: title!),
          for (int i = 0; i < children.length; i++)
            _CellGroupItem(
              position: _resolvePosition(i, children.length),
              onTap: onItemTaps != null && i < onItemTaps!.length
                  ? onItemTaps![i]
                  : null,
              child: children[i],
            ),
        ],
      ),
    );
  }
}

/// Section title for cell groups.
class _CellGroupTitle extends StatelessWidget {
  final String title;

  const _CellGroupTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = XCTheme.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Text(
        title,
        style: theme.text.body.copyWith(
          color: theme.foregroundMuted,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

_CellPosition _resolvePosition(int index, int total) {
  if (total == 1) return _CellPosition.only;
  if (index == 0) return _CellPosition.first;
  if (index == total - 1) return _CellPosition.last;
  return _CellPosition.middle;
}

/// A single item within a cell group that paints its own background slice.
class _CellGroupItem extends StatelessWidget {
  final _CellPosition position;
  final VoidCallback? onTap;
  final CellGroupDecoration? decoration;
  final Widget child;

  const _CellGroupItem({
    required this.position,
    required this.child,
    this.onTap,
    this.decoration,
  });

  @override
  Widget build(BuildContext context) {
    final theme = XCTheme.of(context);
    const edgePad = 8.0;
    final outerRadius = theme.radius.large;
    final innerRadius = outerRadius - edgePad;

    // Outer corner radii based on position
    final outerBorderRadius = switch (position) {
      _CellPosition.only => BorderRadius.circular(outerRadius),
      _CellPosition.first => BorderRadius.only(
        topLeft: Radius.circular(outerRadius),
        topRight: Radius.circular(outerRadius),
      ),
      _CellPosition.last => BorderRadius.only(
        bottomLeft: Radius.circular(outerRadius),
        bottomRight: Radius.circular(outerRadius),
      ),
      _CellPosition.middle => BorderRadius.zero,
    };

    // Inner corner radii for tap effect — always fully rounded
    final innerBorderRadius = BorderRadius.circular(innerRadius);

    // Padding for edge items
    final itemPadding = switch (position) {
      _CellPosition.only => const EdgeInsets.all(edgePad),
      _CellPosition.first => const EdgeInsets.fromLTRB(
        edgePad,
        edgePad,
        edgePad,
        0,
      ),
      _CellPosition.last => const EdgeInsets.fromLTRB(
        edgePad,
        0,
        edgePad,
        edgePad,
      ),
      _CellPosition.middle => const EdgeInsets.symmetric(horizontal: edgePad),
    };

    // Base cell color with optional tint
    final baseColor = theme.cell;
    final effectiveColor = decoration?.tintColor != null
        ? Color.alphaBlend(decoration!.tintColor!, baseColor)
        : baseColor;

    // Build the outer shape decoration
    final hasBorder = decoration?.borderColor != null;
    final shape = RoundedSuperellipseBorder(
      borderRadius: outerBorderRadius,
      side: hasBorder
          ? BorderSide(color: decoration!.borderColor!, width: 2)
          : BorderSide.none,
    );

    // Wrap content in tap effect
    Widget content = XCTapEffect(
      onTap: onTap,
      customBorderRadius: innerBorderRadius,
      showBorder: false,
      child: child,
    );

    // Clip the content to the outer shape so images respect corners
    return ClipPath(
      clipper: ShapeBorderClipper(shape: shape),
      child: DecoratedBox(
        decoration: ShapeDecoration(color: effectiveColor, shape: shape),
        child: Padding(padding: itemPadding, child: content),
      ),
    );
  }
}

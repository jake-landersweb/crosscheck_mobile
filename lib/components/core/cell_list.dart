import 'package:crosscheck_sports/components/core/selection_checkbox.dart';
import 'package:crosscheck_sports/components/core/tap_effect.dart';
import 'package:crosscheck_sports/style/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

/// Position of an item within the list.
enum _CellPosition { only, first, middle, last }

/// A generic item list rendered in the new merged-cell style.
///
/// Replaces the legacy `cv.ListView` from `custom_views/listview.dart`.
/// Items are visually merged into a single continuous rounded-superellipse
/// container. Supports tap, swipe-to-delete, and multi-select modes.
///
/// Some legacy parameters ([hasDividers], [dividerBuilder], [isAnimated],
/// [animateOpen], [borderRadius]) are accepted for call-site compatibility
/// but ignored: the new style has no dividers and standardized radii.
class XCCellList<T> extends StatelessWidget {
  const XCCellList({
    super.key,
    required this.children,
    this.childBuilder,
    this.backgroundColor,
    this.hasDividers = true,
    this.dividerBuilder,
    this.childPadding = const EdgeInsets.all(16),
    this.horizontalPadding = 16,
    this.borderRadius = 10,
    this.onChildTap,
    this.isAnimated = false,
    this.allowsDelete = false,
    this.onDelete,
    this.showStyling = true,
    this.selected,
    this.allowsSelect = false,
    this.onSelect,
    this.color = Colors.blue,
    this.selectedLogic,
    this.animateOpen = false,
    this.equality,
    this.preDelete,
    this.minHeight,
  });

  final List<T> children;
  final Widget Function(BuildContext context, T item)? childBuilder;
  final Color? backgroundColor;
  final bool hasDividers;
  final Widget Function()? dividerBuilder;
  final EdgeInsets childPadding;
  final double horizontalPadding;
  final double borderRadius;
  final Function(BuildContext context, T item)? onChildTap;
  final bool isAnimated;
  final bool allowsDelete;
  final Function(T item)? onDelete;
  final bool showStyling;
  final List<T>? selected;
  final bool allowsSelect;
  final Function(T item)? onSelect;
  final Color color;
  final bool Function(T item)? selectedLogic;
  final bool animateOpen;
  final bool Function(T item1, T item2)? equality;
  final Future<bool> Function(T item)? preDelete;
  final double? minHeight;

  bool _isSelected(T item) {
    if (selectedLogic != null) return selectedLogic!(item);
    return selected?.any((element) => element == item) ?? false;
  }

  _CellPosition _position(int index, int total) {
    if (total == 1) return _CellPosition.only;
    if (index == 0) return _CellPosition.first;
    if (index == total - 1) return _CellPosition.last;
    return _CellPosition.middle;
  }

  @override
  Widget build(BuildContext context) {
    assert(childBuilder != null || T == Widget,
        "When [T] is not a widget, [childBuilder] cannot be null");
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < children.length; i++)
            _CellListItem<T>(
              item: children[i],
              position: _position(i, children.length),
              childPadding: childPadding,
              backgroundColor: backgroundColor,
              showStyling: showStyling,
              minHeight: minHeight,
              isSelected: _isSelected(children[i]),
              allowsSelect: allowsSelect,
              allowsDelete: allowsDelete,
              onDelete: onDelete,
              preDelete: preDelete,
              onTap: (allowsSelect && onSelect != null)
                  ? () => onSelect!(children[i])
                  : (onChildTap != null)
                      ? () => onChildTap!(context, children[i])
                      : null,
              child: childBuilder == null
                  ? children[i] as Widget
                  : childBuilder!(context, children[i]),
            ),
        ],
      ),
    );
  }
}

/// A single list slice that paints its own background segment.
class _CellListItem<T> extends StatelessWidget {
  const _CellListItem({
    required this.item,
    required this.position,
    required this.childPadding,
    required this.backgroundColor,
    required this.showStyling,
    required this.minHeight,
    required this.isSelected,
    required this.allowsSelect,
    required this.allowsDelete,
    required this.child,
    this.onDelete,
    this.preDelete,
    this.onTap,
  });

  final T item;
  final _CellPosition position;
  final EdgeInsets childPadding;
  final Color? backgroundColor;
  final bool showStyling;
  final double? minHeight;
  final bool isSelected;
  final bool allowsSelect;
  final bool allowsDelete;
  final Function(T item)? onDelete;
  final Future<bool> Function(T item)? preDelete;
  final VoidCallback? onTap;
  final Widget child;

  Future<void> _remove(BuildContext context) async {
    bool cont = true;
    if (preDelete != null) {
      cont = await preDelete!(item);
    }
    if (cont) {
      onDelete?.call(item);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = XCTheme.of(context);
    const edgePad = 8.0;
    final outerRadius = theme.radius.large;
    final innerRadius = outerRadius - edgePad;

    Widget content = Container(
      constraints:
          minHeight == null ? null : BoxConstraints(minHeight: minHeight!),
      width: double.infinity,
      padding: childPadding,
      child: allowsSelect
          ? Row(
              children: [
                SelectionCheckbox(isSelected: isSelected),
                const SizedBox(width: 12),
                Expanded(child: child),
              ],
            )
          : child,
    );

    content = XCTapEffect(
      onTap: onTap,
      customBorderRadius: BorderRadius.circular(innerRadius),
      showBorder: false,
      child: content,
    );

    if (!showStyling) {
      if (!allowsDelete) return content;
      return Slidable(
        key: ValueKey(item),
        endActionPane: ActionPane(
          extentRatio: 0.25,
          motion: const BehindMotion(),
          children: [
            SlidableAction(
              onPressed: (context) async => await _remove(context),
              icon: Icons.delete,
              foregroundColor: Colors.white,
              backgroundColor: theme.error,
            ),
          ],
        ),
        child: content,
      );
    }

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

    final itemPadding = switch (position) {
      _CellPosition.only => const EdgeInsets.all(edgePad),
      _CellPosition.first =>
        const EdgeInsets.fromLTRB(edgePad, edgePad, edgePad, 0),
      _CellPosition.last =>
        const EdgeInsets.fromLTRB(edgePad, 0, edgePad, edgePad),
      _CellPosition.middle => const EdgeInsets.symmetric(horizontal: edgePad),
    };

    final shape = RoundedSuperellipseBorder(borderRadius: outerBorderRadius);

    Widget cell = ClipPath(
      clipper: ShapeBorderClipper(shape: shape),
      child: DecoratedBox(
        decoration: ShapeDecoration(
          color: backgroundColor ?? theme.cell,
          shape: shape,
        ),
        child: Padding(padding: itemPadding, child: content),
      ),
    );

    if (allowsDelete) {
      cell = Slidable(
        key: ValueKey(item),
        endActionPane: ActionPane(
          extentRatio: 0.25,
          motion: const BehindMotion(),
          children: [
            Expanded(
              child: ClipPath(
                clipper: ShapeBorderClipper(shape: shape),
                child: SlidableAction(
                  onPressed: (context) async => await _remove(context),
                  icon: Icons.delete,
                  foregroundColor: Colors.white,
                  backgroundColor: theme.error,
                ),
              ),
            ),
          ],
        ),
        child: cell,
      );
    }

    return cell;
  }
}

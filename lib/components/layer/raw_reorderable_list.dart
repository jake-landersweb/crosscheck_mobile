import 'package:animated_list_plus/animated_list_plus.dart';
import 'package:animated_list_plus/transitions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Notification dispatched when a reorder drag starts or ends.
/// Parent widgets (like modal sheets) can listen for this to avoid
/// interfering with the reorder gesture.
class ReorderDragNotification extends Notification {
  final bool isDragging;
  const ReorderDragNotification({required this.isDragging});
}

/// Wrapper widget that dispatches [ReorderDragNotification] when drag state changes.
class _ReorderDragNotifier extends StatefulWidget {
  final bool inDrag;
  final Widget child;

  const _ReorderDragNotifier({required this.inDrag, required this.child});

  @override
  State<_ReorderDragNotifier> createState() => _ReorderDragNotifierState();
}

class _ReorderDragNotifierState extends State<_ReorderDragNotifier> {
  @override
  void didUpdateWidget(_ReorderDragNotifier oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.inDrag != widget.inDrag) {
      // Trigger haptic feedback when drag starts
      if (widget.inDrag) {
        HapticFeedback.mediumImpact();
      }
      // Dispatch notification after the current frame to avoid issues
      // with dispatching during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ReorderDragNotification(isDragging: widget.inDrag).dispatch(context);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// Function signature for wrapping content with a reorder Handle.
typedef HandleWrapper = Widget Function(Widget child);

class RawReorderableList<T extends Object> extends StatefulWidget {
  const RawReorderableList({
    super.key,
    required this.items,
    required this.areItemsTheSame,
    required this.onReorderFinished,
    required this.builder,
    this.slideBuilder,
    this.shrinkWrap = true,
    this.padding,
    this.header,
    this.footer,
    this.controller,
  });
  final List<T> items;
  final bool Function(T item1, T item2) areItemsTheSame;
  final void Function(T item, int from, int to, List<T> newItems)
  onReorderFinished;

  /// Optional slide action builder for backwards compatibility.
  /// If provided, the list will wrap content with Slidable internally.
  /// If null, use [wrapWithHandle] in the builder to handle Slidable yourself.
  final ActionPane? Function(T item, int index)? slideBuilder;

  /// Builder that provides both a [HandleWrapper] function and a pre-built [Handle] widget.
  ///
  /// **New pattern (recommended):** Use [wrapWithHandle] to wrap your entire content,
  /// enabling drag-to-reorder from anywhere on the cell:
  /// ```dart
  /// builder: (item, index, wrapWithHandle, handle, inDrag) {
  ///   return wrapWithHandle(
  ///     Slidable(
  ///       endActionPane: myActionPane,
  ///       child: MyCellContent(),
  ///     ),
  ///   );
  /// }
  /// ```
  ///
  /// **Legacy pattern:** Use the [handle] widget directly and set [slideBuilder]:
  /// ```dart
  /// builder: (item, index, wrapWithHandle, handle, inDrag) {
  ///   return Row(children: [content, handle]);
  /// }
  /// ```
  final Widget Function(
    T item,
    int index,
    HandleWrapper wrapWithHandle,
    Handle handle,
    bool inDrag,
  )
  builder;
  final bool shrinkWrap;
  final EdgeInsets? padding;
  final Widget? header;
  final Widget? footer;
  final ScrollController? controller;

  @override
  State<RawReorderableList<T>> createState() => _RawReorderableListState<T>();
}

class _RawReorderableListState<T extends Object>
    extends State<RawReorderableList<T>> {
  @override
  Widget build(BuildContext context) {
    return ImplicitlyAnimatedReorderableList<T>(
      items: widget.items,
      padding: widget.padding,
      controller: widget.controller,
      areItemsTheSame: widget.areItemsTheSame,
      removeDuration: const Duration(milliseconds: 500),
      liftDuration: const Duration(milliseconds: 500),
      insertDuration: const Duration(milliseconds: 500),
      settleDuration: const Duration(milliseconds: 300),
      updateDuration: const Duration(milliseconds: 300),
      reorderDuration: const Duration(milliseconds: 300),
      onReorderFinished: widget.onReorderFinished,
      header: widget.header,
      footer: widget.footer,
      itemBuilder: (context, itemAnimation, item, index) {
        // Each item must be wrapped in a Reorderable widget.
        return Reorderable(
          // Each item must have an unique key.
          key: ValueKey(item),
          // The animation of the Reorderable builder can be used to
          // change to appearance of the item between dragged and normal
          // state. For example to add elevation when the item is being dragged.
          // This is not to be confused with the animation of the itemBuilder.
          // Implicit animations (like AnimatedContainer) are sadly not yet supported.
          builder: (context, dragAnimation, inDrag) {
            // Pre-built handle widget for legacy pattern
            final handle = Handle(
              delay: const Duration(milliseconds: 150),
              child: Icon(FontAwesomeIcons.bars, color: Colors.grey),
            );

            // Wrapper function for new pattern
            Widget wrapWithHandle(Widget child) =>
                Handle(delay: const Duration(milliseconds: 150), child: child);

            // Build the content from the user's builder
            final content = widget.builder(
              item,
              index,
              wrapWithHandle,
              handle,
              inDrag,
            );

            // If slideBuilder is provided, wrap with Slidable (legacy mode)
            final wrappedContent = widget.slideBuilder != null
                ? Slidable(
                    key: ValueKey(item),
                    endActionPane: widget.slideBuilder!(item, index),
                    child: content,
                  )
                : content;

            return _ReorderDragNotifier(
              inDrag: inDrag,
              child: SizeFadeTransition(
                sizeFraction: 0.5,
                curve: Curves.easeInOut,
                animation: itemAnimation,
                child: wrappedContent,
              ),
            );
          },
        );
      },
      shrinkWrap: widget.shrinkWrap,
    );
  }
}

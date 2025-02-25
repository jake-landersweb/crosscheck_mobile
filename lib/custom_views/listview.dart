import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:crosscheck_sports/extras/root.dart';
import 'package:sprung/sprung.dart';
import 'root.dart' as cv;

/// ``` dart
/// Key? key,
/// required this.children,
/// this.childBuilder,
/// this.backgroundColor,
/// this.hasDividers = true,
/// this.dividerBuilder,
/// this.childPadding = const EdgeInsets.all(16),
/// this.horizontalPadding = 16,
/// this.borderRadius = 10,
/// this.onChildTap,
/// this.isAnimated = false,
/// this.allowsDelete = false,
/// this.onDelete,
/// this.showStyling = true,
/// this.selected,
/// this.allowsSelect = false,
/// this.onSelect,
/// this.color = Colors.blue,
/// this.selectedLogic,
/// this.initOpen = false,
/// ```
class ListView<T> extends StatefulWidget {
  const ListView({
    Key? key,
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
  }) : super(key: key);
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

  @override
  _ListViewState<T> createState() => _ListViewState<T>();
}

class _ListViewState<T> extends State<ListView<T>> {
  late bool _animateOpen;

  @override
  void initState() {
    // assert all data passed is valid
    if (widget.allowsDelete) {
      assert(widget.onDelete != null,
          "When [allowsDelete] is true, [onDelete] cannot be null.");
    }
    if (T != Widget) {
      assert(widget.childBuilder != null,
          "When [T] is not a widget, [childBuilder] cannot be null");
    }
    if (widget.allowsSelect) {
      assert(widget.selected != null,
          "When [allowsSelect] is true, [selected] must not be null.");
      assert(widget.onSelect != null,
          "When [allowsSelect] is true, [onSelect] must not be null.");
      assert(widget.onChildTap == null,
          "When [allowsSelect] is true, [onChildTap] must be null.");
    }
    _animateOpen = widget.animateOpen;
    if (!widget.animateOpen && widget.isAnimated) {
      _handleOpen();
    }

    super.initState();
  }

  Future<void> _handleOpen() async {
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      _animateOpen = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: widget.horizontalPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var child in widget.children)
            Column(
              children: [
                // item
                if (widget.onChildTap != null || widget.onSelect != null)
                  cv.BasicButton(
                    onTap: () {
                      if (widget.allowsSelect) {
                        widget.onSelect!(child);
                      } else if (widget.onChildTap != null) {
                        widget.onChildTap!(context, child);
                      }
                    },
                    child: _cell(context, child),
                  )
                else
                  _cell(context, child),
                // divider if not last item
                if (widget.hasDividers &&
                    (widget.equality != null
                        ? !widget.equality!(child, widget.children.last)
                        : child != widget.children.last))
                  Padding(
                    padding: EdgeInsets.only(left: widget.horizontalPadding),
                    child: (widget.dividerBuilder != null)
                        ? widget.dividerBuilder!()
                        : Stack(
                            children: [
                              Container(
                                width: double.infinity,
                                height: 0.5,
                                color: widget.backgroundColor ??
                                    CustomColors.cellColor(context),
                              ),
                              Divider(
                                color: Colors.white.withValues(alpha: 0.1),
                                indent:
                                    widget.allowsSelect ? (16 + 20 + 16) : 16,
                                height: 0.5,
                              ),
                            ],
                          ),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _cell(BuildContext context, T child) {
    return _ListViewCell(
      item: child,
      padding: widget.childPadding,
      isAnimated: widget.isAnimated,
      allowsDelete: widget.allowsDelete,
      backgroundColor:
          widget.backgroundColor ?? CustomColors.cellColor(context),
      showStyling: widget.showStyling,
      horizontalPadding: widget.horizontalPadding,
      borderRadius: widget.borderRadius,
      isFirst: widget.equality != null
          ? widget.equality!(child, widget.children.first)
          : child == widget.children.first,
      isLast: widget.equality != null
          ? widget.equality!(child, widget.children.last)
          : child == widget.children.last,
      onDelete: widget.onDelete,
      selected: widget.selected,
      allowsSelect: widget.allowsSelect,
      onSelect: widget.onSelect,
      color: widget.color,
      isSelected: widget.selectedLogic != null
          ? widget.selectedLogic!(child)
          : widget.selected?.any((element) => element == child) ?? false,
      animateOpen: _animateOpen,
      preDelete: widget.preDelete,
      minHeight: widget.minHeight,
      child: widget.childBuilder == null
          ? child as Widget
          : widget.childBuilder!(context, child),
    );
  }
}

class _ListViewCell<T> extends StatefulWidget {
  const _ListViewCell({
    Key? key,
    required this.item,
    required this.child,
    required this.padding,
    required this.isAnimated,
    required this.allowsDelete,
    required this.backgroundColor,
    required this.showStyling,
    required this.horizontalPadding,
    required this.borderRadius,
    required this.isFirst,
    required this.isLast,
    this.onDelete,
    this.selected,
    this.allowsSelect = false,
    this.onSelect,
    required this.color,
    required this.isSelected,
    required this.animateOpen,
    this.preDelete,
    this.minHeight,
  }) : super(key: key);
  final T item;
  final Widget child;
  final EdgeInsets padding;
  final bool isAnimated;
  final bool allowsDelete;
  final Color backgroundColor;
  final bool showStyling;
  final double horizontalPadding;
  final double borderRadius;
  final bool isFirst;
  final bool isLast;
  final Function(T)? onDelete;
  final List<T>? selected;
  final bool allowsSelect;
  final Function(T)? onSelect;
  final Color color;
  final bool isSelected;
  final bool animateOpen;
  final Future<bool> Function(T item)? preDelete;
  final double? minHeight;

  @override
  _ListViewCellState<T> createState() => _ListViewCellState<T>();
}

class _ListViewCellState<T> extends State<_ListViewCell<T>>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    // assert various conditions
    if (widget.allowsDelete) {
      assert(widget.onDelete != null,
          "When [allowsDelete] is true, [onDelete] cannot be null.");
    }
    _controller = AnimationController(
      duration: const Duration(milliseconds: 550),
      vsync: this,
      value: widget.animateOpen ? 0 : 1,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Sprung.overDamped,
    );
    // open container if is expanded
    if (widget.animateOpen) {
      _controller.forward();
    }
    super.initState();
  }

  Future<void> _remove() async {
    bool cont = true;
    if (widget.preDelete != null) {
      cont = await widget.preDelete!(widget.item);
    }
    if (cont) {
      await _controller.reverse();
      widget.onDelete!(widget.item);
      // reset height for child that inherits this position
      setState(() {
        _controller.value = double.infinity;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.allowsDelete) {
      return Slidable(
        key: ValueKey(widget.item),
        endActionPane: ActionPane(
          extentRatio: 0.25,
          motion: const BehindMotion(),
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(
                    widget.isFirst ? widget.borderRadius : 0,
                  ),
                  bottom: Radius.circular(
                    widget.isLast ? widget.borderRadius : 0,
                  ),
                ),
                child: Row(children: [
                  SlidableAction(
                    onPressed: (context) async => await _remove(),
                    icon: Icons.delete,
                    foregroundColor: Colors.red,
                    backgroundColor: Colors.red.withOpacity(0.3),
                  ),
                ]),
              ),
            ),
          ],
        ),
        child: _cell(context),
      );
    } else {
      return _cell(context);
    }
  }

  Widget _cell(BuildContext context) {
    if (widget.showStyling) {
      return SizeTransition(
        sizeFactor: _animation,
        child: Padding(
          padding: EdgeInsets.only(left: widget.horizontalPadding),
          child: Container(
            constraints: widget.minHeight == null
                ? null
                : BoxConstraints(minHeight: widget.minHeight!),
            decoration: BoxDecoration(
              color: widget.backgroundColor,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(
                  widget.isFirst ? widget.borderRadius : 0,
                ),
                bottom: Radius.circular(
                  widget.isLast ? widget.borderRadius : 0,
                ),
              ),
            ),
            width: double.infinity,
            child: _baseCell(context),
          ),
        ),
      );
    } else {
      return SizeTransition(
        sizeFactor: _animation,
        child: Padding(
          padding: EdgeInsets.only(left: widget.horizontalPadding),
          child: _baseCell(context),
        ),
      );
    }
  }

  Widget _baseCell(BuildContext context) {
    return Padding(
      padding: widget.padding,
      child: (widget.allowsSelect)
          ? Row(
              children: [
                Icon(
                    widget.isSelected
                        ? Icons.radio_button_checked_rounded
                        : Icons.circle_outlined,
                    color: widget.color,
                    size: 24),
                const SizedBox(width: 16),
                Expanded(child: widget.child),
              ],
            )
          : widget.child,
    );
  }
}

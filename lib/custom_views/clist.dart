import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:pnflutter/extras/root.dart';
import 'package:sprung/sprung.dart';
import 'root.dart' as cv;

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
  }) : super(key: key);
  final List<T> children;
  final Widget Function(BuildContext, T)? childBuilder;
  final Color? backgroundColor;
  final bool hasDividers;
  final Widget Function()? dividerBuilder;
  final EdgeInsets childPadding;
  final double horizontalPadding;
  final double borderRadius;
  final Function(T)? onChildTap;
  final bool isAnimated;
  final bool allowsDelete;
  final Function(T)? onDelete;
  final bool showStyling;
  final List<T>? selected;
  final bool allowsSelect;
  final Function(T)? onSelect;
  final Color color;

  @override
  _ListViewState<T> createState() => _ListViewState<T>();
}

class _ListViewState<T> extends State<ListView<T>> {
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

    super.initState();
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
                        widget.onChildTap!(child);
                      }
                    },
                    child: _cell(context, child),
                  )
                else
                  _cell(context, child),
                // divider if not last item
                if (widget.hasDividers && child != widget.children.last)
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
                                indent: 16,
                                height: 0.5,
                                color: CustomColors.textColor(context)
                                    .withOpacity(0.1),
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
      child: widget.childBuilder == null
          ? child as Widget
          : widget.childBuilder!(context, child),
      padding: widget.childPadding,
      isAnimated: widget.isAnimated,
      allowsDelete: widget.allowsDelete,
      backgroundColor:
          widget.backgroundColor ?? CustomColors.cellColor(context),
      showStyling: widget.showStyling,
      horizontalPadding: widget.horizontalPadding,
      borderRadius: widget.borderRadius,
      isFirst: child == widget.children.first,
      isLast: child == widget.children.last,
      onDelete: widget.onDelete,
      selected: widget.selected,
      allowsSelect: widget.allowsSelect,
      onSelect: widget.onSelect,
      color: widget.color,
      isSelected: widget.selected?.any((element) => element == child) ?? false,
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
      value: widget.isAnimated ? 0 : 1,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Sprung.overDamped,
    );
    // open container if is expanded
    if (widget.isAnimated) {
      _controller.forward();
    }
    super.initState();
  }

  void _remove() async {
    await _controller.reverse();
    widget.onDelete!(widget.item);
    // reset height for child that inherits this position
    setState(() {
      _controller.value = double.infinity;
    });
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
                    onPressed: (context) {
                      _remove();
                    },
                    icon: Icons.delete,
                    backgroundColor: Colors.red,
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
                Expanded(child: widget.child),
                if (widget.isSelected)
                  Icon(Icons.check_circle, color: widget.color, size: 20)
                else
                  Icon(Icons.circle_outlined, color: widget.color, size: 20),
              ],
            )
          : widget.child,
    );
  }
}

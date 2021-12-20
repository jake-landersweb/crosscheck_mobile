import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:pnflutter/extras/root.dart';
import 'package:sprung/sprung.dart';
import 'root.dart' as cv;

class AnimatedList<T> extends StatefulWidget {
  const AnimatedList({
    Key? key,
    required this.children,
    required this.cellBuilder,
    this.padding = const EdgeInsets.all(16),
    this.childPadding = const EdgeInsets.fromLTRB(16, 0, 16, 0),
    this.buttonPadding = 5,
    this.onTap,
    this.allowTap = false,
    this.enabled = true,
    this.onRemove,
  }) : super(key: key);

  final List<T> children;
  final EdgeInsets padding;
  final EdgeInsets childPadding;
  final Widget Function(BuildContext context, T item) cellBuilder;
  final double buttonPadding;
  final Function(T item)? onTap;
  final bool allowTap;
  final bool enabled;
  final Function(int)? onRemove;

  @override
  _AnimatedListState<T> createState() => _AnimatedListState<T>();
}

class _AnimatedListState<T> extends State<AnimatedList<T>> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          0, widget.padding.top, widget.padding.right, widget.padding.bottom),
      child: Column(
        children: [
          for (var i = 0; i < widget.children.length; i++)
            Column(
              children: [
                SwipeListCell<T>(
                  enabled: widget.enabled,
                  children: widget.children,
                  child: widget.cellBuilder(context, widget.children[i]),
                  index: i,
                  padding: widget.padding,
                  childPadding: widget.childPadding,
                  buttonPadding: widget.buttonPadding,
                  onTap: widget.onTap,
                  allowTap: widget.allowTap,
                  onRemove: (index) {
                    if (widget.onRemove == null) {
                      setState(() {
                        widget.children.removeAt(index);
                      });
                    } else {
                      setState(() {
                        widget.onRemove!(index);
                      });
                    }
                  },
                ),
                if (i != widget.children.length - 1)
                  Padding(
                    padding: EdgeInsets.only(left: widget.padding.left),
                    child: _divider(context),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _divider(BuildContext context) {
    return SizedBox(
      height: 0.5,
      child: Stack(
        children: [
          Container(
              height: 0.5,
              width: double.infinity,
              color: CustomColors.cellColor(context)),
          const Divider(indent: 15),
        ],
      ),
    );
  }
}

class SwipeListCell<T> extends StatefulWidget {
  const SwipeListCell({
    Key? key,
    required this.children,
    required this.index,
    required this.child,
    required this.padding,
    required this.childPadding,
    required this.onRemove,
    required this.buttonPadding,
    this.onTap,
    required this.allowTap,
    required this.enabled,
  }) : super(key: key);
  final List<T> children;
  final int index;
  final Widget child;
  final EdgeInsets padding;
  final EdgeInsets childPadding;
  final Function(int) onRemove;
  final double buttonPadding;
  final Function(T item)? onTap;
  final bool allowTap;
  final bool enabled;

  @override
  _SwipeListCellState<T> createState() => _SwipeListCellState<T>();
}

class _SwipeListCellState<T> extends State<SwipeListCell<T>>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 550),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Sprung.overDamped,
    );
    // open container if is expanded
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Slidable(
      enabled: widget.enabled,
      key: ValueKey(widget.children[widget.index]),
      endActionPane: ActionPane(
        extentRatio: 0.25,
        motion: const BehindMotion(),
        children: [
          CustomSlidableAction(
            onPressed: (context) {
              _remove();
            },
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: widget.buttonPadding),
              child: AspectRatio(
                aspectRatio: 1,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    color: Colors.red.withOpacity(0.3),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.delete,
                      color: Colors.red[900],
                    ),
                  ),
                ),
              ),
            ),
            backgroundColor: Colors.transparent,
          ),
        ],
      ),
      child: !widget.allowTap
          ? Padding(
              padding: EdgeInsets.fromLTRB(widget.padding.left, 0, 0, 0),
              child: Material(
                color: CustomColors.cellColor(context),
                shape:
                    ContinuousRectangleBorder(borderRadius: _getborderRadius()),
                child: SizeTransition(
                  sizeFactor: _animation,
                  child: Padding(
                    padding: widget.childPadding,
                    child: widget.child,
                  ),
                ),
              ),
            )
          : Padding(
              padding: EdgeInsets.fromLTRB(widget.padding.left, 0, 0, 0),
              child: cv.BasicButton(
                onTap: () {
                  widget.onTap!(widget.children[widget.index]);
                },
                child: Material(
                  color: CustomColors.cellColor(context),
                  shape: ContinuousRectangleBorder(
                      borderRadius: _getborderRadius()),
                  child: SizeTransition(
                    sizeFactor: _animation,
                    child: Padding(
                      padding: widget.childPadding,
                      child: widget.child,
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  void _remove() async {
    await _controller.reverse();
    widget.onRemove(widget.index);
    // reset height for child that inherits this position
    setState(() {
      _controller.value = double.infinity;
    });
  }

  BorderRadius _getborderRadius() {
    if (widget.index == 0) {
      if (widget.children.length == 1) {
        return BorderRadius.circular(35);
      } else {
        return const BorderRadius.only(
            topLeft: Radius.circular(35), topRight: Radius.circular(35));
      }
    } else if (widget.index == widget.children.length - 1) {
      return const BorderRadius.only(
          bottomLeft: Radius.circular(35), bottomRight: Radius.circular(35));
    } else {
      return BorderRadius.circular(0);
    }
  }
}

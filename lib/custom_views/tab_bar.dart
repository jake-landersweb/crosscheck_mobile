import 'package:crosscheck_sports/extras/root.dart';
import 'package:flutter/material.dart';
import 'package:crosscheck_sports/custom_views/core/root.dart';
import 'package:sprung/sprung.dart';
import 'core/root.dart' as cv;

class TabBar extends StatefulWidget {
  const TabBar({
    Key? key,
    required this.index,
    required this.icons,
    this.titles,
    required this.color,
    required this.onViewChange,
    this.childBuilder,
    this.extraTapArgs,
    this.hasBadge,
  }) : super(key: key);
  final int index;
  final List<IconData> icons;
  final List<String>? titles;
  final Color color;
  final Function(int) onViewChange;
  final Function(int)? hasBadge;
  final Widget Function(BuildContext context, IconData icon, bool isSelected)?
      childBuilder;
  final void Function(BuildContext context, IconData icon, bool isSelected)?
      extraTapArgs;

  @override
  _TabBarState createState() => _TabBarState();
}

class _TabBarState extends State<TabBar> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Divider(
          height: 0.5,
          indent: 0,
          endIndent: 0,
          color: ViewColors.textColor(context).withOpacity(0.3),
        ),
        cv.GlassContainer(
          width: double.infinity,
          borderRadius: BorderRadius.circular(0),
          backgroundColor: ViewColors.backgroundColor(context),
          opacity: 0.8,
          blur: 12,
          child: SafeArea(
            top: false,
            left: false,
            right: false,
            bottom: true,
            child: Padding(
              padding: _barPadding(context),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  for (var i = 0; i < widget.icons.length; i++)
                    Stack(
                      alignment: Alignment.topRight,
                      children: [
                        _TabBarItem(
                          builder: (context) {
                            if (widget.childBuilder == null) {
                              return _tabBarItem(context, i, widget.icons[i],
                                  widget.titles?[i]);
                            } else {
                              return widget.childBuilder!(
                                context,
                                widget.icons[i],
                                widget.index == i,
                              );
                            }
                          },
                          onTap: () {
                            widget.onViewChange(i);
                            if (widget.extraTapArgs != null) {
                              widget.extraTapArgs!(
                                context,
                                widget.icons[i],
                                widget.index == i,
                              );
                            }
                          },
                        ),
                        if (widget.hasBadge != null && widget.hasBadge!(i))
                          Transform.translate(
                            offset: const Offset(3, -3),
                            child: Material(
                              shadowColor: CustomColors.textColor(context),
                              borderRadius: BorderRadius.circular(6),
                              elevation: 2.0,
                              child: Container(
                                height: 12,
                                width: 12,
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _tabBarItem(
      BuildContext context, int idx, IconData icon, String? title) {
    var i = Icon(
      icon,
      size: 28,
      color: widget.index == idx
          ? widget.color
          : ViewColors.textColor(context).withOpacity(0.5),
    );
    if (title == null) {
      return i;
    } else {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          i,
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w300,
              color: widget.index == idx
                  ? widget.color
                  : CustomColors.textColor(context).withOpacity(0.5),
            ),
          ),
        ],
      );
    }
  }

  EdgeInsets _barPadding(BuildContext context) {
    if (MediaQuery.of(context).viewPadding.bottom == 0) {
      return const EdgeInsets.only(top: 8, bottom: 16);
    } else {
      return const EdgeInsets.only(top: 8);
    }
  }
}

class _TabBarItem extends StatefulWidget {
  const _TabBarItem({
    super.key,
    required this.builder,
    required this.onTap,
  });
  final Widget Function(BuildContext context) builder;
  final VoidCallback onTap;

  @override
  State<_TabBarItem> createState() => __TabBarItemState();
}

class __TabBarItemState extends State<_TabBarItem> {
  double _scale = 1.0;

  Future<void> _anim() async {
    setState(() {
      _scale = 1.1;
    });
    await Future.delayed(const Duration(milliseconds: 150));
    setState(() {
      _scale = 1.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      duration: const Duration(milliseconds: 200),
      curve: Sprung(36),
      scale: _scale,
      child: cv.BasicButton(
        onTap: () {
          _anim();
          widget.onTap();
        },
        child: widget.builder(context),
      ),
    );
  }
}

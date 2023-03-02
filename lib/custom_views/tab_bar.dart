import 'package:crosscheck_sports/extras/root.dart';
import 'package:flutter/material.dart';
import 'package:crosscheck_sports/custom_views/core/root.dart';
import 'core/root.dart' as cv;

class TabBar extends StatefulWidget {
  const TabBar({
    Key? key,
    required this.index,
    required this.icons,
    required this.color,
    required this.onViewChange,
    this.childBuilder,
    this.extraTapArgs,
    this.hasBadge,
  }) : super(key: key);
  final int index;
  final List<IconData> icons;
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
                        if (widget.childBuilder == null)
                          _tabBarItem(context, i, widget.icons[i])
                        else
                          cv.BasicButton(
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
                            child: widget.childBuilder!(
                              context,
                              widget.icons[i],
                              widget.index == i,
                            ),
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

  Widget _tabBarItem(BuildContext context, int idx, IconData icon) {
    return cv.BasicButton(
      onTap: () {
        widget.onViewChange(idx);
        if (widget.extraTapArgs != null) {
          widget.extraTapArgs!(
            context,
            icon,
            widget.index == idx,
          );
        }
      },
      child: Icon(
        icon,
        size: 28,
        color: widget.index == idx
            ? widget.color
            : ViewColors.textColor(context).withOpacity(0.5),
      ),
    );
  }

  EdgeInsets _barPadding(BuildContext context) {
    if (MediaQuery.of(context).viewPadding.bottom == 0) {
      return const EdgeInsets.only(top: 8, bottom: 16);
    } else {
      return const EdgeInsets.only(top: 8);
    }
  }
}

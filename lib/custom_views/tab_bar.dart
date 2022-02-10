import 'package:flutter/material.dart';
import 'package:pnflutter/custom_views/core/root.dart';
import 'core/root.dart' as cv;

class TabBar extends StatefulWidget {
  const TabBar({
    Key? key,
    required this.index,
    required this.icons,
    required this.color,
    required this.onViewChange,
  }) : super(key: key);
  final int index;
  final List<IconData> icons;
  final Color color;
  final Function(int) onViewChange;

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
          opacity: 0.9,
          blur: 15,
          height: MediaQuery.of(context).viewPadding.bottom + 40,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              for (var i = 0; i < widget.icons.length; i++)
                _tabBarItem(context, i, widget.icons[i]),
            ],
          ),
        ),
      ],
    );
  }

  Widget _tabBarItem(BuildContext context, int idx, IconData icon) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          32, 0, 32, MediaQuery.of(context).viewPadding.bottom),
      child: cv.BasicButton(
        onTap: () {
          widget.onViewChange(idx);
        },
        child: Icon(
          icon,
          size: 28,
          color: widget.index == idx
              ? widget.color
              : ViewColors.textColor(context).withOpacity(0.5),
        ),
      ),
    );
  }
}

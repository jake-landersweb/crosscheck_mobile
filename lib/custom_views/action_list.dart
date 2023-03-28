import 'package:crosscheck_sports/extras/root.dart';
import 'package:flutter/material.dart';
import 'root.dart' as cv;
import 'dart:math' as math;

enum ALType { nav, sheet, floating }

class ActionListItem {
  ActionListItem({
    required this.title,
    required this.icon,
    required this.view,
    required this.color,
    required this.type,
  });
  final String title;
  final IconData icon;
  final Widget view;
  final ALType type;
  final Color color;
}

class ActionList extends StatefulWidget {
  const ActionList({
    super.key,
    required this.items,
  });
  final List<ActionListItem> items;

  @override
  State<ActionList> createState() => _ActionListState();
}

class _ActionListState extends State<ActionList> {
  @override
  Widget build(BuildContext context) {
    return cv.ListView<ActionListItem>(
      horizontalPadding: 0,
      childPadding: const EdgeInsets.symmetric(horizontal: 16),
      onChildTap: ((context, item) {
        switch (item.type) {
          case cv.ALType.nav:
            cv.Navigate(context, item.view);
            break;
          case cv.ALType.sheet:
            cv.cupertinoSheet(
              context: context,
              builder: (context) {
                return item.view;
              },
            );
            break;
          case cv.ALType.floating:
            cv.showFloatingSheet(
              context: context,
              builder: (context) {
                return item.view;
              },
            );
            break;
        }
      }),
      childBuilder: ((context, item) {
        return ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 50),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: item.color,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(item.icon, size: 20, color: Colors.white),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item.title,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: CustomColors.textColor(context),
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Transform.rotate(
                angle: item.type == ALType.nav ? 0 : -math.pi / 2,
                child: Icon(
                  Icons.chevron_right_rounded,
                  color: CustomColors.textColor(context).withOpacity(0.5),
                ),
              ),
            ],
          ),
        );
      }),
      children: widget.items,
    );
  }
}

import 'package:flutter/material.dart';
import 'root.dart';
import '../../data/root.dart';
import 'package:pnflutter/extras/root.dart';
import '../../custom_views/root.dart' as cv;

enum RosterListType { navigator, selector, none }

class RosterList extends StatefulWidget {
  const RosterList({
    Key? key,
    required this.users,
    required this.team,
    required this.type,
    this.color = Colors.blue,
    this.onSelect,
    this.onNavigate,
    this.selected,
    this.cellBuilder,
  }) : super(key: key);
  final List<SeasonUser> users;
  final Team team;
  final RosterListType type;
  final Color color;
  final Function(SeasonUser)? onSelect;
  final Function(SeasonUser)? onNavigate;
  final List<SeasonUser>? selected;
  final Widget Function(BuildContext, SeasonUser, bool)? cellBuilder;

  @override
  _RosterListState createState() => _RosterListState();
}

class _RosterListState extends State<RosterList> {
  List<String> _internalTracker = [];

  @override
  void initState() {
    if (widget.selected != null) {
      _internalTracker = widget.selected!.map((e) => e.email).toList();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return cv.ListView(
      horizontalPadding: 0,
      childPadding: const EdgeInsets.all(8),
      color: Colors.transparent,
      children: widget.users,
      childBuilder: (context, SeasonUser item) {
        return _cell(context, item, _internalTracker.contains(item.email));
      },
      onChildTap: widget.type == RosterListType.none
          ? null
          : (SeasonUser user) => _action(context, user),
    );
  }

  void _action(BuildContext context, SeasonUser user) {
    switch (widget.type) {
      case RosterListType.navigator:
        widget.onNavigate!(user);
        break;
      case RosterListType.selector:
        widget.onSelect!(user);
        setState(() {
          if (_internalTracker.any((element) => element == user.email)) {
            _internalTracker.removeWhere((element) => element == user.email);
          } else {
            _internalTracker.add(user.email);
          }
        });
        break;
      default:
        break;
    }
  }

  Widget _cell(BuildContext context, SeasonUser i, bool isSelected) {
    return Container(
      color: CustomColors.cellColor(context),
      child: widget.cellBuilder == null
          ? RosterCell(
              name: i.name(widget.team.showNicknames),
              seed: i.email,
              padding: EdgeInsets.zero,
              type: widget.type,
              color: widget.color,
              isSelected: isSelected,
            )
          : widget.cellBuilder!(context, i, isSelected),
    );
  }
}

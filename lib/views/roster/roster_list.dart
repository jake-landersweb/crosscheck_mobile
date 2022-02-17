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
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: cv.NativeList(
        color: Colors.transparent,
        padding: EdgeInsets.zero,
        itemPadding: EdgeInsets.zero,
        children: [
          for (var i in widget.users) _cellWrapper(context, i),
        ],
      ),
    );
  }

  Widget _cellWrapper(BuildContext context, SeasonUser i) {
    switch (widget.type) {
      case RosterListType.navigator:
        return cv.BasicButton(
          onTap: () {
            widget.onNavigate!(i);
          },
          child: _cell(context, i, false),
        );
      case RosterListType.selector:
        return cv.BasicButton(
          onTap: () {
            widget.onSelect!(i);
            setState(() {
              if (_internalTracker.any((element) => element == i.email)) {
                _internalTracker.removeWhere((element) => element == i.email);
              } else {
                _internalTracker.add(i.email);
              }
            });
          },
          child: _cell(context, i, _internalTracker.contains(i.email)),
        );
      default:
        return _cell(context, i, false);
    }
  }

  Widget _cell(BuildContext context, SeasonUser i, bool isSelected) {
    return Container(
      color: CustomColors.cellColor(context),
      child: widget.cellBuilder == null
          ? RosterCell(
              name: i.name(widget.team.showNicknames),
              seed: i.email,
              type: widget.type,
              color: widget.color,
              isSelected: isSelected,
            )
          : widget.cellBuilder!(context, i, isSelected),
    );
  }
}

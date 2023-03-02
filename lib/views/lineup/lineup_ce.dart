import 'package:crosscheck_sports/data/root.dart';
import 'package:flutter/material.dart';

class LineupCEModel extends ChangeNotifier {
  late String seasonId;
  late String eventId;
  late String teamId;

  late List<LineupItem> lineupItems;

  LineupCEModel({
    required this.seasonId,
    required this.eventId,
    required this.teamId,
    this.lineupItems = const [],
  });

  void addLineupItem() {
    lineupItems.add(LineupItem.empty());
    notifyListeners();
  }

  void removeLineupItem(LineupItem item) {
    lineupItems.removeWhere((element) => element.id == item.id);
    notifyListeners();
  }
}

class LineupCE extends StatefulWidget {
  const LineupCE({
    super.key,
    required this.team,
    required this.season,
    required this.event,
  });
  final Team team;
  final Season season;
  final Event event;

  @override
  State<LineupCE> createState() => _LineupCEState();
}

class _LineupCEState extends State<LineupCE> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

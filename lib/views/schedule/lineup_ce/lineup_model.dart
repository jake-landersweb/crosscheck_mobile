import 'package:crosscheck_sports/data/root.dart';
import 'package:flutter/material.dart';

class LModel extends ChangeNotifier {
  late Team team;
  late Season season;
  late Event event;
  late Lineup lineup;
  late bool isCreate;
  late List<SeasonUser> eventUsers;
  List<String> usedIds = [];

  LModel.create({
    required this.team,
    required this.season,
    required this.event,
    required this.eventUsers,
  }) {
    lineup = Lineup(
      eventId: event.eventId,
      teamId: team.teamId,
      seasonId: season.seasonId,
      lineupItems: [],
    );
    isCreate = true;
  }

  LModel.update({
    required this.team,
    required this.season,
    required this.event,
    required Lineup lineup,
    required this.eventUsers,
  }) {
    isCreate = false;
    updateLineup(lineup);
  }

  void updateLineup(Lineup lineup) {
    usedIds = [];

    // only add emails that are part of this event
    List<LineupItem> lineupItems = [];
    for (var i in lineup.lineupItems) {
      LineupItem l = LineupItem(title: i.title, ids: []);
      for (var j in i.ids) {
        if (eventUsers.any((element) => element.email == j)) {
          l.ids.add(j);
        } else {
          l.ids.add("");
        }
      }
      lineupItems.add(l);
    }

    this.lineup = Lineup(
      eventId: "",
      teamId: "",
      seasonId: "",
      lineupItems: lineupItems,
    );
    // keep list of all used ids
    for (var i in lineup.lineupItems) {
      for (var j in i.ids) {
        usedIds.add(j);
      }
    }
    notifyListeners();
  }

  void addLineupItem() {
    lineup.lineupItems.add(LineupItem.empty());
    notifyListeners();
  }

  void removeLineupItem(LineupItem item) {
    lineup.lineupItems.removeWhere((element) => element.id == item.id);
    usedIds.removeWhere(
        ((element) => item.ids.any((element2) => element == element2)));
    notifyListeners();
  }

  bool lineupValid() {
    if (lineup.lineupItems.isEmpty) {
      return false;
    } else {
      return true;
    }
  }

  void updateState() {
    notifyListeners();
  }
}

import 'dart:convert';

import 'package:crosscheck_sports/data/root.dart';
import 'package:uuid/uuid.dart';

class Lineup {
  late String seasonId;
  late String eventId;
  late String teamId;
  late List<LineupItem> lineupItems;
  Event? event;

  Lineup({
    required this.eventId,
    required this.teamId,
    required this.seasonId,
    required this.lineupItems,
    this.event,
  });

  Lineup copy() => Lineup(
        seasonId: seasonId,
        eventId: eventId,
        teamId: teamId,
        lineupItems: [for (var i in lineupItems) i.copy()],
        event: event,
      );

  Lineup.fromJson(dynamic json) {
    seasonId = json['seasonId'];
    eventId = json['eventId'];
    teamId = json['teamId'];
    lineupItems = [];
    for (var i in json['lineupItems']) {
      lineupItems.add(LineupItem.fromJson(i));
    }
    if (json['event'] != null) {
      event = Event.fromJson(json['event']);
    }
  }

  Map<String, dynamic> toMap() {
    return {
      "lineupItems": lineupItems.map((e) => e.toMap()).toList(),
    };
  }

  String toJson() {
    return jsonEncode(toMap());
  }
}

class LineupItem {
  late String id;
  late String title;
  late List<String> ids;

  LineupItem({
    required this.title,
    required this.ids,
  }) {
    id = const Uuid().v4();
  }

  LineupItem.empty() {
    id = const Uuid().v4();
    title = "";
    ids = [];
  }

  LineupItem copy() => LineupItem(title: title, ids: List.of(ids));

  LineupItem.fromJson(dynamic json) {
    id = const Uuid().v4();
    title = json['title'];
    ids = [];
    for (var i in json['ids']) {
      ids.add(i);
    }
  }

  Map<String, dynamic> toMap() {
    return {
      "title": title,
      "ids": ids,
    };
  }

  String toJson() {
    return jsonEncode(toMap());
  }
}

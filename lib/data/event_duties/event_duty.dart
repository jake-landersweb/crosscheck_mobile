import 'dart:math';

import 'package:crosscheck_sports/data/event_duties/event_duty_user.dart';

class EventDuty {
  late String teamId;
  late String seasonId;
  late int eventDutyId;
  late String title;
  late DateTime created;
  late DateTime updated;
  late List<EventDutyUser> users;

  EventDuty({
    required this.teamId,
    required this.seasonId,
    required this.eventDutyId,
    required this.title,
    required this.created,
    required this.updated,
    required this.users,
  });

  EventDuty clone() => EventDuty(
        teamId: teamId,
        seasonId: seasonId,
        eventDutyId: eventDutyId,
        title: title,
        created: created,
        updated: updated,
        users: [for (var i in users) i.clone()],
      );

  EventDuty.empty({
    required this.teamId,
    required this.seasonId,
  }) {
    eventDutyId = Random().nextInt(100000) - 100000; // TODO -- bug
    title = "";
    created = DateTime.now();
    updated = DateTime.now();
    users = [];
  }

  EventDuty.fromJson(Map<String, dynamic> data) {
    teamId = data['teamId'];
    seasonId = data['seasonId'];
    eventDutyId = data['eventDutyId'];
    title = data['title'];
    created = DateTime.parse(data['created']);
    updated = DateTime.parse(data['updated']);
    users = [];
    for (var i in data['users']) {
      users.add(EventDutyUser.fromJson(i));
    }
  }

  Map<String, dynamic> toMap() => {
        "eventDutyId": eventDutyId,
        "teamId": teamId,
        "seasonId": seasonId,
        "title": title,
        "emails": users.map((e) => e.email).toList(),
      };
}

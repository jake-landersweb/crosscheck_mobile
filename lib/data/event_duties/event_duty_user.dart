class EventDutyUser {
  late String teamId;
  late String seasonId;
  late int eventDutyId;
  late String email;
  late DateTime created;
  late DateTime updated;

  EventDutyUser({
    required this.teamId,
    required this.seasonId,
    required this.eventDutyId,
    required this.email,
    required this.created,
    required this.updated,
  });

  EventDutyUser.empty({
    required this.teamId,
    required this.seasonId,
    required this.eventDutyId,
    required this.email,
  }) {
    created = DateTime.now();
    updated = DateTime.now();
  }

  EventDutyUser clone() => EventDutyUser(
        teamId: teamId,
        seasonId: seasonId,
        eventDutyId: eventDutyId,
        email: email,
        created: created,
        updated: updated,
      );

  EventDutyUser.fromJson(Map<String, dynamic> data) {
    teamId = data['teamId'];
    seasonId = data['seasonId'];
    eventDutyId = data['eventDutyId'];
    email = data['email'];
    created = DateTime.parse(data['created']);
    updated = DateTime.parse(data['updated']);
  }

  Map<String, dynamic> toMap() => {
        "teamId": teamId,
        "seasonId": seasonId,
        "eventDutyId": eventDutyId,
        "email": email,
      };
}

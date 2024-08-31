class EventDutyEventUser {
  late String teamId;
  late String seasonId;
  late String eventId;
  late int eventDutyId;
  late String email;
  late DateTime created;
  late DateTime updated;

  EventDutyEventUser({
    required this.teamId,
    required this.seasonId,
    required this.eventId,
    required this.eventDutyId,
    required this.email,
    required this.created,
    required this.updated,
  });

  EventDutyEventUser.empty({
    required String teamId,
    required String seasonId,
    required String eventId,
    required int eventDutyId,
    required String email,
  }) {
    created = DateTime.now();
    updated = DateTime.now();
  }

  EventDutyEventUser.fromJson(Map<String, dynamic> data) {
    teamId = data['teamId'];
    seasonId = data['seasonId'];
    eventId = data['eventId'];
    eventDutyId = data['eventDutyId'];
    email = data['email'];
    created = DateTime.parse(data['created']);
    updated = DateTime.parse(data['updated']);
  }

  Map<String, dynamic> toMap() => {
        "teamId": teamId,
        "seasonId": seasonId,
        "eventId": eventId,
        "eventDutyId": eventDutyId,
        "email": email,
      };

  @override
  String toString() => toMap().toString();
}

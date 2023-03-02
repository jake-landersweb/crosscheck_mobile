class EventDeepLink {
  final String teamId;
  final String seasonId;
  final String eventId;

  EventDeepLink({
    required this.teamId,
    required this.seasonId,
    required this.eventId,
  });

  @override
  String toString() {
    return "teamId: $teamId seasonId: $seasonId eventId: $eventId";
  }
}

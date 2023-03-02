class SUPollFields {
  late String id;
  late String sortKey;
  late String email;
  late String teamId;
  late String seasonId;
  late List<String> selections;

  SUPollFields({
    required this.id,
    required this.sortKey,
    required this.email,
    required this.teamId,
    required this.seasonId,
    required this.selections,
  });

  SUPollFields clone() => SUPollFields(
        id: id,
        sortKey: sortKey,
        email: email,
        teamId: teamId,
        seasonId: seasonId,
        selections: selections,
      );

  SUPollFields.fromJson(dynamic json) {
    id = json['id'];
    sortKey = json['sortKey'];
    email = json['email'];
    teamId = json['teamId'];
    seasonId = json['seasonId'];
    selections = [];
    for (var i in json['selections']) {
      selections.add(i);
    }
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "sortKey": sortKey,
      "email": email,
      "teamId": teamId,
      "seasonId": seasonId,
      "selections": selections,
    };
  }
}

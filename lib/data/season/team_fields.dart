class SeasonUserTeamFields {
  String? teamUserNote;
  String? orgId;
  LastSeason? lastSeason;
  late int teamUserType;
  // new fields
  int? rank;
  int? tPosition;

  SeasonUserTeamFields({
    this.teamUserNote,
    this.orgId,
    this.lastSeason,
    required this.teamUserType,
    this.rank,
    this.tPosition,
  });

  SeasonUserTeamFields.empty() {
    teamUserNote = "";
    orgId = "";
    lastSeason = LastSeason.empty();
    teamUserType = 1;
    rank = 0;
    tPosition = 0;
  }

  SeasonUserTeamFields.of(SeasonUserTeamFields user) {
    teamUserNote = user.teamUserNote;
    orgId = user.orgId;
    lastSeason = user.lastSeason;
    teamUserType = user.teamUserType;
    rank = user.rank;
    tPosition = user.tPosition;
  }

  SeasonUserTeamFields.fromJson(Map<String, dynamic> json) {
    teamUserNote = json['teamUserNote'];
    orgId = json['orgId'];
    lastSeason = json['lastSeason'] != null
        ? LastSeason.fromJson(json['lastSeason'])
        : null;
    teamUserType = json['teamUserType']?.round();
    rank = json['rank']?.round();
    tPosition = json['tPosition']?.round();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['teamUserNote'] = teamUserNote;
    data['orgId'] = orgId;
    if (lastSeason != null) {
      data['lastSeason'] = lastSeason!.toJson();
    }
    data['teamUserType'] = teamUserType;
    data['rank'] = rank;
    data['tPosition'] = tPosition;
    return data;
  }
}

class LastSeason {
  String? title;
  String? seasonId;

  LastSeason({
    required this.title,
    required this.seasonId,
  });

  LastSeason.empty() {
    title = "";
    seasonId = "";
  }

  LastSeason.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    seasonId = json['seasonId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['title'] = title;
    data['seasonId'] = seasonId;
    return data;
  }
}

class SeasonUserTeamFields {
  String? teamUserNote;
  bool? isGoalie;
  String? orgId;
  LastSeason? lastSeason;
  late int teamUserType;
  // new fields
  int? rank;
  int? defaultPosition;

  SeasonUserTeamFields({
    this.teamUserNote,
    this.isGoalie,
    this.orgId,
    this.lastSeason,
    required this.teamUserType,
    this.rank,
    this.defaultPosition,
  });

  SeasonUserTeamFields.empty() {
    teamUserNote = "";
    isGoalie = false;
    orgId = "";
    lastSeason = LastSeason.empty();
    teamUserType = 1;
    rank = 0;
    defaultPosition = 0;
  }

  SeasonUserTeamFields.of(SeasonUserTeamFields user) {
    teamUserNote = user.teamUserNote;
    isGoalie = user.isGoalie;
    orgId = user.orgId;
    lastSeason = user.lastSeason;
    teamUserType = user.teamUserType;
    rank = user.rank;
    defaultPosition = user.defaultPosition;
  }

  SeasonUserTeamFields.fromJson(Map<String, dynamic> json) {
    teamUserNote = json['teamUserNote'];
    isGoalie = json['isGoalie'];
    orgId = json['orgId'];
    lastSeason = json['lastSeason'] != null
        ? LastSeason.fromJson(json['lastSeason'])
        : null;
    teamUserType = json['teamUserType']?.round();
    rank = json['rank']?.round();
    defaultPosition = json['defaultPosition']?.round();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['teamUserNote'] = teamUserNote;
    data['isGoalie'] = isGoalie;
    data['orgId'] = orgId;
    if (lastSeason != null) {
      data['lastSeason'] = lastSeason!.toJson();
    }
    data['teamUserType'] = teamUserType;
    data['rank'] = rank;
    data['defaultPosition'] = defaultPosition;
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

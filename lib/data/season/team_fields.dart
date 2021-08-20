class SeasonUserTeamFields {
  String? teamUserNote;
  bool? isGoalie;
  String? orgId;
  LastSeason? lastSeason;
  late int teamUserType;

  SeasonUserTeamFields({
    this.teamUserNote,
    this.isGoalie,
    this.orgId,
    this.lastSeason,
    required this.teamUserType,
  });

  SeasonUserTeamFields.empty() {
    teamUserNote = "";
    isGoalie = false;
    orgId = "";
    lastSeason = LastSeason.empty();
    teamUserType = 1;
  }

  SeasonUserTeamFields.of(SeasonUserTeamFields user) {
    teamUserNote = user.teamUserNote;
    isGoalie = user.isGoalie;
    orgId = user.orgId;
    lastSeason = user.lastSeason;
    teamUserType = user.teamUserType;
  }

  SeasonUserTeamFields.fromJson(Map<String, dynamic> json) {
    teamUserNote = json['teamUserNote'];
    isGoalie = json['isGoalie'];
    orgId = json['orgId'];
    lastSeason = json['lastSeason'] != null
        ? LastSeason.fromJson(json['lastSeason'])
        : null;
    teamUserType = json['teamUserType']?.round();
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
    return data;
  }
}

class LastSeason {
  late String title;
  late String seasonId;

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

import '../root.dart';

class SeasonUserTeamFields {
  String? teamUserNote;
  String? orgId;
  LastSeason? lastSeason;
  late int teamUserType;
  // new fields
  late String pos;
  late List<CustomField> customFields;

  SeasonUserTeamFields({
    this.teamUserNote,
    this.orgId,
    this.lastSeason,
    required this.teamUserType,
    required this.pos,
    required this.customFields,
  });

  SeasonUserTeamFields.empty() {
    teamUserNote = "";
    orgId = "";
    lastSeason = LastSeason.empty();
    teamUserType = 1;
    pos = "";
    customFields = [];
  }

  SeasonUserTeamFields.of(SeasonUserTeamFields user) {
    teamUserNote = user.teamUserNote;
    orgId = user.orgId;
    lastSeason = user.lastSeason;
    teamUserType = user.teamUserType;
    pos = user.pos;
    customFields = user.customFields;
  }

  SeasonUserTeamFields.fromJson(Map<String, dynamic> json) {
    teamUserNote = json['teamUserNote'];
    orgId = json['orgId'];
    lastSeason = json['lastSeason'] != null
        ? LastSeason.fromJson(json['lastSeason'])
        : null;
    teamUserType = json['teamUserType']?.round();
    pos = json['pos'] ?? "";
    customFields = [];
    if (json.containsKey("customFields")) {
      json['customFields']
          .forEach((v) => customFields.add(CustomField.fromJson(v)));
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['teamUserNote'] = teamUserNote;
    data['orgId'] = orgId;
    if (lastSeason != null) {
      data['lastSeason'] = lastSeason!.toJson();
    }
    data['teamUserType'] = teamUserType;

    return data;
  }

  bool isTeamAdmin() {
    return teamUserType > 1 ? true : false;
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

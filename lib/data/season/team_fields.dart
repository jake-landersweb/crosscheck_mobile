import '../root.dart';

class SeasonUserTeamFields {
  String? teamUserNote;
  String? orgId;
  LastSeason? lastSeason;
  late int teamUserType;
  // new fields
  late String pos;
  late List<CustomField> customFields;
  late int validationStatus;

  SeasonUserTeamFields({
    this.teamUserNote,
    this.orgId,
    this.lastSeason,
    required this.teamUserType,
    required this.pos,
    required this.customFields,
    required this.validationStatus,
  });

  SeasonUserTeamFields.empty() {
    teamUserNote = "";
    orgId = "";
    lastSeason = LastSeason.empty();
    teamUserType = 1;
    pos = "";
    customFields = [];
    validationStatus = 1;
  }

  SeasonUserTeamFields.of(SeasonUserTeamFields user) {
    teamUserNote = user.teamUserNote;
    orgId = user.orgId;
    lastSeason = user.lastSeason;
    teamUserType = user.teamUserType;
    pos = user.pos;
    customFields = user.customFields;
    validationStatus = user.validationStatus;
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
    validationStatus = json['validationStatus'].round() ?? 1;
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
    data['validationStatus'] = validationStatus;

    return data;
  }

  bool isTeamAdmin() {
    return teamUserType > 1 ? true : false;
  }

  bool isOwner() {
    return teamUserType == 3 ? true : false;
  }

  String getValidationStatus() {
    switch (validationStatus) {
      case 1:
        return "Active";
      case 2:
        return "Invited";
      case 0:
        return "Recuit";
      default:
        return "Unknown";
    }
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

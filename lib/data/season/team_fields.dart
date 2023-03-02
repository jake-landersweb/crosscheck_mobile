import '../root.dart';

class SeasonUserTeamFields {
  String? teamUserNote;
  String? orgId;
  LastSeason? lastSeason;
  late int teamUserType;
  late String pos;
  late List<CustomField> customFields;
  late int validationStatus;
  late String jerseySize;
  late String jerseyNumber;
  late String email;

  SeasonUserTeamFields({
    this.teamUserNote,
    this.orgId,
    this.lastSeason,
    required this.teamUserType,
    required this.pos,
    required this.customFields,
    required this.validationStatus,
    required this.jerseySize,
    required this.jerseyNumber,
    required this.email,
  });

  SeasonUserTeamFields.empty() {
    teamUserNote = "";
    orgId = "";
    lastSeason = LastSeason.empty();
    teamUserType = 1;
    pos = "";
    customFields = [];
    validationStatus = 0;
    jerseySize = "";
    jerseyNumber = "";
    email = "";
  }

  SeasonUserTeamFields.of(SeasonUserTeamFields user) {
    teamUserNote = user.teamUserNote;
    orgId = user.orgId;
    lastSeason = user.lastSeason;
    teamUserType = user.teamUserType;
    pos = user.pos;
    customFields = [for (var i in user.customFields) i.clone()];
    validationStatus = user.validationStatus;
    jerseySize = user.jerseySize;
    jerseyNumber = user.jerseyNumber;
    email = user.email;
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
    validationStatus = json['validationStatus']?.round() ?? 1;
    if (json.containsKey("customFields")) {
      json['customFields']
          .forEach((v) => customFields.add(CustomField.fromJson(v)));
    }
    jerseySize = json['jerseySize'] ?? "";
    jerseyNumber = json['jerseyNumber'] ?? "";
    email = json['email'] ?? "";
  }

  Map<String, dynamic> toJson() {
    return {
      "teamUserNote": teamUserNote,
      "teamUserType": teamUserType,
      "pos": pos,
      "customFields": customFields.map((e) => e.toJson()).toList(),
      "validationStatus": validationStatus,
      "jerseySize": jerseySize,
      "jerseyNumber": jerseyNumber,
      "email": email,
    };
  }

  bool isTeamAdmin() {
    return teamUserType > 1 ? true : false;
  }

  bool isOwner() {
    return teamUserType == 3 ? true : false;
  }

  String getTeamUserTypeName() {
    switch (teamUserType) {
      case 3:
        return "Owner";
      case 2:
        return "Manager";
      case 1:
        return "Player";
      default:
        return "Unknown";
    }
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

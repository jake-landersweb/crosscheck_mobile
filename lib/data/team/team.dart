import 'package:equatable/equatable.dart';

import 'root.dart';
import '../root.dart';

class Team extends Equatable {
  late String teamId;
  late String title;
  late String teamCode;
  late String teamNote;
  late String website;
  late String color;
  late String image;
  late bool isLight;
  late TeamPositions positions;
  late List<CustomField> customFields;
  late List<CustomField> customUserFields;
  late bool showNicknames;
  late TeamStat stats;
  late int sportCode;

  Team({
    required this.teamId,
    required this.title,
    required this.teamCode,
    required this.website,
    required this.color,
    required this.image,
    required this.isLight,
    required this.teamNote,
    required this.positions,
    required this.customFields,
    required this.customUserFields,
    required this.showNicknames,
    required this.stats,
    required this.sportCode,
  });

  // empty object
  Team.empty() {
    teamId = "";
    title = "";
    teamCode = "";
    teamNote = "";
    website = "";
    color = "";
    isLight = false;
    image = "";
    positions =
        TeamPositions(isActive: false, defaultPosition: "", available: []);
    customFields = [];
    customUserFields = [];
    showNicknames = false;
    stats = TeamStat.empty();
    sportCode = 0;
  }

  Team clone() => Team(
        teamId: teamId,
        title: title,
        teamCode: teamCode,
        website: website,
        color: color,
        image: image,
        teamNote: teamNote,
        isLight: isLight,
        positions: positions.clone(),
        customFields: [for (var i in customFields) i.clone()],
        customUserFields: [for (var i in customUserFields) i.clone()],
        showNicknames: showNicknames,
        stats: stats.clone(),
        sportCode: sportCode,
      );

  // for making copies
  Team.of(Team team) {
    teamId = team.teamId;
    title = team.title;
    teamCode = team.teamCode;
    teamNote = team.teamNote;
    website = team.website;
    color = team.color;
    isLight = team.isLight;
    image = team.image;
    positions = team.positions;
    customFields = team.customFields;
    customUserFields = team.customUserFields;
    showNicknames = team.showNicknames;
    stats = team.stats.clone();
    sportCode = team.sportCode;
  }

  // converting from json
  Team.fromJson(dynamic json) {
    teamId = json['teamId'];
    title = json['title'];
    teamCode = json['teamCode'] ?? "";
    teamNote = json['teamNote'] ?? "";
    website = json['website'] ?? "";
    color = json['color'] ?? "";
    image = json['image'] ?? "";
    isLight = json['isLight'] ?? false;
    positions = TeamPositions.fromJson(json['positions']);
    customFields = [];
    if (json['customFields'] != null) {
      json['customFields']
          .forEach((v) => customFields.add(CustomField.fromJson(v)));
    }
    customUserFields = [];
    if (json['customUserFields'] != null) {
      json['customUserFields']
          .forEach((v) => customUserFields.add(CustomField.fromJson(v)));
    }
    showNicknames = json['showNicknames'] ?? false;
    if (json['stats'] == null) {
      stats = TeamStat.empty();
    } else {
      stats = TeamStat.fromJson(json['stats']);
    }
    sportCode = json['taemType'] ?? 0;
  }

  void setImage(String image) {
    this.image = image;
  }

  // converting to json
  Map<String, dynamic> toJson() {
    return {
      'teamId': teamId,
      'title': title,
      'teamCode': teamCode,
      'teamNote': teamNote,
      'positions': positions.toJson(),
      "stats": stats.toJson(),
      "teamType": sportCode,
    };
  }

  Team.hockey() {
    teamId = "";
    title = "My Hockey Team";
    teamCode = "";
    teamNote = "";
    website = "https://www.google.com";
    color = "7bc5d6";
    isLight = false;
    image = "";
    positions = TeamPositions(
      isActive: true,
      defaultPosition: "Center",
      available: [
        "Center",
        "Left Wing",
        "Right Wing",
        "Left Defense",
        "Right Defense",
        "Goalie",
      ],
    );
    customFields = [
      CustomField(
          title: "Rink Address", type: "S", value: "1000 Sherwood Blvd"),
    ];
    customUserFields = [
      CustomField(title: "USA Hockey Number", type: "S", value: ""),
      CustomField(title: "Has Paid Team Dues", type: "B", value: "false"),
      CustomField(title: "Handness", type: "S", value: "Right"),
    ];
    showNicknames = true;
    stats = TeamStat(
      isActive: true,
      stats: [
        StatItem(title: "Goals", isActive: true),
        StatItem(title: "Assists", isActive: true),
        StatItem(title: "PIMs", isActive: true),
      ],
    );
    sportCode = 1;
  }

  Team.golf() {
    teamId = "";
    title = "My Golf Team";
    teamCode = "";
    teamNote = "";
    website = "https://www.google.com";
    color = "7bc5d6";
    isLight = false;
    image = "";
    positions = TeamPositions(
      isActive: true,
      defaultPosition: "",
      available: [],
    );
    customFields = [
      CustomField(
          title: "Club House Address", type: "S", value: "1000 Sherwood Blvd"),
    ];
    customUserFields = [
      CustomField(title: "Handness", type: "S", value: "Right"),
      CustomField(title: "Has Paid Dues", type: "B", value: "false"),
      CustomField(title: "Handicap", type: "S", value: "15"),
    ];
    showNicknames = true;
    stats = TeamStat(
      isActive: true,
      stats: const [],
    );
    sportCode = 2;
  }

  // comparing objects
  @override
  List<Object> get props => [teamId, title];
}

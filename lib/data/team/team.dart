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
  // late TeamStat stats;
  late int sportCode;
  late String timezone;

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
    // required this.stats,
    required this.sportCode,
    required this.timezone,
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
    positions = TeamPositions(
      isActive: false,
      defaultPosition: "",
      available: [],
      mvp: "",
    );
    customFields = [];
    customUserFields = [];
    showNicknames = false;
    // stats = TeamStat.empty();
    sportCode = 0;
    timezone = "US/Pacific";
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
        // stats: stats.clone(),
        sportCode: sportCode,
        timezone: timezone,
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
    // stats = team.stats.clone();
    sportCode = team.sportCode;
    timezone = team.timezone;
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
    // if (json['stats'] == null) {
    //   stats = TeamStat.empty();
    // } else {
    //   stats = TeamStat.fromJson(json['stats']);
    // }
    sportCode = json['taemType'] ?? 0;
    timezone = json['tz'] ?? "US/Pacific";
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
      // "stats": stats.toJson(),
      "teamType": sportCode,
      "tz": timezone,
    };
  }

  Team.hockey() {
    teamId = "";
    title = "";
    teamCode = "";
    teamNote = "My hockey team";
    website = "https://www.google.com";
    color = "7bc5d6";
    isLight = true;
    image = "";
    positions = TeamPositions(
      isActive: true,
      defaultPosition: "Forward",
      available: ["Forward", "Defense", "Goalie"],
      mvp: "Goalie",
    );
    customFields = [
      CustomField(
          title: "Rink Address", type: "S", value: "1000 Sherwood Blvd"),
    ];
    customUserFields = [
      CustomField(title: "USA Hockey Number", type: "S", value: ""),
      CustomField(title: "Handness", type: "S", value: "Right"),
    ];
    showNicknames = true;
    sportCode = 1;
    timezone = "US/Pacific";
  }

  Team.basketball() {
    teamId = "";
    title = "";
    teamCode = "";
    teamNote = "My basketball team";
    website = "https://www.google.com";
    color = "7bc5d6";
    isLight = true;
    image = "";
    positions = TeamPositions(
      isActive: true,
      defaultPosition: "Point guard",
      available: [
        "Point guard",
        "Shooting guard",
        "Center",
        "Power forward",
        "Small forward"
      ],
      mvp: "Point guard",
    );
    customFields = [
      CustomField(
          title: "Arena Address", type: "S", value: "1000 Sherwood Blvd"),
    ];
    customUserFields = [];
    showNicknames = true;
    sportCode = 2;
    timezone = "US/Pacific";
  }

  Team.football() {
    teamId = "";
    title = "";
    teamCode = "";
    teamNote = "My football team";
    website = "https://www.google.com";
    color = "7bc5d6";
    isLight = true;
    image = "";
    positions = TeamPositions(
      isActive: true,
      defaultPosition: "Quarterback",
      available: [
        "Quarterback",
        "Running back",
        "Wide receiver",
        "Tight end",
        "Left guard",
        "Right guard",
        "Center",
        "Left tackle",
        "Right tackle",
        "Nose tackle",
        "Defensive tackle",
        "Offensive tackle",
        "Offensive lineman",
        "Defensive lineman",
        "Defensive end",
        "Cornerback",
        "Linebacker",
        "Free safety",
        "Strong safety",
        "Kicker",
        "Returner",
        "Snapper",
        "Long snapper",
      ],
      mvp: "Quarterback",
    );
    customFields = [
      CustomField(
          title: "Field Address", type: "S", value: "1000 Sherwood Blvd"),
    ];
    customUserFields = [];
    showNicknames = true;
    sportCode = 3;
    timezone = "US/Pacific";
  }

  Team.golf() {
    teamId = "";
    title = "";
    teamCode = "";
    teamNote = "My golf team";
    website = "https://www.google.com";
    color = "7bc5d6";
    isLight = true;
    image = "";
    positions = TeamPositions(
      isActive: true,
      defaultPosition: "",
      available: [],
      mvp: "",
    );
    customFields = [
      CustomField(
          title: "Club House Address", type: "S", value: "1000 Sherwood Blvd"),
    ];
    customUserFields = [
      CustomField(title: "Handness", type: "S", value: "Right"),
      CustomField(title: "Handicap", type: "S", value: "15"),
    ];
    showNicknames = true;
    sportCode = 4;
  }

  Team.soccer() {
    teamId = "";
    title = "";
    teamCode = "";
    teamNote = "My soccer team";
    website = "https://www.google.com";
    color = "7bc5d6";
    isLight = true;
    image = "";
    positions = TeamPositions(
        isActive: true,
        defaultPosition: "Center midfielder",
        available: [
          "Goalie",
          "Right full-back",
          "Left full-back",
          "Center-back",
          "Defensive midfielder",
          "Right midfielder",
          "Center midfielder",
          "Striker",
          "Center forward",
          "Left forward",
          "Default = Center midfielder",
        ],
        mvp: "Goalie");
    customFields = [
      CustomField(
          title: "Field Address", type: "S", value: "1000 Sherwood Blvd"),
    ];
    customUserFields = [];
    showNicknames = true;
    sportCode = 5;
    timezone = "US/Pacific";
  }

  Team.baseball() {
    teamId = "";
    title = "";
    teamCode = "";
    teamNote = "My baseball team";
    website = "https://www.google.com";
    color = "7bc5d6";
    isLight = true;
    image = "";
    positions = TeamPositions(
      isActive: true,
      defaultPosition: "First base",
      mvp: "Pitcher",
      available: [
        "Pitcher",
        "Catcher",
        "First base",
        "Second base",
        "Third base",
        "Shortstop",
        "Left field",
        "Center field",
        "Right field",
        "Default = First baseman",
      ],
    );
    customFields = [
      CustomField(
          title: "Field Address", type: "S", value: "1000 Sherwood Blvd"),
    ];
    customUserFields = [
      CustomField(title: "Handness", type: "S", value: "Right"),
    ];
    showNicknames = true;
    sportCode = 6;
    timezone = "US/Pacific";
  }

  // comparing objects
  @override
  List<Object> get props => [teamId, title];
}

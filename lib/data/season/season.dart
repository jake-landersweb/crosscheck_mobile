import 'package:crosscheck_sports/extras/global_funcs.dart';
import 'package:equatable/equatable.dart';
import 'package:crosscheck_sports/data/root.dart';
import 'package:crosscheck_sports/data/team/team_stat.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

const String defaultIgnoreString = "versus, vs, at, @, .";

class Season extends Equatable {
  late String id;
  late String title;
  late String seasonId;
  late String seasonCode;
  late int seasonStatus;
  late String seasonNote;
  late TeamPositions positions;
  late List<CustomField> customFields;
  late List<CustomField> customUserFields;
  late List<CustomField> eventCustomFieldsTemplate;
  late List<CustomField> eventCustomUserFieldsTemplate;
  late String website;
  late int sportCode;
  late TeamStat stats;
  late bool hasStats;
  late List<String> opponents;
  late String timezone;
  late String calendarUrl;
  late bool parseOpponents;
  late String calendarTitleIgnoreString;

  Season({
    required this.id,
    required this.title,
    required this.seasonId,
    required this.seasonCode,
    required this.seasonStatus,
    required this.seasonNote,
    required this.positions,
    required this.customFields,
    required this.customUserFields,
    required this.website,
    required this.sportCode,
    required this.eventCustomFieldsTemplate,
    required this.eventCustomUserFieldsTemplate,
    required this.stats,
    required this.hasStats,
    required this.opponents,
    required this.timezone,
    required this.calendarUrl,
    required this.parseOpponents,
    required this.calendarTitleIgnoreString,
  });

  // empty object
  Season.empty() {
    id = "";
    title = "";
    seasonId = "";
    seasonCode = "";
    seasonStatus = 1;
    seasonNote = "";
    positions = TeamPositions.empty();
    customFields = [];
    customUserFields = [];
    website = "";
    sportCode = 0;
    eventCustomFieldsTemplate = [];
    eventCustomUserFieldsTemplate = [];
    stats = TeamStat.empty();
    hasStats = true;
    opponents = [];
    timezone = "US/Pacific";
    calendarUrl = "";
    parseOpponents = false;
    calendarTitleIgnoreString = defaultIgnoreString;
  }

  // for creating a copy
  Season.of(Season season) {
    id = season.id;
    title = season.title;
    seasonId = season.seasonId;
    seasonCode = season.seasonCode;
    seasonStatus = season.seasonStatus;
    seasonNote = season.seasonNote;
    positions = season.positions;
    customFields = season.customFields;
    customUserFields = season.customUserFields;
    website = season.website;
    sportCode = season.sportCode;
    stats = TeamStat(
        stats: List.of(season.stats.stats), isActive: season.stats.isActive);
    hasStats = season.hasStats;
    opponents = season.opponents;
    timezone = season.timezone;
    calendarUrl = season.calendarUrl;
    parseOpponents = season.parseOpponents;
    calendarTitleIgnoreString = season.calendarTitleIgnoreString;
  }

  // converting from json
  Season.fromJson(dynamic json) {
    id = json['id'];
    title = json['title'];
    seasonId = json['seasonId'];
    seasonCode = json['seasonCode'] ?? "";
    seasonStatus = json['seasonStatus'].round();
    seasonNote = json['seasonNote'] ?? "";
    positions = json['positions'] == null
        ? TeamPositions.empty()
        : TeamPositions.fromJson(json['positions']);
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
    website = json['website'] ?? "";
    sportCode = json['sportCode']?.round() ?? 0;
    eventCustomFieldsTemplate = [];
    if (json['eventCustomFieldsTemplate'] != null) {
      json['eventCustomFieldsTemplate'].forEach(
          (v) => eventCustomFieldsTemplate.add(CustomField.fromJson(v)));
    }
    eventCustomUserFieldsTemplate = [];
    if (json['eventCustomUserFieldsTemplate'] != null) {
      json['eventCustomUserFieldsTemplate'].forEach(
          (v) => eventCustomUserFieldsTemplate.add(CustomField.fromJson(v)));
    }
    if (json['stats'] != null) {
      stats = TeamStat.fromJson(json['stats']);
    } else {
      stats = TeamStat.empty();
    }
    hasStats = json['hasStats'] ?? true;
    opponents = [];
    if (json['opponents'] != null) {
      for (var i in json['opponents']) {
        opponents.add(i);
      }
    }
    timezone = json['tz'] ?? "US/Pacific";
    calendarUrl = json['calendarUrl'] ?? "";
    parseOpponents = json['parseOpponents'] ?? false;
    calendarTitleIgnoreString =
        json['calendarTitleIgnoreString'] ?? defaultIgnoreString;
  }

  // converting from json
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "title": title,
      "seasonId": seasonId,
      "seasonCode": seasonCode,
      "seasonStatus": seasonStatus,
      "seasonNote": seasonNote,
      "positions": positions.toJson(),
      "customFields": customFields.map((e) => e.toJson()).toList(),
      "customUserFields": customUserFields.map((e) => e.toJson()).toList(),
      "website": website,
      "sportCode": sportCode,
      "stats": stats.toJson(),
      "hasStats": hasStats,
      "opponents": opponents,
      "tz": timezone,
      "calendarUrl": calendarUrl,
      "parseOpponents": parseOpponents,
      "calendarTitleIgnoreString": calendarTitleIgnoreString,
    };
  }

  String status() {
    switch (seasonStatus) {
      case 1:
        return "Active";
      case 2:
        return "Future";
      default:
        return "Previous";
    }
  }

  Widget mvpIcon(BuildContext context, Color color, {double? size}) {
    return SvgPicture.asset(mvpPath(positions.mvp), color: color, height: size);
  }

  // templates
  Season.hockey() {
    id = "";
    title = "";
    seasonId = "";
    seasonCode = "";
    seasonStatus = 2;
    seasonNote = "My hockey team";
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
      CustomField(title: "Handness", type: "S", value: ""),
      CustomField(title: "Has Paid Dues", type: "B", value: "false"),
    ];
    eventCustomFieldsTemplate = [
      CustomField(title: "Dress Code", type: "S", value: ""),
    ];
    eventCustomUserFieldsTemplate = [
      CustomField(title: "Needs Jersey", type: "B", value: "false"),
    ];
    stats = TeamStat(isActive: true, stats: [
      StatItem(title: "Goals", isActive: true),
      StatItem(title: "Assists", isActive: true),
      StatItem(title: "PIMs", isActive: true),
    ]);
    website = "";
    sportCode = 1;
    opponents = [];
    timezone = "US/Pacific";
    calendarUrl = "";
    parseOpponents = false;
    calendarTitleIgnoreString = defaultIgnoreString;
  }

  Season.basketball() {
    id = "";
    title = "";
    seasonId = "";
    seasonCode = "";
    seasonStatus = 2;
    seasonNote = "My basketball season";
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
      CustomField(title: "Arena Address", type: "S", value: ""),
    ];
    customUserFields = [
      CustomField(title: "USA Basketball Number", type: "S", value: ""),
    ];
    eventCustomFieldsTemplate = [
      CustomField(title: "Dress Code", type: "S", value: ""),
    ];
    eventCustomUserFieldsTemplate = [
      CustomField(title: "Needs Jersey", type: "B", value: "false"),
    ];
    stats = TeamStat(isActive: true, stats: [
      StatItem(title: "Points", isActive: true),
      StatItem(title: "Field Goals", isActive: true),
      StatItem(title: "3 Pointers", isActive: true),
      StatItem(title: "Fouls", isActive: true),
    ]);
    website = "";
    sportCode = 2;
    opponents = [];
    timezone = "US/Pacific";
    calendarUrl = "";
    parseOpponents = false;
    calendarTitleIgnoreString = defaultIgnoreString;
  }

  Season.football() {
    id = "";
    title = "";
    seasonId = "";
    seasonCode = "";
    seasonStatus = 2;
    seasonNote = "My football season";
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
      CustomField(title: "Field Address", type: "S", value: ""),
    ];
    customUserFields = [
      CustomField(title: "Has Paid Dues", type: "B", value: ""),
    ];
    eventCustomFieldsTemplate = [
      CustomField(title: "Dress Code", type: "S", value: ""),
    ];
    eventCustomUserFieldsTemplate = [
      CustomField(title: "Needs Jersey", type: "B", value: "false"),
    ];
    stats = TeamStat(isActive: true, stats: [
      StatItem(title: "Yards", isActive: true),
      StatItem(title: "Touchdowns", isActive: true),
      StatItem(title: "Catches", isActive: true),
      StatItem(title: "Sacks", isActive: true),
      StatItem(title: "Tackles", isActive: true),
      StatItem(title: "Interceptions", isActive: true),
      StatItem(title: "Fumbles", isActive: true),
    ]);
    website = "";
    sportCode = 3;
    opponents = [];
    timezone = "US/Pacific";
    calendarUrl = "";
    parseOpponents = false;
    calendarTitleIgnoreString = defaultIgnoreString;
  }

  Season.golf() {
    id = "";
    title = "";
    seasonId = "";
    seasonCode = "";
    seasonStatus = 2;
    seasonNote = "My golf season";
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
      CustomField(title: "Has Paid Dues", type: "B", value: "false"),
      CustomField(title: "Handicap", type: "S", value: "15"),
    ];
    eventCustomFieldsTemplate = [
      CustomField(title: "Dress Code", type: "S", value: "Formal"),
      CustomField(title: "Golf Carts Supplied", type: "B", value: "true"),
    ];
    eventCustomUserFieldsTemplate = [
      CustomField(title: "Need Rental Clubs", type: "B", value: "false"),
    ];
    stats = TeamStat(isActive: true, stats: [
      StatItem(title: "Strokes", isActive: true),
      StatItem(title: "Puts", isActive: true),
      StatItem(title: "Chips", isActive: true),
      StatItem(title: "Lost Balls", isActive: true),
    ]);
    website = "";
    sportCode = 4;
    timezone = "US/Pacific";
    calendarUrl = "";
    parseOpponents = false;
    calendarTitleIgnoreString = defaultIgnoreString;
  }

  Season.soccer() {
    id = "";
    title = "";
    seasonId = "";
    seasonCode = "";
    seasonStatus = 2;
    seasonNote = "My soccer team";
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
      mvp: "Goalie",
    );
    customFields = [
      CustomField(title: "Field Address", type: "S", value: ""),
    ];
    customUserFields = [
      CustomField(title: "USA Soccer Number", type: "S", value: ""),
    ];
    eventCustomFieldsTemplate = [
      CustomField(title: "Dress Code", type: "S", value: ""),
    ];
    eventCustomUserFieldsTemplate = [
      CustomField(title: "Needs Jersey", type: "B", value: "false"),
    ];
    stats = TeamStat(isActive: true, stats: [
      StatItem(title: "Goals", isActive: true),
      StatItem(title: "Assists", isActive: true),
      StatItem(title: "Shots", isActive: true),
      StatItem(title: "Blocks", isActive: true),
    ]);
    website = "";
    sportCode = 5;
    opponents = [];
    timezone = "US/Pacific";
    calendarUrl = "";
    parseOpponents = false;
    calendarTitleIgnoreString = defaultIgnoreString;
  }

  Season.baseball() {
    id = "";
    title = "";
    seasonId = "";
    seasonCode = "";
    seasonStatus = 2;
    seasonNote = "";
    positions = TeamPositions(
      isActive: true,
      defaultPosition: "First base",
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
      mvp: "Pitcher",
    );
    customFields = [
      CustomField(title: "Field Address", type: "S", value: ""),
    ];
    customUserFields = [
      CustomField(title: "Handness", type: "S", value: ""),
    ];
    eventCustomFieldsTemplate = [
      CustomField(title: "Dress Code", type: "S", value: ""),
    ];
    eventCustomUserFieldsTemplate = [
      CustomField(title: "Needs Jersey", type: "B", value: "false"),
    ];
    stats = TeamStat(isActive: true, stats: [
      StatItem(title: "Home Runs", isActive: true),
      StatItem(title: "Hits", isActive: true),
      StatItem(title: "Strike-outs", isActive: true),
      StatItem(title: "Stolen Bases", isActive: true),
      StatItem(title: "At-Bats", isActive: true),
    ]);
    website = "";
    sportCode = 6;
    opponents = [];
    timezone = "US/Pacific";
    calendarUrl = "";
    parseOpponents = false;
    calendarTitleIgnoreString = defaultIgnoreString;
  }

  IconData getSportIcon() {
    switch (sportCode) {
      case 1:
        return Icons.sports_hockey;
      case 2:
        return Icons.sports_football;
      case 3:
        return Icons.sports_basketball;
      case 4:
        return Icons.sports_soccer;
      case 5:
        return Icons.sports_baseball;
      default:
        return Icons.close;
    }
  }

  // values to compare
  @override
  List<Object> get props => [title, seasonId];
}

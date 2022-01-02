import 'package:equatable/equatable.dart';
import 'package:pnflutter/data/root.dart';
import 'package:pnflutter/data/season/season_stat.dart';
import 'package:flutter/material.dart';

class Season extends Equatable {
  late String id;
  late String title;
  late String seasonId;
  late String seasonCode;
  late int seasonStatus;
  late String seasonNote;
  late TeamStat stats;
  late bool showNicknames;
  late TeamPositions positions;
  late List<CustomField> customFields;
  late List<CustomField> customUserFields;
  late List<CustomField> eventCustomFieldsTemplate;
  late List<CustomField> eventCustomUserFieldsTemplate;
  late String website;
  late int sportCode;

  Season({
    required this.id,
    required this.title,
    required this.seasonId,
    required this.seasonCode,
    required this.seasonStatus,
    required this.seasonNote,
    required this.stats,
    required this.showNicknames,
    required this.positions,
    required this.customFields,
    required this.customUserFields,
    required this.website,
    required this.sportCode,
    required this.eventCustomFieldsTemplate,
    required this.eventCustomUserFieldsTemplate,
  });

  // empty object
  Season.empty() {
    id = "";
    title = "";
    seasonId = "";
    seasonCode = "";
    seasonStatus = 1;
    seasonNote = "";
    stats = TeamStat.empty();
    showNicknames = false;
    positions = TeamPositions.empty();
    customFields = [];
    customUserFields = [];
    website = "";
    sportCode = 0;
    eventCustomFieldsTemplate = [];
    eventCustomUserFieldsTemplate = [];
  }

  // for creating a copy
  Season.of(Season season) {
    id = season.id;
    title = season.title;
    seasonId = season.seasonId;
    seasonCode = season.seasonCode;
    seasonStatus = season.seasonStatus;
    seasonNote = season.seasonNote;
    stats = season.stats;
    showNicknames = season.showNicknames;
    positions = season.positions;
    customFields = season.customFields;
    customUserFields = season.customUserFields;
    website = season.website;
    sportCode = season.sportCode;
  }

  // converting from json
  Season.fromJson(dynamic json) {
    id = json['id'];
    title = json['title'];
    seasonId = json['seasonId'];
    seasonCode = json['seasonCode'] ?? "";
    seasonStatus = json['seasonStatus'].round();
    seasonNote = json['seasonNote'] ?? "";
    stats = TeamStat.fromJson(json['stats']);
    showNicknames = json['showNicknames'] ?? false;
    positions = json['positions'] == null
        ? TeamPositions.empty()
        : TeamPositions.fromJson(json['positions']);
    customFields = [];
    json['customFields']
        .forEach((v) => customFields.add(CustomField.fromJson(v)));
    customUserFields = [];
    json['customUserFields']
        .forEach((v) => customUserFields.add(CustomField.fromJson(v)));
    website = json['website'] ?? "";
    sportCode = json['sportCode'].round() ?? 0;
    eventCustomFieldsTemplate = [];
    if (json['eventCustomFieldsTemplate'] != null) {
      json['eventCustomFieldsTemplate']
          .forEach((v) => customFields.add(CustomField.fromJson(v)));
    }
    eventCustomUserFieldsTemplate = [];
    if (json['eventCustomUserFieldsTemplate'] != null) {
      json['eventCustomUserFieldsTemplate']
          .forEach((v) => customFields.add(CustomField.fromJson(v)));
    }
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
      "stats": stats.toJson(),
      "showNicknames": showNicknames,
      "positions": positions.toJson(),
      "customFields": customFields.map((e) => e.toJson()).toList(),
      "customUserFields": customUserFields.map((e) => e.toJson()).toList(),
      "website": website,
      "sportCode": sportCode,
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

  // templates
  Season.hockey() {
    id = "";
    title = "";
    seasonId = "";
    seasonCode = "";
    seasonStatus = 2;
    seasonNote = "";
    stats = TeamStat(isActive: true, stats: [
      StatItem(title: "Goals", isActive: true),
      StatItem(title: "Assists", isActive: true),
      StatItem(title: "Penalty Minutes", isActive: true),
      StatItem(title: "Plus / Minus", isActive: true),
    ]);
    showNicknames = false;
    positions = TeamPositions(
      isActive: true,
      defaultPosition: "Forward",
      available: [
        "Left Wing",
        "Right Wing",
        "Center",
        "Left Defense",
        "Right Defense",
        "Goalie"
      ],
    );
    customFields = [
      CustomField(title: "Rink Address", type: "S", value: ""),
    ];
    customUserFields = [
      CustomField(title: "USA Hockey Number", type: "S", value: ""),
    ];
    eventCustomFieldsTemplate = [];
    eventCustomUserFieldsTemplate = [];
    website = "";
    sportCode = 1;
  }

  Season.football() {
    id = "";
    title = "";
    seasonId = "";
    seasonCode = "";
    seasonStatus = 2;
    seasonNote = "";
    stats = TeamStat(isActive: true, stats: [
      StatItem(title: "Passing", isActive: true),
      StatItem(title: "Rushing", isActive: true),
      StatItem(title: "Recieving", isActive: true),
      StatItem(title: "Touchdowns", isActive: true),
      StatItem(title: "Tackles", isActive: true),
      StatItem(title: "Sacks", isActive: true),
      StatItem(title: "Interceptions", isActive: true),
      StatItem(title: "Returning", isActive: true),
      StatItem(title: "Kicking", isActive: true),
      StatItem(title: "Punting", isActive: true),
    ]);
    showNicknames = false;
    positions = TeamPositions(
      isActive: true,
      defaultPosition: "Quaterback",
      available: [
        "Quarterback",
        "Running Back",
        "Fullback",
        "Wide Reciever",
        "Tight End",
        "Offensive Tackle",
        "Offensive Guard",
        "Center",
        "Nose Tackle",
        "Defensive Tackle",
        "Middle Linebacker",
        "Outside Linebacker",
        "Cornerback",
        "Free Safety",
        "Strong Safety",
        "Kicker",
        "Punter",
        "Long Snapper",
        "Holder",
        "Kick Returner",
        "Punt Returner",
      ],
    );
    customFields = [
      CustomField(title: "Stadium Address", type: "S", value: ""),
    ];
    customUserFields = [
      CustomField(title: "USA Football Number", type: "S", value: ""),
    ];
    eventCustomFieldsTemplate = [];
    eventCustomUserFieldsTemplate = [];
    website = "";
    sportCode = 2;
  }

  Season.basketball() {
    id = "";
    title = "";
    seasonId = "";
    seasonCode = "";
    seasonStatus = 2;
    seasonNote = "";
    stats = TeamStat(isActive: true, stats: [
      StatItem(title: "Points", isActive: true),
      StatItem(title: "Rebounds", isActive: true),
      StatItem(title: "Assists", isActive: true),
      StatItem(title: "Blocks", isActive: true),
      StatItem(title: "Steals", isActive: true),
    ]);
    showNicknames = false;
    positions = TeamPositions(
      isActive: true,
      defaultPosition: "Point Guard",
      available: [
        "Point Guard",
        "Shooting Guard",
        "Small Forward",
        "Power Forward",
        "Center",
      ],
    );
    customFields = [
      CustomField(title: "Arena Address", type: "S", value: ""),
    ];
    customUserFields = [
      CustomField(title: "USA Basketball Number", type: "S", value: ""),
    ];
    eventCustomFieldsTemplate = [];
    eventCustomUserFieldsTemplate = [];
    website = "";
    sportCode = 3;
  }

  Season.soccer() {
    id = "";
    title = "";
    seasonId = "";
    seasonCode = "";
    seasonStatus = 2;
    seasonNote = "";
    stats = TeamStat(isActive: true, stats: [
      StatItem(title: "Goals", isActive: true),
      StatItem(title: "Assists", isActive: true),
      StatItem(title: "Yellow Cards", isActive: true),
      StatItem(title: "Red Cards", isActive: true),
    ]);
    showNicknames = false;
    positions = TeamPositions(
      isActive: true,
      defaultPosition: "Center Forward",
      available: [
        "GoalKeeper",
        "Centerback",
        "Sweeper",
        "Fullback",
        "Wingback",
        "Center Midfielder",
        "Defending Midfielder",
        "Attacking Midfielder",
        "Wide Midfielder",
        "Center Forward",
        "Second Striker",
        "Winger"
      ],
    );
    customFields = [
      CustomField(title: "Arena Address", type: "S", value: ""),
    ];
    customUserFields = [
      CustomField(title: "USA Soccer Number", type: "S", value: ""),
    ];
    eventCustomFieldsTemplate = [];
    eventCustomUserFieldsTemplate = [];
    website = "";
    sportCode = 4;
  }

  Season.baseball() {
    id = "";
    title = "";
    seasonId = "";
    seasonCode = "";
    seasonStatus = 2;
    seasonNote = "";
    stats = TeamStat(isActive: true, stats: [
      StatItem(title: "Batting Average", isActive: true),
      StatItem(title: "Home Runs", isActive: true),
      StatItem(title: "Runs Batted In", isActive: true),
      StatItem(title: "Hits", isActive: true),
      StatItem(title: "Stolen Bases", isActive: true),
      StatItem(title: "Wins", isActive: true),
      StatItem(title: "Earned Run Average", isActive: true),
      StatItem(title: "Saves", isActive: true),
      StatItem(title: "Strikeouts", isActive: true),
    ]);
    showNicknames = false;
    positions = TeamPositions(
      isActive: true,
      defaultPosition: "Pitcher",
      available: [
        "Pitcher",
        "Catcher",
        "First Base",
        "Second Base",
        "Third Base",
        "Shortstop",
        "Left Field",
        "Center Field",
        "Right Field"
      ],
    );
    customFields = [
      CustomField(title: "Arena Address", type: "S", value: ""),
    ];
    customUserFields = [
      CustomField(title: "USA Baseball Number", type: "S", value: ""),
    ];
    eventCustomFieldsTemplate = [];
    eventCustomUserFieldsTemplate = [];
    website = "";
    sportCode = 5;
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

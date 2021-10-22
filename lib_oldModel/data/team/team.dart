import 'package:equatable/equatable.dart';

import 'root.dart';

class Team extends Equatable {
  late String teamId;
  late String title;
  String? image;
  bool? isLight;
  String? teamLink;
  String? teamCode;
  String? teamNote;
  String? color;
  TeamStyle? teamStyle;
  TeamInfo? teamInfo;
  TeamPositions? positions;

  Team({
    required this.teamId,
    required this.title,
    this.image,
    this.isLight = true,
    this.teamLink,
    this.teamCode,
    this.teamNote,
    this.color,
    this.teamStyle,
    this.teamInfo,
    this.positions,
  });

  // empty object
  Team.empty() {
    teamId = "";
    title = "";
    image = "";
    isLight = true;
    teamLink = "";
    teamCode = "";
    teamNote = "";
    color = "";
    teamStyle = TeamStyle();
    teamInfo = TeamInfo();
    positions = TeamPositions(defaultPosition: 0, available: [0]);
  }

  // for making copies
  Team.of(Team team) {
    teamId = team.teamId;
    title = team.title;
    image = team.image;
    teamLink = team.teamLink;
    teamCode = team.teamCode;
    teamNote = team.teamNote;
    color = team.color;
    teamStyle = team.teamStyle;
    teamInfo = team.teamInfo;
    positions = team.positions;
  }

  // converting from json
  static Team fromJson(dynamic json) {
    Team team = Team(
        teamId: json['teamId'],
        title: json['title'],
        image: json['image'],
        isLight: json['isLight'],
        teamLink: json['teamLink'],
        teamCode: json['teamCode'],
        teamNote: json['teamNote'],
        color: json['color'],
        teamStyle: TeamStyle.fromJson(json['teamStyle']),
        teamInfo: TeamInfo.fromJson(json['teamInfo']),
        positions: TeamPositions.fromJson(json['positions']));
    return team;
  }

  // converting to json
  Map<String, dynamic> toJson() {
    return {
      'teamId': teamId,
      'title': title,
      'image': image,
      'isLight': isLight,
      'teamLink': teamLink,
      'teamCode': teamCode,
      'teamNote': teamNote,
      'color': color,
      'teamStyle': teamStyle,
      'teamInfo': teamInfo,
      'positions': positions,
    };
  }

  // comparing objects
  @override
  List<Object> get props => [teamId, title];
}

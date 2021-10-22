import 'package:equatable/equatable.dart';

import 'root.dart';

class Team extends Equatable {
  late String teamId;
  late String title;
  String? teamCode;
  String? teamNote;
  late TeamStyle teamStyle;
  late TeamInfo teamInfo;
  TeamPositions? positions;

  Team({
    required this.teamId,
    required this.title,
    this.teamCode,
    this.teamNote,
    required this.teamStyle,
    required this.teamInfo,
    this.positions,
  });

  // empty object
  Team.empty() {
    teamId = "";
    title = "";
    teamCode = "";
    teamNote = "";
    teamStyle = TeamStyle();
    teamInfo = TeamInfo();
    positions = TeamPositions(defaultPosition: 0, available: [0]);
  }

  // for making copies
  Team.of(Team team) {
    teamId = team.teamId;
    title = team.title;
    teamCode = team.teamCode;
    teamNote = team.teamNote;
    teamStyle = team.teamStyle;
    teamInfo = team.teamInfo;
    positions = team.positions;
  }

  // converting from json
  static Team fromJson(dynamic json) {
    Team team = Team(
      teamId: json['teamId'],
      title: json['title'],
      teamCode: json['teamCode'],
      teamNote: json['teamNote'],
      teamStyle: TeamStyle.fromJson(json['teamStyle']),
      teamInfo: TeamInfo.fromJson(json['teamInfo']),
      positions: TeamPositions.fromJson(json['positions']),
    );
    return team;
  }

  // converting to json
  Map<String, dynamic> toJson() {
    return {
      'teamId': teamId,
      'title': title,
      'teamCode': teamCode,
      'teamNote': teamNote,
      'teamStyle': teamStyle.toJson(),
      'teamInfo': teamInfo.toJson(),
      'positions': positions?.toJson(),
    };
  }

  // comparing objects
  @override
  List<Object> get props => [teamId, title];
}

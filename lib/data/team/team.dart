import 'package:equatable/equatable.dart';

import 'root.dart';
import '../root.dart';

class Team extends Equatable {
  late String teamId;
  late String title;
  late String teamCode;
  String? teamNote;
  late String website;
  late String color;
  late String image;
  late bool isLight;
  late TeamPositions positions;
  late List<CustomField> customFields;
  late List<CustomField> customUserFields;

  Team({
    required this.teamId,
    required this.title,
    required this.teamCode,
    required this.website,
    required this.color,
    required this.image,
    required this.isLight,
    this.teamNote,
    required this.positions,
    required this.customFields,
    required this.customUserFields,
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
  }

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
  }

  // converting from json
  Team.fromJson(dynamic json) {
    teamId = json['teamId'];
    title = json['title'];
    teamCode = json['teamCode'] ?? "";
    teamNote = json['teamNote'];
    website = json['website'] ?? "";
    color = json['color'] ?? "";
    image = json['image'] ?? "";
    isLight = json['isLight'] ?? false;
    positions = TeamPositions.fromJson(json['positions']);
    customFields = [];
    json['customFields']
        .forEach((v) => customFields.add(CustomField.fromJson(v)));
    customUserFields = [];
    json['customUserFields']
        .forEach((v) => customUserFields.add(CustomField.fromJson(v)));
  }

  // converting to json
  Map<String, dynamic> toJson() {
    return {
      'teamId': teamId,
      'title': title,
      'teamCode': teamCode,
      'teamNote': teamNote,
      'positions': positions.toJson(),
    };
  }

  // comparing objects
  @override
  List<Object> get props => [teamId, title];
}

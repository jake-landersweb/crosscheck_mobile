import 'package:equatable/equatable.dart';
import 'package:pnflutter/data/root.dart';
import 'package:pnflutter/data/season/season_stat.dart';

class Season extends Equatable {
  late String teamId;
  late String title;
  late String seasonId;
  String? seasonLink;
  String? seasonCode;
  late int seasonStatus;
  String? seasonNote;
  // new fields
  List<SeasonStat>? stats;
  TeamInfo? seasonInfo;

  Season({
    required this.teamId,
    required this.title,
    required this.seasonId,
    this.seasonLink,
    this.seasonCode,
    required this.seasonStatus,
    this.seasonNote,
    this.stats,
    this.seasonInfo,
  });

  // empty object
  Season.empty() {
    teamId = "";
    title = "";
    seasonId = "";
    seasonLink = "";
    seasonCode = "";
    seasonStatus = 1;
    seasonNote = "";
    stats = [];
    seasonInfo = TeamInfo();
  }

  // for creating a copy
  Season.of(Season season) {
    teamId = season.teamId;
    title = season.title;
    seasonId = season.seasonId;
    seasonLink = season.seasonLink;
    seasonCode = season.seasonCode;
    seasonStatus = season.seasonStatus;
    seasonNote = season.seasonNote;
    stats = season.stats;
    seasonInfo = season.seasonInfo;
  }

  // converting from json
  static Season fromJson(dynamic json) {
    Season season = Season(
        teamId: json['teamId'],
        title: json['title'],
        seasonId: json['seasonId'],
        seasonLink: json['seasonLink'],
        seasonCode: json['seasonCode'],
        seasonStatus: json['seasonStatus'].round(),
        seasonNote: json['seasonNote'],
        stats: SeasonStat.fromJson(json['stats']),
        seasonInfo: TeamInfo.fromJson(json['seasonInfo']));
    return season;
  }

  // converting from json
  Map<String, dynamic> toJson() {
    return {
      "teamId": teamId,
      "title": title,
      "seasonId": seasonId,
      "seasonLink": seasonLink,
      "seasonCode": seasonCode,
      "seasonStatus": seasonStatus,
      "seasonNote": seasonNote,
    };
  }

  // values to compare
  @override
  List<Object> get props => [title, seasonId];
}

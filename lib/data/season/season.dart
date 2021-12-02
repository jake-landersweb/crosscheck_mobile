import 'package:equatable/equatable.dart';
import 'package:pnflutter/data/root.dart';
import 'package:pnflutter/data/season/season_stat.dart';

class Season extends Equatable {
  late String id;
  late String title;
  late String seasonId;
  String? seasonCode;
  late int seasonStatus;
  String? seasonNote;
  // new fields
  late List<SeasonStat> stats;
  late TeamInfo seasonInfo;
  late int defaultPosition;
  late bool showNicknames;

  Season({
    required this.id,
    required this.title,
    required this.seasonId,
    this.seasonCode,
    required this.seasonStatus,
    this.seasonNote,
    required this.stats,
    required this.seasonInfo,
    required this.defaultPosition,
    required this.showNicknames,
  });

  // empty object
  Season.empty() {
    id = "";
    title = "";
    seasonId = "";
    seasonCode = "";
    seasonStatus = 1;
    seasonNote = "";
    stats = [];
    seasonInfo = TeamInfo();
    defaultPosition = 0;
    showNicknames = false;
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
    seasonInfo = season.seasonInfo;
    defaultPosition = season.defaultPosition;
    showNicknames = season.showNicknames;
  }

  // converting from json
  static Season fromJson(dynamic json) {
    Season season = Season(
      id: json['id'],
      title: json['title'],
      seasonId: json['seasonId'],
      seasonCode: json['seasonCode'],
      seasonStatus: json['seasonStatus'].round(),
      seasonNote: json['seasonNote'],
      stats: SeasonStat.fromJson(json['stats']),
      defaultPosition: json['defaultPosition'].round() ?? 0,
      seasonInfo: TeamInfo.fromJson(json['seasonInfo']),
      showNicknames: json['showNicknames'] ?? false,
    );
    return season;
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
      "stats": stats.map((e) => e.toJson()).toList(),
      "seasonInfo": seasonInfo.toJson(),
      "defaultPosition": defaultPosition,
      "showNicknames": showNicknames,
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

  // values to compare
  @override
  List<Object> get props => [title, seasonId];
}

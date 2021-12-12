import 'package:equatable/equatable.dart';
import 'package:pnflutter/data/root.dart';
import 'package:pnflutter/data/season/season_stat.dart';

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
  late List<CustomUserField> customUserFields;
  late String website;

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
        .forEach((v) => customUserFields.add(CustomUserField.fromJson(v)));
    website = json['website'] ?? "";
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

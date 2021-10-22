import 'package:pnflutter/data/root.dart';

class SeasonUserSeasonFields {
  String? seasonUserNote;
  int? seasonUserType;
  int? seasonUserStatus;
  // new fields
  String? email;
  late bool isManager;
  late bool isPlaying;
  Jersey? jersey;
  List<SUStats>? stats;
  int? sPosition;
  String? jerseySize;
  String? jerseyNumber;

  SeasonUserSeasonFields({
    this.seasonUserNote,
    this.seasonUserType,
    this.seasonUserStatus,
    this.email,
    required this.isManager,
    required this.isPlaying,
    this.jersey,
    this.stats,
    this.sPosition,
    this.jerseySize,
    this.jerseyNumber,
  });

  SeasonUserSeasonFields.empty() {
    seasonUserNote = "";
    seasonUserNote = "";
    seasonUserStatus = 1;
    email = "";
    isManager = false;
    isPlaying = true;
    jersey = Jersey();
    stats = [];
    sPosition = 0;
    jerseySize = "";
    jerseyNumber = "";
  }

  SeasonUserSeasonFields.of(SeasonUserSeasonFields user) {
    seasonUserNote = user.seasonUserNote;
    seasonUserType = user.seasonUserType;
    seasonUserStatus = user.seasonUserStatus;
    email = user.email;
    isManager = user.isManager;
    isPlaying = user.isPlaying;
    jersey = user.jersey;
    stats = user.stats;
    sPosition = user.sPosition;
    jerseySize = user.jerseySize;
    jerseyNumber = user.jerseyNumber;
  }

  SeasonUserSeasonFields.fromJson(Map<String, dynamic> json) {
    seasonUserNote = json['seasonUserNote'];
    seasonUserType = json['seasonUserType']?.round();
    seasonUserStatus = json['seasonUserStatus']?.round();
    email = json['email'];
    isManager = json['isManager'] ?? false;
    isPlaying = json['isPlaying'] ?? true;
    jersey = Jersey.fromJson(json['jersey']);
    stats = SUStats.fromJson(json['stats']);
    sPosition = json['sPosition']?.round() ?? 0;
    jerseySize = json['jerseySize'];
    jerseyNumber = json['jerseyNumber'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['seasonUserNote'] = seasonUserNote;
    data['seasonUserType'] = seasonUserType;
    data['seasonUserStatus'] = seasonUserStatus;
    data['email'] = email;
    data['isManager'] = isManager;
    data['isPlaying'] = isPlaying;
    data['jersey'] = jersey?.toJson();
    data['stats'] = stats?.map((v) => v.toJson()).toList();
    data['sPosition'] = sPosition;
    data['jerseySize'] = jerseySize;
    data['jerseyNumber'] = jerseyNumber;
    return data;
  }
}

class Jersey {
  String? size;
  int? number;

  Jersey({this.size, this.number});

  Jersey.fromJson(Map<String, dynamic> json) {
    size = json['size'];
    // number = json['number']?.round();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['size'] = size;
    data['number'] = number;
    return data;
  }
}

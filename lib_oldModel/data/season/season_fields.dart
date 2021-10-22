import 'package:pnflutter/data/root.dart';

class SeasonUserSeasonFields {
  String? nickName;
  String? seasonUserNote;
  int? userPosition;
  String? jerseySize;
  int? seasonUserType;
  int? userStatus;
  String? jerseyNumber;
  // new fields
  String? email;
  bool? isManager;
  bool? isPlaying;
  Jersey? jersey;
  List<SUStats>? stats;

  SeasonUserSeasonFields({
    this.nickName,
    this.seasonUserNote,
    this.userPosition,
    this.jerseySize,
    this.seasonUserType,
    this.userStatus,
    this.jerseyNumber,
    this.email,
    this.isManager,
    this.isPlaying,
    this.jersey,
    this.stats,
  });

  SeasonUserSeasonFields.empty() {
    nickName = "";
    seasonUserNote = "";
    userPosition = 0;
    jerseySize = "";
    seasonUserNote = "";
    userStatus = 1;
    jerseyNumber = "";
    email = "";
    isManager = false;
    isPlaying = true;
    jersey = Jersey();
    stats = [];
  }

  SeasonUserSeasonFields.of(SeasonUserSeasonFields user) {
    nickName = user.nickName;
    seasonUserNote = user.seasonUserNote;
    userPosition = user.userPosition;
    jerseySize = user.jerseySize;
    seasonUserType = user.seasonUserType;
    userStatus = user.userStatus;
    jerseyNumber = user.jerseyNumber;
    email = user.email;
    isManager = user.isManager;
    isPlaying = user.isPlaying;
    jersey = user.jersey;
    stats = user.stats;
  }

  SeasonUserSeasonFields.fromJson(Map<String, dynamic> json) {
    nickName = json['nickName'];
    seasonUserNote = json['seasonUserNote'];
    userPosition = json['userPosition'];
    jerseySize = json['jerseySize'];
    seasonUserType = json['seasonUserType']?.round();
    userStatus = json['userStatus']?.round();
    jerseyNumber = json['jerseyNumber'];
    email = json['email'];
    isManager = json['isManager'];
    isPlaying = json['isPlaying'];
    jersey = Jersey.fromJson(json['jersey']);
    stats = SUStats.fromJson(json['stats']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['nickName'] = nickName;
    data['seasonUserNote'] = seasonUserNote;
    data['userPosition'] = userPosition;
    data['jerseySize'] = jerseySize;
    data['seasonUserType'] = seasonUserType;
    data['userStatus'] = userStatus;
    data['jerseyNumber'] = jerseyNumber;
    data['email'] = email;
    data['isManager'] = isManager;
    data['isPlaying'] = isPlaying;
    data['jersey'] = jersey?.toJson();
    data['stats'] = stats?.map((v) => v.toJson()).toList();
    return data;
  }
}

class Jersey {
  String? size;
  int? number;

  Jersey({this.size, this.number});

  Jersey.fromJson(Map<String, dynamic> json) {
    size = json['size'];
    number = json['number']?.round();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['size'] = size;
    data['number'] = number;
    return data;
  }
}

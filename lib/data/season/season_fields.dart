import 'package:pnflutter/data/root.dart';

class SeasonUserSeasonFields {
  String? seasonUserNote;
  int? seasonUserType;
  int? seasonUserStatus;
  // new fields
  late String email;
  late bool isManager;
  late bool isPlaying;
  late List<SUStats> stats;
  late bool isSub;
  late String nickname;
  late List<CustomField> customFields;
  late String pos;

  SeasonUserSeasonFields({
    this.seasonUserNote,
    this.seasonUserType,
    this.seasonUserStatus,
    required this.email,
    required this.isManager,
    required this.isPlaying,
    required this.stats,
    required this.isSub,
    required this.nickname,
    required this.customFields,
    required this.pos,
  });

  SeasonUserSeasonFields.empty() {
    seasonUserNote = "";
    seasonUserNote = "";
    seasonUserStatus = 1;
    email = "";
    isManager = false;
    isPlaying = true;
    stats = [];
    isSub = false;
    nickname = "";
    customFields = [];
    pos = "";
  }

  SeasonUserSeasonFields.of(SeasonUserSeasonFields user) {
    seasonUserNote = user.seasonUserNote;
    seasonUserType = user.seasonUserType;
    seasonUserStatus = user.seasonUserStatus;
    email = user.email;
    isManager = user.isManager;
    isPlaying = user.isPlaying;
    stats = user.stats;
    isSub = user.isSub;
    nickname = user.nickname;
    customFields = List.of(user.customFields);
    pos = user.pos;
  }

  SeasonUserSeasonFields.fromJson(Map<String, dynamic> json) {
    seasonUserNote = json['seasonUserNote'];
    seasonUserType = json['seasonUserType']?.round();
    seasonUserStatus = json['seasonUserStatus']?.round();
    email = json['email'];
    isManager = json['isManager'] ?? false;
    isPlaying = json['isPlaying'] ?? true;
    stats = SUStats.fromJson(json['stats']);
    isSub = json['isSub'] ?? false;
    nickname = json['nickname'] ?? "";
    customFields = [];
    for (var i in json['customFields']) {
      customFields.add(CustomField.fromJson(i));
    }
    pos = json['pos'] ?? "";
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['seasonUserNote'] = seasonUserNote;
    data['seasonUserType'] = seasonUserType;
    data['seasonUserStatus'] = seasonUserStatus;
    data['email'] = email;
    data['isManager'] = isManager;
    data['isPlaying'] = isPlaying;
    data['stats'] = stats.map((v) => v.toJson()).toList();
    data['isSub'] = isSub;
    data['nickname'] = nickname;
    data['customFields'] = customFields.map((e) => e.toJson());
    data['pos'] = pos;
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

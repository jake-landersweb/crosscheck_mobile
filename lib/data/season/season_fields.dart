import 'package:crosscheck_sports/data/root.dart';

class SeasonUserSeasonFields {
  String? seasonUserNote;
  int? seasonUserType;
  late int seasonUserStatus;
  // new fields
  late String email;
  late bool isManager;
  late bool isPlaying;
  late bool isSub;
  late List<CustomField> customFields;
  late String pos;
  late bool allowChatNotifications;
  late String jerseySize;
  late String jerseyNumber;

  SeasonUserSeasonFields({
    this.seasonUserNote,
    this.seasonUserType,
    required this.seasonUserStatus,
    required this.email,
    required this.isManager,
    required this.isPlaying,
    required this.isSub,
    required this.customFields,
    required this.pos,
    required this.allowChatNotifications,
    required this.jerseySize,
    required this.jerseyNumber,
  });

  SeasonUserSeasonFields.empty() {
    seasonUserNote = "";
    seasonUserNote = "";
    seasonUserStatus = 1;
    email = "";
    isManager = false;
    isPlaying = true;
    isSub = false;
    customFields = [];
    pos = "";
    allowChatNotifications = true;
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
    isSub = user.isSub;
    customFields = [for (var i in user.customFields) i.clone()];
    pos = user.pos;
    allowChatNotifications = user.allowChatNotifications;
    jerseySize = user.jerseySize;
    jerseyNumber = user.jerseyNumber;
  }

  SeasonUserSeasonFields.fromJson(Map<String, dynamic> json) {
    seasonUserNote = json['seasonUserNote'];
    seasonUserType = json['seasonUserType']?.round();
    seasonUserStatus = json['seasonUserStatus']?.round() ?? 1;
    email = json['email'];
    isManager = json['isManager'] ?? false;
    isPlaying = json['isPlaying'] ?? true;
    isSub = json['isSub'] ?? false;
    customFields = [];
    if (json['customFields'] != null) {
      for (var i in json['customFields']) {
        customFields.add(CustomField.fromJson(i));
      }
    }
    pos = json['pos'] ?? "";
    allowChatNotifications = json['allowChatNotifications'] ?? false;
    jerseySize = json['jerseySize'] ?? "";
    jerseyNumber = json['jerseyNumber'] ?? "";
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['seasonUserNote'] = seasonUserNote;
    data['seasonUserType'] = seasonUserType;
    data['seasonUserStatus'] = seasonUserStatus;
    data['email'] = email;
    data['isManager'] = isManager;
    data['isPlaying'] = isPlaying;
    data['isSub'] = isSub;
    data['customFields'] = customFields.map((e) => e.toJson()).toList();
    data['pos'] = pos;
    data['allowChatNotifications'] = allowChatNotifications;
    data["jerseySize"] = jerseySize;
    data["jerseyNumber"] = jerseyNumber;
    return data;
  }

  String getStatus() {
    switch (seasonUserStatus) {
      case 1:
        return "Active";
      case -1:
        return "Inactive";
      default:
        return "Unknown";
    }
  }
}

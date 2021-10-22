import 'package:pnflutter/data/root.dart';

class SeasonUserEventFields {
  String? teamId;
  String? message;
  late List<StatusReply> statusReplies;
  // new fields
  String? email;
  late int eStatus;
  late bool isPlaying;
  List<SUStats>? stats;
  int? ePosition;

  SeasonUserEventFields(
      {this.teamId,
      this.message,
      required this.statusReplies,
      this.email,
      required this.eStatus,
      required this.isPlaying,
      this.stats,
      this.ePosition});

  SeasonUserEventFields.empty() {
    teamId = "";
    message = "";
    statusReplies = [];
    email = "empty";
    eStatus = 0;
    isPlaying = true;
    stats = [];
    ePosition = 0;
  }

  SeasonUserEventFields.of(SeasonUserEventFields user) {
    teamId = user.teamId;
    message = user.message;
    statusReplies = user.statusReplies;
    email = user.email;
    eStatus = user.eStatus;
    isPlaying = user.isPlaying;
    stats = user.stats;
    ePosition = user.ePosition;
  }

  SeasonUserEventFields.fromJson(Map<String, dynamic> json) {
    teamId = json['teamId'];
    message = json['message'];
    statusReplies = [];
    if (json['statusReplies'] != null) {
      json['statusReplies'].forEach((v) {
        statusReplies.add(StatusReply.fromJson(v));
      });
    } else {
      statusReplies = [];
    }
    email = json['email'];
    eStatus = json['eStatus']?.round() ?? 0;
    isPlaying = json['isPlaying'] ?? true;
    stats = SUStats.fromJson(json['stats']);
    ePosition = json['ePosition']?.round() ?? 0;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['teamId'] = teamId;
    data['message'] = message;
    data['statusReplies'] = statusReplies.map((v) => v.toJson()).toList();
    data['email'] = email;
    data['eStatus'] = eStatus.round();
    data['isPlaying'] = isPlaying;
    data['stats'] = stats?.map((v) => v.toJson()).toList();
    data['ePosition'] = ePosition;
    return data;
  }
}

class StatusReply {
  late String date;
  late String message;
  late String name;

  StatusReply({
    required this.date,
    required this.message,
    required this.name,
  });

  StatusReply.empty() {
    date = "";
    message = "";
    name = "";
  }

  StatusReply.fromJson(Map<String, dynamic> json) {
    date = json['date'];
    message = json['message'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['date'] = date;
    data['message'] = message;
    data['name'] = name;
    return data;
  }
}

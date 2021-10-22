import 'dart:html';

import 'package:pnflutter/data/root.dart';

class SeasonUserEventFields {
  String? teamId;
  String? message;
  late int eStatus;
  late List<StatusReply> statusReplies;
  // new fields
  String? email;
  int? checkInStatus;
  bool? isPlaying;
  List<SUStats>? stats;

  SeasonUserEventFields({
    this.teamId,
    this.message,
    required this.eStatus,
    required this.statusReplies,
    this.email,
    this.checkInStatus,
    this.isPlaying,
    this.stats,
  });

  SeasonUserEventFields.empty() {
    teamId = "";
    message = "";
    eStatus = 1;
    statusReplies = [];
    email = "";
    checkInStatus = 0;
    isPlaying = true;
    stats = [];
  }

  SeasonUserEventFields.of(SeasonUserEventFields user) {
    teamId = user.teamId;
    message = user.message;
    eStatus = user.eStatus;
    statusReplies = user.statusReplies;
    email = user.email;
    checkInStatus = user.checkInStatus;
    isPlaying = user.isPlaying;
    stats = user.stats;
  }

  SeasonUserEventFields.fromJson(Map<String, dynamic> json) {
    teamId = json['teamId'];
    message = json['message'];
    eStatus = json['eStatus']?.round();
    statusReplies = [];
    if (json['statusReplies'] != null) {
      json['statusReplies'].forEach((v) {
        statusReplies.add(StatusReply.fromJson(v));
      });
    } else {
      statusReplies = [];
    }
    email = json['email'];
    checkInStatus = json['checkInStatus'];
    isPlaying = json['isPlaying'];
    stats = SUStats.fromJson(json['stats']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['teamId'] = teamId;
    data['message'] = message;
    data['eStatus'] = eStatus;
    data['statusReplies'] = statusReplies.map((v) => v.toJson()).toList();
    data['email'] = email;
    data['checkInStatus'] = checkInStatus?.round();
    data['isPlaying'] = isPlaying;
    data['stats'] = stats?.map((v) => v.toJson()).toList();
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

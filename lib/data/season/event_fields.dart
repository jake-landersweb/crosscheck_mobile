import 'package:crosscheck_sports/data/root.dart';
import 'package:crosscheck_sports/extras/global_funcs.dart';

class SeasonUserEventFields {
  String? teamId;
  String? message;
  late List<StatusReply> statusReplies;
  // new fields
  String? email;
  late int eStatus;
  late bool isPlaying;
  late bool isParticipant;
  int? ePosition;
  late List<CustomField> customFields;

  SeasonUserEventFields({
    this.teamId,
    this.message,
    required this.statusReplies,
    this.email,
    required this.eStatus,
    required this.isPlaying,
    required this.isParticipant,
    this.ePosition,
    required this.customFields,
  });

  SeasonUserEventFields.empty() {
    teamId = "";
    message = "";
    statusReplies = [];
    email = "empty";
    eStatus = 0;
    isPlaying = true;
    isParticipant = true;
    ePosition = 0;
    customFields = [];
  }

  SeasonUserEventFields.of(SeasonUserEventFields user) {
    teamId = user.teamId;
    message = user.message;
    statusReplies = user.statusReplies;
    email = user.email;
    eStatus = user.eStatus;
    isPlaying = user.isPlaying;
    isParticipant = user.isParticipant;
    ePosition = user.ePosition;
    customFields = [for (var i in user.customFields) i.clone()];
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
    isParticipant = json['isParticipant'] ?? json['isPlaying'] ?? true;
    ePosition = json['ePosition']?.round() ?? 0;
    customFields = [];
    if (json['customFields'] != null) {
      for (var i in json['customFields']) {
        customFields.add(CustomField.fromJson(i));
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['teamId'] = teamId;
    data['message'] = message;
    data['statusReplies'] = statusReplies.map((v) => v.toJson()).toList();
    data['email'] = email;
    data['eStatus'] = eStatus.round();
    data['isPlaying'] = isPlaying;
    data['isParticipant'] = isParticipant;
    data['ePosition'] = ePosition;
    data['customFields'] = customFields.map((e) => e.toJson()).toList();
    return data;
  }
}

class StatusReply {
  late String date;
  late String message;
  late String name;
  late String email;

  StatusReply({
    required this.date,
    required this.message,
    required this.name,
    required this.email,
  });

  StatusReply.empty() {
    date = "";
    message = "";
    name = "";
    email = "";
  }

  StatusReply.fromJson(Map<String, dynamic> json) {
    date = json['date'];
    message = json['message'];
    name = json['name'];
    email = json['email'] ?? json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['date'] = date;
    data['message'] = message;
    data['name'] = name;
    data['email'] = email;
    return data;
  }

  String getFormattedDate() {
    DateTime d = stringToDate(date);
    DateTime now = DateTime.now();

    // get seconds between the two dates
    int secondsOffset =
        (now.millisecondsSinceEpoch - d.millisecondsSinceEpoch) ~/ 1000;

    if (secondsOffset < 60) {
      return "Just now";
    }
    int minOffset = secondsOffset ~/ 60;
    if (minOffset < 60) {
      return "$minOffset min ago";
    }
    int hourOffset = minOffset ~/ 60;
    if (hourOffset < 24) {
      return "$hourOffset hr ago";
    }
    int dayOffset = hourOffset ~/ 24;
    if (dayOffset < 365) {
      return "$dayOffset days ago";
    }
    return "> 1 year ago";
  }
}

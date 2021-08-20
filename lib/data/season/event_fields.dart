class SeasonUserEventFields {
  String? teamId;
  String? message;
  late int eStatus;
  late List<StatusReply> statusReplies;

  SeasonUserEventFields({
    this.teamId,
    this.message,
    required this.eStatus,
    required this.statusReplies,
  });

  SeasonUserEventFields.empty() {
    teamId = "";
    message = "";
    eStatus = 1;
    statusReplies = [];
  }

  SeasonUserEventFields.of(SeasonUserEventFields user) {
    teamId = user.teamId;
    message = user.message;
    eStatus = user.eStatus;
    statusReplies = user.statusReplies;
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
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['teamId'] = teamId;
    data['message'] = message;
    data['eStatus'] = eStatus;
    data['statusReplies'] = statusReplies.map((v) => v.toJson()).toList();
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

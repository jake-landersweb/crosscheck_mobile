class SeasonUserSeasonFields {
  String? nickName;
  String? seasonUserNote;
  String? userPosition;
  String? jerseySize;
  int? seasonUserType;
  int? userStatus;
  String? jerseyNumber;

  SeasonUserSeasonFields({
    this.nickName,
    this.seasonUserNote,
    this.userPosition,
    this.jerseySize,
    this.seasonUserType,
    this.userStatus,
    this.jerseyNumber,
  });

  SeasonUserSeasonFields.empty() {
    nickName = "";
    seasonUserNote = "";
    userPosition = "";
    jerseySize = "";
    seasonUserNote = "";
    userStatus = 1;
    jerseyNumber = "";
  }

  SeasonUserSeasonFields.of(SeasonUserSeasonFields user) {
    nickName = user.nickName;
    seasonUserNote = user.seasonUserNote;
    userPosition = user.userPosition;
    jerseySize = user.jerseySize;
    seasonUserType = user.seasonUserType;
    userStatus = user.userStatus;
    jerseyNumber = user.jerseyNumber;
  }

  SeasonUserSeasonFields.fromJson(Map<String, dynamic> json) {
    nickName = json['nickName'];
    seasonUserNote = json['seasonUserNote'];
    userPosition = json['userPosition'];
    jerseySize = json['jerseySize'];
    seasonUserType = json['seasonUserType']?.round();
    userStatus = json['userStatus']?.round();
    jerseyNumber = json['jerseyNumber'];
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
    return data;
  }
}

class MobileNotification {
  late bool allow;
  String? token;
  String? deviceType;
  String? deviceName;
  String? deviceVersion;
  String? teamId;
  String? updated;
  String? created;

  MobileNotification({
    required this.allow,
    this.token,
    this.deviceType,
    this.deviceName,
    this.deviceVersion,
    this.teamId,
    this.updated,
    this.created,
  });

  MobileNotification clone() => MobileNotification(
        allow: allow,
        token: token,
        deviceType: deviceType,
        deviceName: deviceName,
        deviceVersion: deviceVersion,
        teamId: teamId,
        updated: updated,
        created: created,
      );

  MobileNotification.fromJson(dynamic json) {
    allow = json['allow'];
    token = json['token'] ?? "";
    deviceType = json['deviceType'];
    deviceName = json['deviceName'];
    deviceVersion = json['deviceVersion'];
    teamId = json['teamId'];
    updated = json['updated'];
    created = json['created'];
  }

  Map<String, dynamic> toJson() {
    return {
      "token": token,
      "allow": allow,
      "deviceType": deviceType,
      "deviceName": deviceName,
      "deviceVersion": deviceVersion,
      "teamId": teamId,
      "created": created,
      "updated": updated,
    };
  }
}

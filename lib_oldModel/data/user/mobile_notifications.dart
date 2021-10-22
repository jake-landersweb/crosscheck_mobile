class MobileNotifications {
  late String deviceId;
  late String allow;

  MobileNotifications({
    required this.deviceId,
    required this.allow,
  });

  MobileNotifications.fromJson(Map<String, dynamic> json) {
    deviceId = json['deviceId'];
    allow = json['allow'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['deviceId'] = deviceId;
    data['allow'] = allow;
    return data;
  }
}

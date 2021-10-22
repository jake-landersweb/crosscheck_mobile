class MobileNotifications {
  late String deviceId;
  late bool allow;

  MobileNotifications({
    required this.deviceId,
    required this.allow,
  });

  static List<MobileNotifications> fromJson(dynamic json) {
    List<MobileNotifications> list = [];
    if (json != null) {
      for (var i in json) {
        list.add(
            MobileNotifications(deviceId: i['deviceId'], allow: i['allow']));
      }
    }
    return list;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['deviceId'] = deviceId;
    data['allow'] = allow;
    return data;
  }
}

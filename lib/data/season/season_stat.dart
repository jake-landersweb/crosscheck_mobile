class SeasonStat {
  late String title;
  late int defaultValue;
  late bool isActive;

  SeasonStat(
      {required this.title,
      required this.defaultValue,
      required this.isActive});

  static List<SeasonStat> fromJson(dynamic json) {
    List<SeasonStat> list = [];
    if (json != null) {
      for (var i in json) {
        list.add(SeasonStat(
            title: i['title'],
            defaultValue: i['defaultValue'].round(),
            isActive: i['isActive']));
      }
    }
    return list;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['title'] = title;
    data['defaultValue'] = defaultValue;
    data['isActive'] = isActive;
    return data;
  }
}

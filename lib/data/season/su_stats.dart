class SUStats {
  late String title;
  late int value;

  SUStats({required this.title, required this.value});

  SUStats clone() => SUStats(title: title, value: value);

  static List<SUStats> fromJson(dynamic json) {
    List<SUStats> list = [];
    if (json != null) {
      for (var i in json) {
        list.add(
          SUStats(
            title: i['title'],
            value: i['value']?.round() ?? 0,
          ),
        );
      }
    }
    return list;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['title'] = title;
    data['value'] = value;
    return data;
  }
}

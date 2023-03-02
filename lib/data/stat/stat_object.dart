class StatObject {
  late String title;
  late int value;

  StatObject({required this.title, required this.value});

  StatObject clone() => StatObject(title: title, value: value);

  StatObject.fromJson(dynamic json) {
    title = json['title'];
    value = json['value'].round();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['title'] = title;
    data['value'] = value;
    return data;
  }
}

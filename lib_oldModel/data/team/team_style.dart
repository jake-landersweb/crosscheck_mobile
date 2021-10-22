class TeamStyle {
  String? color;
  bool? isLight;

  TeamStyle({this.color, this.isLight});

  TeamStyle.fromJson(Map<String, dynamic> json) {
    color = json['color'];
    isLight = json['isLight'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['color'] = color;
    data['isLight'] = isLight;
    return data;
  }
}

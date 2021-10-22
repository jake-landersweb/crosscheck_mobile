class TeamStyle {
  String? color;
  bool? isLight;
  String? image;

  TeamStyle({this.color, this.isLight});

  TeamStyle.fromJson(Map<String, dynamic> json) {
    color = json['color'];
    isLight = json['isLight'];
    image = json['image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['color'] = color;
    data['isLight'] = isLight;
    data['image'] = image;
    return data;
  }
}

class TeamPositions {
  late int defaultPosition;
  late List<int> available;

  TeamPositions({
    required this.defaultPosition,
    required this.available,
  });

  TeamPositions.fromJson(Map<String, dynamic> json) {
    defaultPosition = (json['defaultPosition'] ?? 0).round();
    List<int> temp = [];
    for (var i in json['available']) {
      temp.add(i.round());
    }
    available = temp;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['defaultPosition'] = defaultPosition;
    data['available'] = available;
    return data;
  }
}

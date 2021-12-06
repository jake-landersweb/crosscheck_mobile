class TeamPositions {
  late String defaultPosition;
  late List<String> available;
  late bool isActive;

  TeamPositions({
    required this.isActive,
    required this.defaultPosition,
    required this.available,
  });

  TeamPositions.fromJson(Map<String, dynamic> json) {
    isActive = json['isActive'] ?? false;
    defaultPosition = json['defaultPosition'] ?? "";
    List<String> temp = [];
    if (json.containsKey("available")) {
      for (var i in json['available']) {
        temp.add(i);
      }
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

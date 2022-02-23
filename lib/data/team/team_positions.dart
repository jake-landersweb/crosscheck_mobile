class TeamPositions {
  late String defaultPosition;
  late List<String> available;
  late bool isActive;

  TeamPositions({
    required this.isActive,
    required this.defaultPosition,
    required this.available,
  });

  TeamPositions.empty() {
    isActive = true;
    defaultPosition = "";
    available = [];
  }

  TeamPositions.fromJson(Map<String, dynamic> json) {
    isActive = json['isActive'] ?? true;
    defaultPosition = json['defaultPosition'] ?? "";
    List<String> temp = [];
    if (json['available'] != null) {
      for (var i in json['available']) {
        temp.add(i);
      }
    }
    available = temp;
  }

  TeamPositions clone() => TeamPositions(
      isActive: isActive,
      defaultPosition: defaultPosition,
      available: [for (var i in available) i]);

  TeamPositions.of(TeamPositions positions) {
    defaultPosition = positions.defaultPosition;
    available = List.of(positions.available);
    isActive = positions.isActive;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['defaultPosition'] = defaultPosition;
    data['available'] = available;
    data['isActive'] = isActive;
    return data;
  }

  void removePosition(String value) {
    available.removeWhere((element) => element == value);
  }

  void setDefault(String value) {
    defaultPosition = value;
  }

  void setIsActive(bool isActive) {
    this.isActive = isActive;
  }
}

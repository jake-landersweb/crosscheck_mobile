class TeamPositions {
  late String defaultPosition;
  late String mvp;
  late List<String> available;
  late bool isActive;

  TeamPositions({
    required this.isActive,
    required this.defaultPosition,
    required this.available,
    required this.mvp,
  });

  TeamPositions.empty() {
    isActive = true;
    defaultPosition = "";
    available = [];
    mvp = "";
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
    mvp = json['mvp'] ?? "";
  }

  TeamPositions clone() => TeamPositions(
        isActive: isActive,
        defaultPosition: defaultPosition,
        available: [for (var i in available) i],
        mvp: mvp,
      );

  TeamPositions.of(TeamPositions positions) {
    defaultPosition = positions.defaultPosition;
    available = List.of(positions.available);
    isActive = positions.isActive;
    mvp = positions.mvp;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['defaultPosition'] = defaultPosition.toLowerCase();
    data['available'] = available.map((e) => e.toLowerCase()).toList();
    data['isActive'] = isActive;
    data['mvp'] = mvp.toLowerCase();
    return data;
  }

  void removePosition(String value) {
    available.removeWhere((element) => element == value);
  }

  void setDefault(String value) {
    defaultPosition = value;
  }

  void setMVP(String value) {
    mvp = value;
  }

  void setIsActive(bool isActive) {
    this.isActive = isActive;
  }
}

import 'root.dart';

class TeamStat {
  late bool isActive;
  late List<StatItem> stats;

  TeamStat({
    required this.isActive,
    required this.stats,
  });

  TeamStat.of(TeamStat s) {
    isActive = s.isActive;
    stats = s.stats;
  }

  TeamStat.empty() {
    isActive = true;
    stats = [];
  }

  TeamStat.fromJson(dynamic json) {
    isActive = json['isActive'] ?? true;
    stats = [];
    for (var i in json['stats']) {
      stats.add(StatItem.fromJson(i));
    }
  }

  Map<String, dynamic> toJson() {
    return {
      "isActive": isActive,
      "stats": stats.map((e) => e.toJson()).toList(),
    };
  }
}

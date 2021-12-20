import 'root.dart';
import 'package:equatable/equatable.dart';

class TeamStat extends Equatable {
  late bool isActive;
  late List<StatItem> stats;

  TeamStat({
    required this.isActive,
    required this.stats,
  });

  TeamStat.of(TeamStat s) {
    isActive = s.isActive;
    stats = List.of(s.stats);
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

  @override
  List<Object?> get props => [isActive, stats];
}

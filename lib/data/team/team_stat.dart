import '../dynamic_fields/root.dart';
import 'package:equatable/equatable.dart';

class TeamStat extends Equatable {
  late bool isActive;
  late List<StatItem> stats;

  TeamStat({
    required this.isActive,
    required this.stats,
  });

  TeamStat clone() => TeamStat(
      isActive: isActive, stats: [for (var i in stats) StatItem.of(i)]);

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

  void addStat(String title) {
    stats.add(StatItem(title: title, isActive: true));
  }

  @override
  List<Object?> get props => [isActive, stats];
}

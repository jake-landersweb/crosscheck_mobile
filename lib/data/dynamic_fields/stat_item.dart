import 'package:equatable/equatable.dart';

class StatItem extends Equatable {
  late String title;
  late bool isActive;

  StatItem({
    required this.title,
    required this.isActive,
  });

  StatItem.of(StatItem stat) {
    title = stat.title;
    isActive = stat.isActive;
  }

  StatItem.empty() {
    title = "";
    isActive = true;
  }

  StatItem.fromJson(dynamic json) {
    title = json['title'] ?? "";
    isActive = json['isActive'];
  }

  Map<String, dynamic> toJson() {
    return {
      "title": title,
      "isActive": isActive,
    };
  }

  String getTitle() {
    return title;
  }

  void setTitle(String title) {
    this.title = title;
  }

  bool isEqual(StatItem item) {
    if (title == item.title && isActive == item.isActive) {
      return true;
    } else {
      return false;
    }
  }

  @override
  List<Object?> get props => [title, isActive];
}

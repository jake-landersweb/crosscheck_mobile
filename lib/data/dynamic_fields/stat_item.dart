import 'package:equatable/equatable.dart';

class StatItem extends Equatable {
  late String title;
  late int defaultValue;
  late bool isActive;

  StatItem({
    required this.title,
    required this.defaultValue,
    required this.isActive,
  });

  StatItem.of(StatItem stat) {
    title = stat.title;
    defaultValue = stat.defaultValue;
    isActive = stat.isActive;
  }

  StatItem.empty() {
    title = "";
    defaultValue = 0;
    isActive = true;
  }

  StatItem.fromJson(dynamic json) {
    title = json['title'] ?? "";
    defaultValue = json['defaultValue'].round() ?? 0;
    isActive = json['isActive'];
  }

  Map<String, dynamic> toJson() {
    return {
      "title": title,
      "defaultValue": defaultValue,
      "isActive": isActive,
    };
  }

  String getTitle() {
    return title;
  }

  String getValue() {
    return defaultValue.toString();
  }

  void setTitle(String title) {
    this.title = title;
  }

  void setValue(int value) {
    defaultValue = value;
  }

  bool isEqual(StatItem item) {
    if (title == item.title &&
        defaultValue == item.defaultValue &&
        isActive == item.isActive) {
      return true;
    } else {
      return false;
    }
  }

  @override
  List<Object?> get props => [title, isActive, defaultValue];
}

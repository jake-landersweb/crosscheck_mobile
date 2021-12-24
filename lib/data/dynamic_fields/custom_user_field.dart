import 'root.dart';
import 'package:equatable/equatable.dart';

class CustomUserField extends DynamicField with EquatableMixin {
  late String title;
  late String type;
  late String defaultValue;

  CustomUserField({
    required this.title,
    required this.type,
    required this.defaultValue,
  });

  CustomUserField.of(CustomUserField c) {
    title = c.title;
    type = c.type;
    defaultValue = c.defaultValue;
  }

  CustomUserField.fromJson(dynamic json) {
    title = json['title'] ?? "";
    type = json['type'] ?? "S";
    defaultValue = json['defaultValue'] ?? "";
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      "type": type,
      "defaultValue": defaultValue,
    };
  }

  @override
  String getTitle() {
    return title;
  }

  @override
  String getType() {
    return type;
  }

  @override
  String getValue() {
    return defaultValue;
  }

  @override
  void setTitle(String title) {
    this.title = title;
  }

  @override
  void setType(String type) {
    this.type = type;
  }

  @override
  void setValue(dynamic value) {
    if (value is bool) {
      defaultValue = value ? "true" : "false";
    } else {
      defaultValue = value.toString();
    }
  }

  bool isEqual(CustomUserField cuf) {
    if (title == cuf.title &&
        type == cuf.type &&
        defaultValue == cuf.defaultValue) {
      return true;
    } else {
      return false;
    }
  }

  @override
  List<Object?> get props => [title, type, defaultValue];
}

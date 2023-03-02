import 'package:uuid/uuid.dart';

import 'package:equatable/equatable.dart';

class CustomField with EquatableMixin {
  late String id;
  late String title;
  late String type;
  late String value;

  CustomField({
    required this.title,
    required this.type,
    required this.value,
  }) {
    id = const Uuid().v4();
  }

  CustomField clone() {
    var cf = CustomField(title: title, type: type, value: value);
    cf.id = id;
    return cf;
  }

  CustomField.fromJson(dynamic json) {
    id = const Uuid().v4();
    title = json['title'] ?? "";
    type = json['type'] ?? "S";
    value = json['value'] ?? "";
  }

  Map<String, dynamic> toJson() {
    return {
      "title": title,
      "type": type,
      "value": value,
    };
  }

  String getTitle() {
    return title;
  }

  String getType() {
    return type;
  }

  String getValue() {
    return value;
  }

  void setTitle(String title) {
    this.title = title;
  }

  void setType(String type) {
    this.type = type;
  }

  void setValue(dynamic value) {
    if (value is bool) {
      this.value = value ? "true" : "false";
    } else {
      this.value = value.toString();
    }
  }

  bool isEqual(CustomField cf) {
    if (title == cf.title && type == cf.type && value == cf.value) {
      return true;
    } else {
      return false;
    }
  }

  String typeTitle() {
    return getTypeTitle(type);
  }

  static String getTypeTitle(String type) {
    switch (type) {
      case "S":
        return "Word";
      case "I":
        return "Number";
      case "B":
        return "True/False";
      case "SS":
        return "Single Select";
      default:
        return "Unknown";
    }
  }

  @override
  List<Object?> get props => [title, type, value];
}

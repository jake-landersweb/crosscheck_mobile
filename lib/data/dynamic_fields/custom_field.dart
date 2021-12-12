import 'root.dart';

class CustomField extends DynamicField {
  late String title;
  late String type;
  late String value;

  CustomField({
    required this.title,
    required this.type,
    required this.value,
  });

  CustomField.of(CustomField f) {
    title = f.title;
    type = f.type;
    value = f.value;
  }

  CustomField.fromJson(dynamic json) {
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
    return value;
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
      this.value = value ? "true" : "false";
    } else {
      this.value = value.toString();
    }
  }
}

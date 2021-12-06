class CustomUserField {
  late String title;
  late String type;
  late String defaultValue;
  late List<String> defaultStringListValue;

  CustomUserField(
      {required this.title,
      required this.type,
      required this.defaultValue,
      required this.defaultStringListValue});

  CustomUserField.empty() {
    title = "";
    type = "S";
    defaultValue = "";
    defaultStringListValue = [];
  }

  CustomUserField.fromJson(Map<String, dynamic> json) {
    title = json['title'] ?? "";
    type = json['type'] ?? "S";
    defaultValue = json['defaultValue'] ?? "";
    defaultStringListValue = json['defaultStringListValue'] ?? [];
  }
}

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

  Map<String, dynamic> toJson() {
    return {
      "title": title,
      "type": type,
      "defaultValue": defaultValue,
    };
  }

  void setTitle(String title) {
    this.title = title;
  }

  void setType(String type) {
    this.type = type;
  }

  void setStringVal(String val) {
    defaultValue = val;
  }

  void setIntVal(int val) {
    defaultValue = val.toString();
  }

  void setBoolVal(bool val) {
    defaultValue = val ? "true" : "false";
  }
}

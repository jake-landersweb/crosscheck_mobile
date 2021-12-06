class CustomField {
  late String title;
  late String type;
  String? stringVal;
  bool? boolVal;
  int? intVal;
  List<String>? stringListVal;

  CustomField({
    required this.title,
    required this.type,
    this.stringVal,
    this.boolVal,
    this.intVal,
    this.stringListVal,
  });

  CustomField.empty() {
    title = "";
    type = "S";
  }

  CustomField.fromJson(Map<String, dynamic> json) {
    title = json['title'] ?? "";
    type = json['type'] ?? "S";
    switch (type) {
      case "S":
        stringVal = json['value'].toString().toLowerCase();
        break;
      case "I":
        intVal = int.parse(json['value']);
        break;
      case "B":
        boolVal =
            json['value'].toString().toLowerCase() == "true" ? true : false;
        break;
      default:
        stringListVal = json['value'];
    }
  }

  Map<String, dynamic> toJson() {
    // get the value
    String val = "";
    switch (type) {
      case "S":
        val = stringVal ?? "";
        break;
      case "I":
        val = (intVal ?? 0).toString();
        break;
      case "B":
        val = (boolVal ?? true) ? "true" : "false";
        break;
      default:
        val = "";
    }
    return {
      "title": title,
      "type": type,
      "value": val,
    };
  }

  String getValue() {
    switch (type) {
      case "S":
        return stringVal ?? "";
      case "I":
        return intVal.toString();
      case "B":
        return (boolVal ?? false) ? "True" : "False";
      default:
        String val = '';
        stringListVal?.forEach((element) {
          val = val + ", " + element;
        });
        return val;
    }
  }

  void setTitle(String title) {
    this.title = title;
  }

  void setType(String type) {
    this.type = type;
  }

  void setStringVal(String val) {
    stringVal = val;
  }

  void setIntVal(int val) {
    intVal = val;
  }

  void setBoolVal(bool val) {
    boolVal = val;
  }
}

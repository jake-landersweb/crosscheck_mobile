class EventLocation {
  String? name;
  String? address;

  EventLocation({
    this.name,
    this.address,
  });

  EventLocation.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    address = json['address'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['address'] = address;
    return data;
  }
}

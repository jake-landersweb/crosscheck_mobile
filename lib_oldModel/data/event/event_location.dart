class EventLocation {
  String? name;
  String? address1;
  String? address2;
  String? city;
  int? zip;
  String? state;

  EventLocation({
    this.name,
    this.address1,
    this.address2,
    this.city,
    this.zip,
    this.state,
  });

  EventLocation.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    address1 = json['address1'];
    address2 = json['address2'];
    city = json['city'];
    zip = json['zip']?.round();
    state = json['state'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['address1'] = address1;
    data['address2'] = address2;
    data['city'] = city;
    data['zip'] = zip;
    data['state'] = state;
    return data;
  }
}

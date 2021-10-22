class SeasonUserUserFields {
  String? lastName;
  String? phone;
  String? firstName;

  SeasonUserUserFields({
    this.lastName,
    this.phone,
    this.firstName,
  });

  SeasonUserUserFields.empty() {
    lastName = "";
    phone = "";
    firstName = "";
  }

  SeasonUserUserFields.of(SeasonUserUserFields user) {
    lastName = user.lastName;
    phone = user.phone;
    firstName = user.firstName;
  }

  SeasonUserUserFields.fromJson(Map<String, dynamic> json) {
    lastName = json['lastName'];
    phone = json['phone'];
    firstName = json['firstName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['lastName'] = lastName;
    data['phone'] = phone;
    data['firstName'] = firstName;
    return data;
  }
}

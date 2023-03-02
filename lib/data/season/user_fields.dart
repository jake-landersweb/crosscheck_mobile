class SeasonUserUserFields {
  String? lastName;
  String? phone;
  String? firstName;
  String? nickname;

  SeasonUserUserFields({
    this.lastName,
    this.phone,
    this.firstName,
    this.nickname,
  });

  SeasonUserUserFields.empty() {
    lastName = "";
    phone = "";
    firstName = "";
    nickname = "";
  }

  SeasonUserUserFields.of(SeasonUserUserFields user) {
    lastName = user.lastName;
    phone = user.phone;
    firstName = user.firstName;
    nickname = user.nickname;
  }

  SeasonUserUserFields.fromJson(Map<String, dynamic> json) {
    lastName = json['lastName'];
    phone = json['phone'];
    firstName = json['firstName'];
    nickname = json['nickname'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['lastName'] = lastName;
    data['phone'] = phone;
    data['firstName'] = firstName;
    data['nickname'] = nickname;
    return data;
  }
}

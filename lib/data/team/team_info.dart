class TeamInfo {
  String? website;
  String? email;

  TeamInfo({this.website, this.email});

  TeamInfo.fromJson(Map<String, dynamic> json) {
    website = json['website'];
    email = json['email'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['website'] = website;
    data['email'] = email;
    return data;
  }
}

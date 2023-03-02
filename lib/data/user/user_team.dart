import 'package:equatable/equatable.dart';

class UserTeam {
  late String title;
  late String teamId;

  UserTeam({
    required this.title,
    required this.teamId,
  }) : assert(title != teamId);

  // empty object
  UserTeam.empty() {
    title = "";
    teamId = "";
  }

  // copying object
  UserTeam.of(UserTeam userTeam) {
    title = userTeam.title;
    teamId = userTeam.teamId;
  }

  // converting from json
  static List<UserTeam> fromJson(dynamic json) {
    List<UserTeam> list = [];
    if (json != null) {
      for (var i in json) {
        list.add(
          UserTeam(
            title: i['title'],
            teamId: i['teamId'],
          ),
        );
      }
    }
    return list;
  }

  // converting to json
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'teamId': teamId,
    };
  }
}

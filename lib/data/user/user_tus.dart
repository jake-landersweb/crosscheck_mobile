import 'package:crosscheck_sports/data/root.dart';

class UserTUS {
  late User user;
  TeamUserSeasons? tus;
  Schedule? schedule;

  UserTUS({required this.user, this.tus, this.schedule});

  UserTUS.fromJson(dynamic json) {
    user = User.fromJson(json['user']);
    if (json['tus'] != null) {
      tus = TeamUserSeasons.fromJson(json['tus']);
    }
    if (json['schedule'] != null) {
      schedule = Schedule.fromjson(json['schedule']);
    }
  }
}

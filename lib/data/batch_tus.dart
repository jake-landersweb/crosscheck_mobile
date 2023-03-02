import 'package:crosscheck_sports/data/root.dart';

class BatchTUS {
  late User user;
  late Team team;
  late List<Season> seasons;
  late SeasonUserTeamFields teamUser;
  late SeasonUserSeasonFields seasonUser;

  BatchTUS.fromJson(dynamic json) {
    user = User.fromJson(json['users_3']);
    team = Team.fromJson(json['teams_3']);
    seasons = [Season.fromJson(json['seasons_2'])];
    teamUser = SeasonUserTeamFields.fromJson(json['teamUser']);
    seasonUser = SeasonUserSeasonFields.fromJson(json['seasonUser']);
  }
}

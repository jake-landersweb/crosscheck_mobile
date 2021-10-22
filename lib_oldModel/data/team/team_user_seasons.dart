import 'root.dart';
import '../season/root.dart';

class TeamUserSeasons {
  late Team team;
  late List<Season> seasons;
  late SeasonUser user;

  TeamUserSeasons({
    required this.team,
    required this.seasons,
    required this.user,
  });

  TeamUserSeasons.fromJson(Map<String, dynamic> json) {
    team = Team.fromJson(json['team']);
    seasons = [];
    json['seasons'].forEach((v) {
      seasons.add(Season.fromJson(v));
    });
    user = SeasonUser.fromJson(json['user']);
  }
}

import 'package:crosscheck_sports/data/root.dart';
import 'package:crosscheck_sports/extras/global_funcs.dart';

Map<String, dynamic> createSeasonUserBody({
  required Team team,
  Season? season,
  required String email,
  required SeasonUserUserFields userFields,
  required SeasonUserTeamFields teamFields,
  SeasonUserSeasonFields? seasonFields,
  required bool isCreate,
}) {
  Map<String, dynamic> body = {
    "email": email,
    "date": dateToString(DateTime.now()),
    "userFields": userFields.toJson(),
  };
  if (season != null) {
    body['seasonFields'] = seasonFields!.toJson();
    if (isCreate) {
      if (seasonFields.pos.isNotEmpty &&
          team.positions.available.contains(seasonFields.pos)) {
        teamFields.pos = seasonFields.pos;
      } else {
        teamFields.pos = team.positions.defaultPosition;
      }
      teamFields.jerseyNumber = seasonFields.jerseyNumber;
      teamFields.jerseySize = seasonFields.jerseySize;
    } else {
      if (teamFields.pos.isEmpty &&
          team.positions.available
              .any((element) => element == seasonFields.pos)) {
        teamFields.pos = seasonFields.pos;
      }
      if (teamFields.jerseyNumber.isEmpty) {
        teamFields.jerseyNumber = seasonFields.jerseyNumber;
      }
      if (teamFields.jerseySize.isEmpty) {
        teamFields.jerseySize = seasonFields.jerseySize;
      }
    }
  }
  body['teamFields'] = teamFields.toJson();
  print(body['teamFields']);
  return body;
}

SeasonUserTeamFields createTeamFields(Team team) {
  var teamFields = SeasonUserTeamFields.empty();
  teamFields.customFields = [for (var i in team.customUserFields) i.clone()];
  teamFields.pos = team.positions.defaultPosition;
  return teamFields;
}

SeasonUserSeasonFields createSeasonFields(Season season) {
  var seasonFields = SeasonUserSeasonFields.empty();
  seasonFields.pos = season.positions.defaultPosition;
  seasonFields.customFields = [
    for (var i in season.customUserFields) i.clone()
  ];
  return seasonFields;
}

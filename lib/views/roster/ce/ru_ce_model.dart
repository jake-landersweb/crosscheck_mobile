import 'package:crosscheck_sports/views/root.dart';
import 'package:flutter/material.dart';
import 'package:crosscheck_sports/data/root.dart';
import 'package:crosscheck_sports/extras/root.dart';

class RUCEModel extends ChangeNotifier {
  late Team team;
  Season? season;
  late String email;
  late SeasonUserUserFields userFields;
  late SeasonUserTeamFields teamFields;
  SeasonUserSeasonFields? seasonFields;

  late bool isCreate;
  late bool isTeamToSeason;

  RUCEModel.createTeam(this.team) {
    email = "";
    userFields = SeasonUserUserFields.empty();
    teamFields = createTeamFields(team);
    isCreate = true;
    isTeamToSeason = false;
  }

  RUCEModel.createSeason(this.team, this.season) {
    email = "";
    userFields = SeasonUserUserFields.empty();
    teamFields = createTeamFields(team);
    seasonFields = createSeasonFields(season!);
    isCreate = true;
    isTeamToSeason = false;
  }

  RUCEModel.editTeam(this.team, SeasonUser seasonUser) {
    email = seasonUser.email;
    userFields = SeasonUserUserFields.of(seasonUser.userFields!);
    teamFields = SeasonUserTeamFields.of(seasonUser.teamFields!);
    isCreate = false;
    isTeamToSeason = false;
  }

  RUCEModel.editSeason(this.team, this.season, SeasonUser seasonUser) {
    email = seasonUser.email;
    userFields = SeasonUserUserFields.of(seasonUser.userFields!);
    teamFields = SeasonUserTeamFields.of(seasonUser.teamFields!);
    seasonFields = SeasonUserSeasonFields.of(seasonUser.seasonFields!);
    isCreate = false;
    isTeamToSeason = false;
  }

  RUCEModel.teamToSeason(this.team, this.season, SeasonUser seasonUser) {
    email = seasonUser.email;
    userFields = SeasonUserUserFields.of(seasonUser.userFields!);
    teamFields = SeasonUserTeamFields.of(seasonUser.teamFields!);
    seasonFields = SeasonUserSeasonFields.of(seasonUser.seasonFields!);
    isCreate = true;
    isTeamToSeason = true;
  }

  Map<String, dynamic> createBody() {
    return createSeasonUserBody(
      team: team,
      season: season,
      email: email,
      userFields: userFields,
      teamFields: teamFields,
      seasonFields: seasonFields,
      isCreate: isCreate,
    );
  }

  bool isValid() {
    if (!emailIsValid(email)) {
      return false;
    } else if (userFields.firstName == "") {
      return false;
    } else {
      return true;
    }
  }

  String validationText() {
    if (!emailIsValid(email)) {
      return "Please enter a valid email address";
    } else if (userFields.firstName == "") {
      return "First name cannot be empty";
    } else {
      return isCreate ? "Create" : "Update";
    }
  }

  void updateState() => notifyListeners();
}

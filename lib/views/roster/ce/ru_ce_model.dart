import 'package:flutter/material.dart';
import 'package:pnflutter/data/root.dart';
import 'package:pnflutter/extras/root.dart';

class RUCEModel extends ChangeNotifier {
  late Team team;
  Season? season;
  late String email;
  late SeasonUserUserFields userFields;
  late SeasonUserTeamFields teamFields;
  SeasonUserSeasonFields? seasonFields;

  late bool isCreate;

  RUCEModel.createTeam(this.team) {
    email = "";
    userFields = SeasonUserUserFields.empty();
    teamFields = SeasonUserTeamFields.empty();
    teamFields.customFields = [for (var i in team.customUserFields) i.clone()];
    teamFields.pos = team.positions.defaultPosition;
    isCreate = true;
  }

  RUCEModel.createSeason(this.team, this.season) {
    email = "";
    userFields = SeasonUserUserFields.empty();
    teamFields = SeasonUserTeamFields.empty();
    teamFields.customFields = [for (var i in team.customUserFields) i.clone()];
    teamFields.pos = team.positions.defaultPosition;
    seasonFields = SeasonUserSeasonFields.empty();
    seasonFields!.customFields = [
      for (var i in season!.customUserFields) i.clone()
    ];
    seasonFields!.pos = season!.positions.defaultPosition;
    isCreate = true;
  }

  RUCEModel.editTeam(this.team, SeasonUser seasonUser) {
    email = seasonUser.email;
    userFields = SeasonUserUserFields.of(seasonUser.userFields!);
    teamFields = SeasonUserTeamFields.of(seasonUser.teamFields!);
    isCreate = false;
  }

  RUCEModel.editSeason(this.team, this.season, SeasonUser seasonUser) {
    email = seasonUser.email;
    userFields = SeasonUserUserFields.of(seasonUser.userFields!);
    teamFields = SeasonUserTeamFields.of(seasonUser.teamFields!);
    seasonFields = SeasonUserSeasonFields.of(seasonUser.seasonFields!);
    isCreate = false;
  }

  Map<String, dynamic> createBody() {
    Map<String, dynamic> body = {
      "email": email,
      "date": dateToString(DateTime.now()),
      "userFields": userFields.toJson(),
      "teamFields": teamFields.toJson(),
    };
    if (season != null) {
      body['seasonFields'] = seasonFields!.toJson();
    }
    return body;
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
}

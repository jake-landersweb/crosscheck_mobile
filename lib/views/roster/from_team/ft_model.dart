import 'dart:developer';

import 'package:crosscheck_sports/client/root.dart';
import 'package:crosscheck_sports/data/root.dart';
import 'package:crosscheck_sports/extras/global_funcs.dart';
import 'package:crosscheck_sports/views/root.dart';
import 'package:flutter/material.dart';

class FTModel extends ChangeNotifier {
  List<SeasonUser>? users;
  late Team team;
  late Season season;

  bool isLoading = false;

  List<SeasonUser> selectedUsers = [];

  FTModel(this.team, this.season, DataModel dmodel) {
    fetchUsers(dmodel);
  }

  void setUsers(List<SeasonUser> users) {
    this.users = users;
    notifyListeners();
  }

  void addUser(SeasonUser user) {
    // add a clone
    var seasonFields = SeasonUserSeasonFields.empty();
    if (season.positions.available
        .any((element) => element == user.teamFields!.pos)) {
      seasonFields.pos = user.teamFields!.pos;
    } else {
      seasonFields.pos = season.positions.defaultPosition;
    }
    seasonFields.jerseyNumber = user.teamFields!.jerseyNumber;
    seasonFields.jerseySize = user.teamFields!.jerseySize;
    user.seasonFields = seasonFields;
    selectedUsers.add(SeasonUser.of(user));
    notifyListeners();
  }

  void removeUser(SeasonUser user) {
    selectedUsers.removeWhere((element) => element.email == user.email);
    notifyListeners();
  }

  void handleSelect(SeasonUser user) {
    if (selectedUsers.any((element) => element.email == user.email)) {
      removeUser(user);
    } else {
      addUser(user);
    }
  }

  void handleUpdate(SeasonUser user) {
    print(user.seasonFields!.toJson());
    // get the index
    int index =
        selectedUsers.indexWhere((element) => element.email == user.email);
    // remove
    selectedUsers.removeWhere((element) => element.email == user.email);
    // re-add at index
    selectedUsers.insert(index, user);
    // update state
    notifyListeners();
  }

  Future<void> fetchUsers(DataModel dmodel) async {
    isLoading = true;
    notifyListeners();
    // fetch users
    await dmodel.getTeamRosterNotOnSeason(
      team.teamId,
      season.seasonId,
      (p0) => setUsers(p0),
    );
    isLoading = false;
    notifyListeners();
  }

  Map<String, dynamic> createBody() {
    List<Map<String, dynamic>> u = [];
    for (var i in selectedUsers) {
      u.add(createSeasonUserBody(
        team: team,
        season: season,
        email: i.email,
        userFields: i.userFields!,
        teamFields: i.teamFields!,
        seasonFields: i.seasonFields,
        isCreate: false,
      ));
    }
    log(u.toString());
    return {"users": u, "date": dateToString(DateTime.now())};
  }
}

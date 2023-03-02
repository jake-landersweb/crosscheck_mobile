import 'dart:developer';

import 'package:crosscheck_sports/client/root.dart';
import 'package:crosscheck_sports/data/root.dart';
import 'package:crosscheck_sports/extras/global_funcs.dart';
import 'package:crosscheck_sports/views/root.dart';
import 'package:flutter/material.dart';

class FSModel extends ChangeNotifier {
  late Team team;
  late Season season;
  late List<SeasonUser> seasonRoster;
  List<SeasonUser> selectedUsers = [];
  List<Season>? seasons;
  bool isLoadingSeasons = true;
  String? seasonLoadErrorText;
  String? rosterLoadErrorText;
  bool isLoading = false;

  FSModel({
    required this.team,
    required this.season,
    required this.seasonRoster,
    required DataModel dmodel,
  }) {
    fetchSeasons(team.teamId, dmodel);
  }

  void removeUser(SeasonUser user) {
    selectedUsers.removeWhere((element) => element.email == user.email);
    notifyListeners();
  }

  void addUser(SeasonUser user) {
    // add a clone
    selectedUsers.add(SeasonUser.of(user));
    notifyListeners();
  }

  void selectUser(SeasonUser user) {
    if (selectedUsers.any((element) => element.email == user.email)) {
      // remove the user
      removeUser(user);
    } else {
      // add user
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

  Future<void> fetchSeasons(String teamId, DataModel dmodel) async {
    isLoadingSeasons = true;
    notifyListeners();
    await dmodel.getAllSeasons(teamId, (p0) {
      // add all seasons except current
      seasons = [];
      for (var i in p0) {
        if (season.seasonId != i.seasonId) {
          seasons!.add(i);
        }
      }
    }, onError: () {
      seasonLoadErrorText = "There was an issue getting the seasons";
    });
    isLoadingSeasons = false;
    notifyListeners();
  }

  Future<void> fetchSeasonRoster(String teamId, String seasonId,
      DataModel dmodel, void Function(List<SeasonUser>) completion) async {
    await dmodel.getSeasonRoster(teamId, seasonId, (p0) {
      completion(p0);
    }, onError: () {
      rosterLoadErrorText = "There was an issue fetching the season roster";
    });
    notifyListeners();
  }
}

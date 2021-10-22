import 'dart:convert';

import 'package:flutter/material.dart';

import 'root.dart';

import '../data/root.dart';

extension TeamCalls on DataModel {
  Future<void> teamUserSeasonsGet(
      String teamId, String email, Function(TeamUserSeasons) completion) async {
    var response = await client.fetch("/teams/$teamId/users/$email/tusRaw");

    if (response == null) {
      setError("There was an issue fetching your team information", true);
    } else if (response['status'] == 200) {
      setSuccess("Successfully got tus", false);
      completion(TeamUserSeasons.fromJson(response['body']));
    } else {
      setError("There was an issue fetching your team information", true);
      print(response['message']);
      if (response['status'] == 500) {
        // the team was not found, remove from prefs
        prefs.remove("teamId");
        // reget the data if the team info failed
        init();
      }
    }
  }

  Future<void> getTeamRoster(
      String teamId, Function(List<SeasonUser>) completion) async {
    await client.fetch("/teams/$teamId/users").then((response) {
      if (response == null) {
        setError("There was an issue fetching the schedule", true);
      } else if (response['status'] == 200) {
        setSuccess("Successfully fetched schedule", false);
        List<SeasonUser> users = [];
        for (var i in response['body']) {
          users.add(SeasonUser.fromJson(i));
        }
        completion(users);
      } else {
        setError("There was an issue fetching the schedule", true);
        print(response['message']);
      }
    });
  }

  Future<void> teamUserUpdate(String teamId, String email,
      Map<String, dynamic> body, VoidCallback completion,
      {bool? showMessages}) async {
    Map<String, String> headers = {'Content-Type': 'application/json'};

    await client
        .put("/teams/$teamId/users/$email/update", headers, jsonEncode(body))
        .then((response) {
      if (response == null) {
        setError("There was an issue updating your user record", true);
      } else if (response['status'] == 200) {
        setSuccess("Successfully updated user record", true);
        completion();
      } else {
        setError("There was an issue updating your user record", true);
        print(response['message']);
      }
    });
  }
}

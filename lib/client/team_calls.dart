import 'dart:convert';

import 'package:flutter/foundation.dart';
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
      prefs.remove("teamId");
      // TODO -- fix issue when user team does not work
      // reget the data if the team info failed
      // init();
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

  Future<void> createTeam(
      Map<String, dynamic> body, Function(Team) completion) async {
    Map<String, String> headers = {'Content-Type': 'application/json'};

    await client
        .post("/createTeam", headers, jsonEncode(body))
        .then((response) {
      if (response == null) {
        setError("There was an issue creating the team", true);
      } else if (response['status'] == 200) {
        setSuccess("Successfully created your team!", true);
        completion(Team.fromJson(response['body']));
      } else {
        setError("There was an issue creating the team", true);
        print(response['message']);
      }
    });
  }

  Future<void> updateTeam(
      String teamId, Map<String, dynamic> body, VoidCallback completion) async {
    Map<String, String> headers = {'Content-Type': 'application/json'};

    await client
        .put("/teams/$teamId/update", headers, jsonEncode(body))
        .then((response) {
      if (response == null) {
        setError("There was an issue updating the team", true);
      } else if (response['status'] == 200) {
        setSuccess("Successfully updated your team", true);
        completion();
      } else {
        setError("There was an issue updating the team", true);
        print(response['message']);
      }
    });
  }

  Future<void> createTeamUser(String teamId, Map<String, dynamic> body,
      Function(SeasonUser) completion) async {
    Map<String, String> headers = {'Content-Type': 'application/json'};

    await client
        .post("/teams/$teamId/createUser", headers, jsonEncode(body))
        .then((response) {
      if (response == null) {
        setError("There was an issue adding the user", true);
      } else if (response['status'] == 200) {
        setSuccess("Successfully added user", true);
        completion(SeasonUser.fromJson(response['body']));
      } else {
        setError("There was an issue adding the user", true);
        print(response['message']);
      }
    });
  }

  Future<void> validateUser(
      String email, Map<String, dynamic> body, VoidCallback completion) async {
    Map<String, String> headers = {'Content-Type': 'application/json'};

    await client
        .put("/users/$email/validate", headers, jsonEncode(body))
        .then((response) {
      if (response == null) {
        setError("There was an issue joining the team", true);
      } else if (response['status'] == 200) {
        setSuccess("Successfully joined team", true);
        completion();
      } else {
        print(response.toString());
        if (response['status'] < 400) {
          setError(response['message'], true);
        } else {
          setError("There was an issue joining the team", true);
        }
      }
    });
  }
}

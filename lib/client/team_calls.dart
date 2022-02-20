import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'root.dart';

import '../data/root.dart';

extension TeamCalls on DataModel {
  Future<void> teamUserSeasonsGet(
      String teamId, String email, Function(TeamUserSeasons) completion,
      {VoidCallback? onError}) async {
    var response = await client.fetch("/teams/$teamId/users/$email/tusRaw");

    if (response == null) {
      addIndicator(IndicatorItem.error(
          "There was an issue fetching your team information"));
      if (onError != null) {
        onError();
      }
    } else if (response['status'] == 200) {
      print("Successfully got tus");
      completion(TeamUserSeasons.fromJson(response['body']));
    } else {
      addIndicator(IndicatorItem.error(
          "There was an issue fetching your team information"));
      print(response['message']);
      prefs.remove("teamId");
      if (onError != null) {
        onError();
      }
    }
  }

  Future<void> getTeamRoster(
      String teamId, Function(List<SeasonUser>) completion) async {
    await client.fetch("/teams/$teamId/users").then((response) {
      if (response == null) {
        addIndicator(
            IndicatorItem.error("There was an issue fetching the schedule"));
      } else if (response['status'] == 200) {
        print("Successfully fetched schedule");
        List<SeasonUser> users = [];
        for (var i in response['body']) {
          users.add(SeasonUser.fromJson(i));
        }
        completion(users);
      } else {
        addIndicator(
            IndicatorItem.error("There was an issue fetching the schedule"));
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
        addIndicator(IndicatorItem.error(
            "There was an issue updating your user record"));
      } else if (response['status'] == 200) {
        addIndicator(IndicatorItem.success("Successfully updated user record"));
        completion();
      } else {
        addIndicator(IndicatorItem.error(
            "There was an issue updating your user record"));
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
        addIndicator(
            IndicatorItem.error("There was an issue creating the team"));
      } else if (response['status'] == 200) {
        addIndicator(IndicatorItem.success("Successfully created your team!"));
        completion(Team.fromJson(response['body']));
      } else {
        addIndicator(
            IndicatorItem.error("There was an issue creating the team"));
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
        addIndicator(
            IndicatorItem.error("There was an issue updating the team"));
      } else if (response['status'] == 200) {
        print(response);
        addIndicator(IndicatorItem.success("Successfully updated your team"));
        completion();
      } else {
        addIndicator(
            IndicatorItem.error("There was an issue updating the team"));
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
        addIndicator(IndicatorItem.error("There was an issue adding the user"));
      } else if (response['status'] == 200) {
        addIndicator(IndicatorItem.success("Successfully added user"));
        completion(SeasonUser.fromJson(response['body']));
      } else {
        addIndicator(IndicatorItem.error("There was an issue adding the user"));
        print(response['message']);
      }
    });
  }

  Future<void> validateUser(String email, Map<String, dynamic> body,
      Future<void> Function(String) completion) async {
    Map<String, String> headers = {'Content-Type': 'application/json'};

    await client
        .put("/users/$email/validate", headers, jsonEncode(body))
        .then((response) {
      if (response == null) {
        addIndicator(
            IndicatorItem.error("There was an issue joining the team"));
      } else if (response['status'] == 200) {
        addIndicator(IndicatorItem.success("Successfully joined team"));
        completion(response['body']);
      } else {
        print(response.toString());
        if (response['status'] < 400) {
          addIndicator(IndicatorItem.error(response['message']));
        } else {
          addIndicator(
              IndicatorItem.error("There was an issue joining the team"));
        }
      }
    });
  }
}

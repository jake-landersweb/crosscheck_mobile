import 'dart:convert';
import 'package:flutter/material.dart';
import 'root.dart';
import '../data/root.dart';

extension SeasonCalls on DataModel {
  void seasonUserGet(String teamId, String seasonId, String email,
      Function(SeasonUser) completion,
      {bool? showMessages}) async {
    var response =
        await client.fetch("/teams/$teamId/seasons/$seasonId/users/$email");

    if (response == null) {
      if (showMessages ?? false) {
        setError("There was an issue getting the user record", true);
      }
    } else if (response['status'] == 200) {
      setSuccess("Successfully found season user", false);
      completion(SeasonUser.fromJson(response['body']));
    } else {
      if (showMessages ?? false) {
        setError("There was an issue getting the user record", true);
      }
      print(response['message']);
    }
  }

  Future<void> getSeasonRoster(String teamId, String seasonId,
      Function(List<SeasonUser>) completion) async {
    await client
        .fetch("/teams/$teamId/seasons/$seasonId/users")
        .then((response) {
      if (response == null) {
        setError("There was an issue getting the season roster", true);
      } else if (response['status'] == 200) {
        setSuccess("Successfully got season roster", false);
        List<SeasonUser> users = [];
        for (var i in response['body']) {
          users.add(SeasonUser.fromJson(i));
        }
        completion(users);
      } else {
        setError("There was an issue getting the season roster", true);
        print(response['message']);
      }
    });
  }

  Future<void> seasonUserUpdate(String teamId, String seasonId, String email,
      Map<String, dynamic> body, Function(SeasonUser) completion) async {
    Map<String, String> headers = {'Content-Type': 'application/json'};

    await client
        .put("/teams/$teamId/seasons/$seasonId/users/$email/update", headers,
            jsonEncode(body))
        .then((response) {
      if (response == null) {
        setError("There was an issue updating the user record", true);
      } else if (response['status'] == 200) {
        setSuccess("Successfully updated user record", true);
        completion(SeasonUser.fromJson(response['body']));
      } else {
        setError("There was an issue updating the user record", true);
        print(response['message']);
      }
    });
  }

  Future<void> seasonUserAdd(String teamId, String seasonId,
      Map<String, dynamic> body, Function(SeasonUser) completion) async {
    Map<String, String> headers = {'Content-Type': 'application/json'};

    await client
        .post("/teams/$teamId/seasons/$seasonId/createUser", headers,
            jsonEncode(body))
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

  Future<void> createSeason(
      String teamId, Map<String, dynamic> body, VoidCallback completion) async {
    Map<String, String> headers = {'Content-Type': 'application/json'};

    // first create the season
    await client
        .post("/teams/$teamId/createSeason", headers, jsonEncode(body))
        .then((response) {
      if (response == null) {
        setError("There was an issue creating the season", true);
      } else if (response['status'] == 200) {
        completion();
        print(response);
        setSuccess("Successfully created season", true);
      } else if (response['status'] < 400) {
        completion();
        setError("Your season was created, but " + response['message'], true);
      } else {
        print(response['message']);
        setError("There was an issue creating your season", true);
      }
    });
  }

  Future<void> updateSeason(String teamId, String seasonId,
      Map<String, dynamic> body, VoidCallback completion) async {
    Map<String, String> headers = {'Content-Type': 'application/json'};

    // first create the season
    await client
        .put("/teams/$teamId/seasons/$seasonId/update", headers,
            jsonEncode(body))
        .then((response) {
      if (response == null) {
        setError("There was an issue updating the season", true);
      } else if (response['status'] == 200) {
        completion();
        print(response);
        setSuccess("Successfully updated season", true);
      } else if (response['status'] < 400) {
        completion();
        setError(
            "Your season was updated, but there was an issue with your custom fields or stats",
            true);
        print(response['message']);
      } else {
        print(response['message']);
        setError("There was an issue updating your season", true);
      }
    });
  }
}

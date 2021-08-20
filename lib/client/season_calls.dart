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

  Future<void> seasonUserUpdate(
      String teamId,
      String seasonId,
      String email,
      String firstName,
      String lastName,
      String phone,
      String nickName,
      VoidCallback completion,
      {bool? showMessages}) async {
    Map<String, dynamic> body = {
      "email": email,
      "userFields": {
        "firstName": firstName,
        "lastName": lastName,
        "phone": phone,
      },
      "seasonFields": {
        "nickName": nickName,
      }
    };

    Map<String, String> headers = {'Content-Type': 'application/json'};

    await client
        .put("/teams/$teamId/seasons/$seasonId/users/$email/update", headers,
            jsonEncode(body))
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

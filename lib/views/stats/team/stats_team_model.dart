import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pnflutter/data/root.dart';
import '../../../client/root.dart';
import 'package:http/http.dart' as http;

class StatsTeamModel extends ChangeNotifier {
  StatsTeamModel(this.team) {
    init();
  }

  Future<void> init() async {
    await userStatsGet(team.teamId, (userStats) => setUserStats(userStats));
  }

  Client client = Client(client: http.Client());
  late Team team;
  List<UserStat>? userStats;
  bool isLoading = false;

  void setUserStats(List<UserStat> userStats) {
    this.userStats = userStats;
    notifyListeners();
  }

  Future<void> userStatsGet(
      String teamId, Function(List<UserStat>) completion) async {
    isLoading = true;
    notifyListeners();
    print("fetching stats for team: ${team.teamId}");
    var response = await client.fetch("/teams/$teamId/stats");

    if (response == null) {
      // setError("There was an issue fetching the stats", true);
      print("There was an issue fetching the stats");
    } else if (response['status'] == 200) {
      // setSuccess("Successfully got stats", false);
      print("successfully got stats");
      List<UserStat> list = [];
      for (var i in response['body']) {
        list.add(UserStat.fromJson(i));
      }
      completion(list);
    } else {
      // setError("There was an issue fetching the stats", true);
      print("There was an issue fetching the stats");
      print(response['message']);
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> updateUserList(String teamId, List<UserStat> oldList,
      List<UserStat> newList, AsyncCallback completion) async {
    Map<String, dynamic> body = _prepBody(oldList, newList);
    print(body);

    Map<String, String> headers = {'Content-Type': 'application/json'};

    var response = await client.put(
        "/teams/$teamId/incrementStats", headers, jsonEncode(body));

    if (response == null) {
      print("There was an issue updating the user stats");
    } else if (response['status'] == 200) {
      print("successfully incremented stats");
      completion();
    } else {
      print("There was an issue updating the user stats");
      print(response['message']);
    }
  }

  Map<String, dynamic> _prepBody(
      List<UserStat> oldList, List<UserStat> newList) {
    List<Map<String, dynamic>> userList = [];
    // compose the new list
    for (var newItem in newList) {
      var oldItem =
          oldList.firstWhere((element) => element.email == newItem.email);
      List<Map<String, dynamic>> statMapList = [];
      for (var oldStat in oldItem.stats) {
        var newStat = newItem.stats
            .firstWhere((element) => element.title == oldStat.title);
        if (oldStat.value != newStat.value) {
          statMapList.add({
            "title": newStat.title,
            "increment": newStat.value - oldStat.value,
          });
        }
      }
      if (statMapList.isNotEmpty) {
        userList.add({
          "email": oldItem.email,
          "stats": statMapList,
        });
      }
    }

    Map<String, dynamic> body = {"users": userList};
    return body;
  }

  @override
  void dispose() {
    userStats = null;
    super.dispose();
  }
}

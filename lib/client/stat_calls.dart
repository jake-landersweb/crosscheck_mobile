import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'root.dart';

import '../data/root.dart';

extension StatCalls on DataModel {
  Future<void> teamStatsGet(
      String teamId, Function(List<UserStat>) completion) async {
    var response = await client.fetch("/teams/$teamId/stats");

    if (response == null) {
      setError("There was an issue fetching the stats", true);
    } else if (response['status'] == 200) {
      setSuccess("Successfully got stats", false);
      List<UserStat> list = [];
      for (var i in response['body']) {
        list.add(UserStat.fromJson(i));
      }
      completion(list);
    } else {
      setError("There was an issue fetching the stats", true);
      print(response['message']);
    }
  }
}

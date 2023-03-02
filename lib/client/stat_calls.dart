import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'root.dart';

import '../data/root.dart';

extension StatCalls on DataModel {
  Future<void> teamStatsGet(
      String teamId, Function(List<UserStat>) completion) async {
    var response = await client.fetch("/teams/$teamId/stats");

    if (response == null) {
      addIndicator(
          IndicatorItem.error("There was an issue fetching the stats"));
    } else if (response['status'] == 200) {
      print("Successfully got stats");
      List<UserStat> list = [];
      for (var i in response['body']) {
        list.add(UserStat.fromJson(i));
      }
      completion(list);
    } else {
      addIndicator(
          IndicatorItem.error("There was an issue fetching the stats"));
      print(response['message']);
    }
  }
}

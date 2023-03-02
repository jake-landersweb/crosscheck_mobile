import 'dart:convert';

import 'package:flutter/material.dart';

import 'root.dart';
import '../data/root.dart';
import '../extras/root.dart';

extension MiscCalls on DataModel {
  Future<void> getVersion(double major, double minor,
      Function(bool update, bool maintenance) completion, VoidCallback onError,
      {String? teamId}) async {
    Map<String, String> headers = {'Content-Type': 'application/json'};
    var body = {
      "major": major,
      "minor": minor,
      "teamId": teamId,
    };
    final response = await client.put("/version", headers, jsonEncode(body));

    if (response == null) {
      print("version was null");
      addIndicator(
          IndicatorItem.error("There was an issue getting the app version"));
      onError();
    } else if (response['status'] == 200) {
      print("Successfully got version");
      completion(
        response['body']['update'],
        response['body']['maintenance'],
      );
    } else {
      print(response['message']);
      addIndicator(
          IndicatorItem.error("There was an issue getting the app version"));
      onError();
    }
  }
}

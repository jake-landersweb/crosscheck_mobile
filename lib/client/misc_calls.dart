import 'dart:convert';

import 'package:flutter/material.dart';

import 'root.dart';
import '../data/root.dart';
import '../extras/root.dart';

extension MiscCalls on DataModel {
  Future<void> getVersion(Function(double, bool) completion) async {
    final response = await client.fetch("/version");

    if (response == null) {
      setError("There was an issue getting the app version", true);
    } else if (response['status'] == 200) {
      setSuccess("Successfully got version", false);
      print(response['message']);
      completion(response['message'], response['showMaintenance']);
    } else {
      print(response['message']);
      setError("There was an issue getting the app version", true);
    }
  }
}

import 'dart:convert';

import 'package:flutter/material.dart';

import 'root.dart';
import '../data/root.dart';
import '../extras/root.dart';

extension MiscCalls on DataModel {
  Future<double> getVersion() async {
    final response = await client.fetch("/version");

    if (response == null) {
      setError("There was an issue getting the app version", true);
    } else if (response['status'] == 200) {
      setSuccess("Successfully got version", false);
      print(response['message']);
      return response['message'];
    } else {
      print(response['message']);
      setError("There was an issue getting the app version", true);
    }
    return 0;
  }
}

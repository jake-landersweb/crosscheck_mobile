import 'dart:convert';

import 'package:crosscheck_sports/client/root.dart';
import 'package:crosscheck_sports/data/indicator_item.dart';
import 'package:crosscheck_sports/data/roster/roster_group.dart';
import 'package:flutter/material.dart';

extension RosterGroupCalls on DataModel {
  Future<void> createRostergroup(
    String teamId,
    String seasonId,
    Map<String, dynamic> body,
    void Function(RosterGroup) completion,
    VoidCallback onError,
  ) async {
    Map<String, String> headers = {'Content-Type': 'application/json'};

    var response = await client.post(
        "/teams/$teamId/seasons/$seasonId/rosterGroups",
        headers,
        jsonEncode(body));

    if (response == null) {
      debugPrint("There was an issue creating the roster group");
      onError();
    } else if (response['status'] == 200) {
      debugPrint("Successfully created roster group");
      completion(RosterGroup.fromJson(response['body']));
    } else {
      debugPrint("There was an issue creating the roster group");
      onError();
    }
  }

  Future<void> getAllRosterGroups(
    String teamId,
    String seasonId,
    void Function(List<RosterGroup>) completion,
    VoidCallback onError,
  ) async {
    var response =
        await client.fetch("/teams/$teamId/seasons/$seasonId/rosterGroups");
    if (response == null) {
      debugPrint(
          "There was an issue getting the roster groups for season: $seasonId");
      onError();
    } else if (response['status'] == 200) {
      debugPrint("Successfully got roster groups");
      List<RosterGroup> rgs = [];
      for (var i in response['body']) {
        rgs.add(RosterGroup.fromJson(i));
      }
      completion(rgs);
    } else {
      debugPrint(
          "There was an issue getting the roster groups for season: $seasonId");
      onError();
    }
  }

  Future<void> getRosterGroup(
    String teamId,
    String seasonId,
    String sortKey,
    void Function(RosterGroup) completion,
    VoidCallback onError,
  ) async {
    var response = await client
        .fetch("/teams/$teamId/seasons/$seasonId/rosterGroups/$sortKey");
    if (response == null) {
      debugPrint(
          "There was an issue getting the roster group with seasonId: $seasonId sortKey: $sortKey");
      onError();
    } else if (response['status'] == 200) {
      debugPrint("Successfully got the roster group");
      completion(RosterGroup.fromJson(response['body']));
    } else {
      debugPrint(
          "There was an issue getting the roster group with seasonId: $seasonId sortKey: $sortKey");
      onError();
    }
  }

  Future<void> updateRosterGroup(
    String teamId,
    String seasonId,
    String sortKey,
    Map<String, dynamic> body,
    void Function(RosterGroup) completion,
    VoidCallback onError,
  ) async {
    Map<String, String> headers = {'Content-Type': 'application/json'};

    var response = await client.put(
      "/teams/$teamId/seasons/$seasonId/rosterGroups/$sortKey",
      headers,
      jsonEncode(body),
    );

    if (response == null) {
      debugPrint(
          "There was an unknown issue updating the roster group with seasonId: $seasonId sortKey: $sortKey");
      onError();
    } else if (response['status'] == 200) {
      debugPrint("Successfully updated roster group");
      completion(RosterGroup.fromJson(response['body']));
    } else {
      debugPrint(response['message']);
      debugPrint(
          "There was an issue updating the roster group with seasonId: $seasonId sortKey: $sortKey");
      onError();
    }
  }

  Future<void> deleteRosterGroup(
    String teamId,
    String seasonId,
    String sortKey,
    VoidCallback completion,
    VoidCallback onError,
  ) async {
    var response = await client
        .delete("/teams/$teamId/seasons/$seasonId/rosterGroups/$sortKey");

    if (response == null) {
      debugPrint(
          "There was an issue deleting the roster group with seasonId: $seasonId sortKey: $sortKey");
      onError();
    } else if (response['status'] == 200) {
      debugPrint("Successfully deleted roster group");
      completion();
    } else {
      debugPrint(
          "There was an issue deleted the roster group with seasonId: $seasonId sortKey: $sortKey");
      onError();
    }
  }
}

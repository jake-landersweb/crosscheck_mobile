import 'dart:convert';

import 'package:crosscheck_sports/client/root.dart';
import 'package:crosscheck_sports/data/root.dart';
import 'package:flutter/material.dart';

extension LineupCalls on DataModel {
  Future<void> createLineup(
    String teamId,
    String seasonId,
    String eventId,
    Map<String, dynamic> body,
    void Function(Lineup) completion,
    VoidCallback onError,
  ) async {
    Map<String, String> headers = {'Content-Type': 'application/json'};

    var response = await client.post(
      "/teams/$teamId/seasons/$seasonId/events/$eventId/lineup",
      headers,
      jsonEncode(body),
    );

    if (response == null) {
      debugPrint("There was an issue creating the lineup");
      onError();
    } else if (response['status'] == 200) {
      debugPrint("Successfully created lineup");
      completion(Lineup.fromJson(response['body']));
    } else {
      debugPrint("There was an issue creating the lineup");
      print(response['message']);
      onError();
    }
  }

  Future<void> getAllLineups(
    String teamId,
    String seasonId,
    void Function(List<Lineup>) completion,
    VoidCallback onError, {
    bool includeEvents = false,
  }) async {
    late dynamic response;
    if (includeEvents) {
      response = await client
          .fetch("/teams/$teamId/seasons/$seasonId/lineupsWithEvent");
    } else {
      response = await client.fetch("/teams/$teamId/seasons/$seasonId/lineups");
    }
    if (response == null) {
      debugPrint(
          "There was an issue getting the lineups with seasonId: $seasonId");
      onError();
    } else if (response['status'] == 200) {
      debugPrint("Successfully got all lineups");
      List<Lineup> lineups = [];
      for (var i in response['body']) {
        lineups.add(Lineup.fromJson(i));
      }
      completion(lineups);
    } else {
      debugPrint(
          "There was an issue getting the lineups with seasonId: $seasonId");
      onError();
    }
  }

  Future<void> getLineup(
    String teamId,
    String seasonId,
    String eventId,
    void Function(Lineup) completion,
    VoidCallback onError,
  ) async {
    var response = await client
        .fetch("/teams/$teamId/seasons/$seasonId/events/$eventId/lineup");
    if (response == null) {
      debugPrint(
          "There was an issue getting the lineup with seasonId: $seasonId eventId: $eventId");
      onError();
    } else if (response['status'] == 200) {
      debugPrint("Successfully got the lineup");
      completion(Lineup.fromJson(response['body']));
    } else {
      debugPrint(
          "There was an issue getting the lineup with seasonId: $seasonId eventId: $eventId");
      onError();
    }
  }

  Future<void> updateLineup(
    String teamId,
    String seasonId,
    String eventId,
    Map<String, dynamic> body,
    void Function(Lineup) completion,
    VoidCallback onError,
  ) async {
    Map<String, String> headers = {'Content-Type': 'application/json'};

    var response = await client.put(
      "/teams/$teamId/seasons/$seasonId/events/$eventId/lineup",
      headers,
      jsonEncode(body),
    );

    if (response == null) {
      debugPrint(
          "There was an unknown issue updating the lineup with seasonId: $seasonId eventId: $eventId");
      onError();
    } else if (response['status'] == 200) {
      debugPrint("Successfully updated lineup");
      completion(Lineup.fromJson(response['body']));
    } else {
      debugPrint(response['message']);
      debugPrint(
          "There was an issue updating the lineup with seasonId: $seasonId eventId: $eventId");
      onError();
    }
  }

  Future<void> deleteLineup(
    String teamId,
    String seasonId,
    String eventId,
    VoidCallback completion,
    VoidCallback onError,
  ) async {
    var response = await client
        .delete("/teams/$teamId/seasons/$seasonId/events/$eventId/lineup");

    if (response == null) {
      debugPrint(
          "There was an issue deleting the lineup with seasonId: $seasonId eventId: $eventId");
      onError();
    } else if (response['status'] == 200) {
      debugPrint("Successfully deleted lineup");
      completion();
    } else {
      debugPrint(
          "There was an issue deleted the lineup with seasonId: $seasonId eventId: $eventId");
      onError();
    }
  }
}

// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:flutter/material.dart';

import 'root.dart';
import '../data/root.dart';
import '../extras/root.dart';

extension EventCalls on DataModel {
  Future<void> scheduleGet(String teamId, String seasonId, String email,
      Function(Schedule) completion,
      {bool? showLoads}) async {
    if (showLoads ?? false) {}

    Map<String, dynamic> body = {
      'email': email.toLowerCase(),
      "date": dateToString(DateTime.now()),
    };

    Map<String, String> headers = {'Content-Type': 'application/json'};

    var response = await client.put(
        "/teams/$teamId/seasons/$seasonId/eventsSorted",
        headers,
        jsonEncode(body));

    if (response == null) {
      setError("There was an issue getting the schedule", true);
    } else if (response['status'] == 200) {
      setSuccess("Successfully fetched current schedule", false);
      completion(Schedule.fromjson(response['body']));
    } else {
      setError("There was an issue getting the schedule", true);
      print(response['message']);
    }
  }

  void getUserStatus(String teamId, String seasonId, String eventId,
      String email, Function(int, String) completion) async {
    final response = await client
        .fetch("/teams/$teamId/seasons/$seasonId/events/$eventId/users/$email");

    if (response == null) {
      setError("There was an issue getting your status", true);
    } else if (response['status'] == 200) {
      setSuccess("Successfully got user status", false);
      completion(response['body']['eStatus']?.round() ?? 0,
          response['body']['message']);
    } else {
      print(response['message']);
      setError("There was an issue getting your status", true);
    }
  }

  void updateUserStatus(String teamId, String seasonId, String eventId,
      String email, int status, String message, VoidCallback completion) async {
    Map<String, dynamic> body = {
      'checkInStatus': status,
      "message": message,
    };

    Map<String, String> headers = {'Content-Type': 'application/json'};

    final response = await client.put(
        "/teams/$teamId/seasons/$seasonId/events/$eventId/users/$email/update",
        headers,
        jsonEncode(body));

    if (response == null) {
      setError("There was an issue updating your status", true);
    } else if (response['status'] == 200) {
      setSuccess("Succesfully updated your status", true);
      completion();
    } else {
      print(response['message']);
      setError("There was an issue updating your status", true);
    }
  }

  Future<void> getEventUsers(String teamId, String seasonId, String eventId,
      Function(List<SeasonUserEventFields>) completion) async {
    await client
        .fetch("/teams/$teamId/seasons/$seasonId/events/$eventId/usersRaw")
        .then((response) {
      if (response == null) {
        setError("There was an issue getting the users", true);
      } else if (response['status'] == 200) {
        setSuccess("successfully got event users", false);
        List<SeasonUserEventFields> users = [];
        for (var i in response['body']) {
          users.add(SeasonUserEventFields.fromJson(i));
        }
        completion(users);
      } else {
        setError("There was an issue getting the users", true);
        print(response['message']);
      }
    });
  }

  Future<void> replyToStatus(
      String teamId,
      String seasonId,
      String eventId,
      String email,
      String name,
      String message,
      VoidCallback completion) async {
    Map<String, dynamic> body = {
      'date': dateToString(DateTime.now()),
      "name": name,
      "message": message,
    };

    Map<String, String> headers = {'Content-Type': 'application/json'};

    await client
        .put(
            "/teams/$teamId/seasons/$seasonId/events/$eventId/users/$email/replyCheckIn",
            headers,
            jsonEncode(body))
        .then((response) {
      if (response == null) {
        setError("There was an issue replying to this user", true);
      } else if (response['status'] == 200) {
        setSuccess("Successfully posted reply", true);
        completion();
      } else {
        setError("There was an issue replying to this user", true);
        print(response['message']);
      }
    });
  }

  Future<void> getCalendar(String teamId, String seasonId, String email,
      Function(CalendarEvent) completion) async {
    await client
        .fetch("/teams/$teamId/seasons/$seasonId/users/$email/calendar")
        .then((response) {
      if (response == null) {
        setError("There was an issue fetching the calendar", true);
      } else if (response['status'] == 200) {
        setSuccess("Successfully fetched calendar", false);
        completion(CalendarEvent.fromJson(response['body']));
      } else {
        setError("There was an issue fetching the calendar", true);
        print(response['message']);
      }
    });
  }
}

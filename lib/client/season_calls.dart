// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:developer';
import 'package:crosscheck_sports/extras/root.dart';
import 'package:crosscheck_sports/views/roster/from_excel/root.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
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
        addIndicator(
            IndicatorItem.error("There was an issue getting the user record"));
      }
    } else if (response['status'] == 200) {
      print("Successfully found season user");
      completion(SeasonUser.fromJson(response['body']));
    } else {
      if (showMessages ?? false) {
        addIndicator(
            IndicatorItem.error("There was an issue getting the user record"));
      }
      print(response['message']);
    }
  }

  Future<void> getSeasonRoster(
      String teamId, String seasonId, Function(List<SeasonUser>) completion,
      {VoidCallback? onError}) async {
    await client
        .fetch("/teams/$teamId/seasons/$seasonId/users")
        .then((response) {
      if (response == null) {
        addIndicator(IndicatorItem.error(
            "There was an issue getting the season roster"));
        if (onError != null) onError();
      } else if (response['status'] == 200) {
        print("Successfully got season roster");
        List<SeasonUser> users = [];
        for (var i in response['body']) {
          users.add(SeasonUser.fromJson(i));
        }
        completion(users);
      } else {
        addIndicator(IndicatorItem.error(
            "There was an issue getting the season roster"));
        print(response['message']);
        if (onError != null) onError();
      }
    });
  }

  Future<void> getBatchSeasonRoster(String teamId, String seasonId,
      Function(List<SeasonUser>) completion) async {
    await client
        .fetch("/teams/$teamId/seasons/$seasonId/batchUsers")
        .then((response) {
      if (response == null) {
        addIndicator(IndicatorItem.error(
            "There was an issue getting the season roster"));
      } else if (response['status'] == 200) {
        print("Successfully got batch season roster");
        List<SeasonUser> users = [];
        for (var i in response['body']) {
          users.add(SeasonUser.fromJson(i));
        }
        completion(users);
      } else {
        addIndicator(IndicatorItem.error(
            "There was an issue getting the batch season roster"));
        print(response['message']);
      }
    });
  }

  Future<void> seasonUserUpdate(String teamId, String seasonId, String email,
      Map<String, dynamic> body, VoidCallback completion) async {
    Map<String, String> headers = {'Content-Type': 'application/json'};

    await client
        .put("/teams/$teamId/seasons/$seasonId/users/$email/update", headers,
            jsonEncode(body))
        .then((response) {
      if (response == null) {
        addIndicator(
            IndicatorItem.error("There was an issue updating the user record"));
      } else if (response['status'] == 200) {
        addIndicator(IndicatorItem.success("Successfully updated user record"));
        completion();
      } else {
        addIndicator(
            IndicatorItem.error("There was an issue updating the user record"));
        print(response['message']);
      }
    });
  }

  Future<void> seasonUserAdd(String teamId, String seasonId,
      Map<String, dynamic> body, Function(SeasonUser) completion) async {
    Map<String, String> headers = {'Content-Type': 'application/json'};

    await client
        .post("/teams/$teamId/seasons/$seasonId/createUser", headers,
            jsonEncode(body))
        .then((response) {
      if (response == null) {
        addIndicator(IndicatorItem.error("There was an issue adding the user"));
      } else if (response['status'] == 200) {
        print(response);
        addIndicator(IndicatorItem.success("Successfully added user"));
        completion(SeasonUser.fromJson(response['body']));
      } else {
        addIndicator(IndicatorItem.error("There was an issue adding the user"));
        print(response['message']);
      }
    });
  }

  Future<void> seasonUserAddFromList(String teamId, String seasonId,
      Map<String, dynamic> body, VoidCallback completion) async {
    Map<String, String> headers = {'Content-Type': 'application/json'};

    await client
        .post("/teams/$teamId/seasons/$seasonId/createUsers", headers,
            jsonEncode(body))
        .then((response) {
      if (response == null) {
        addIndicator(
            IndicatorItem.error("There was an issue adding the users"));
      } else if (response['status'] == 200) {
        print(response);
        addIndicator(
            IndicatorItem.success("Successfully added users to season"));
        completion();
      } else {
        addIndicator(
            IndicatorItem.error("There was an issue adding the users"));
        print(response['message']);
      }
    });
  }

  Future<void> createSeason(
      String teamId, Map<String, dynamic> body, VoidCallback completion) async {
    Map<String, String> headers = {'Content-Type': 'application/json'};

    // first create the season
    await client
        .post("/teams/$teamId/createSeason", headers, jsonEncode(body))
        .then((response) async {
      if (response == null) {
        addIndicator(
            IndicatorItem.error("There was an issue creating the season"));
      } else if (response['status'] == 200) {
        await FirebaseAnalytics.instance.logEvent(
          name: "create_season",
          parameters: {"platform": "mobile"},
        );
        completion();
        print(response);
        addIndicator(IndicatorItem.success("Successfully created season"));
      } else if (response['status'] < 400) {
        completion();
        addIndicator(IndicatorItem.error(
            "Your season was created, but " + response['message']));
      } else {
        print(response['message']);
        addIndicator(
            IndicatorItem.error("There was an issue creating your season"));
      }
    });
  }

  Future<void> updateSeason(String teamId, String seasonId,
      Map<String, dynamic> body, VoidCallback completion,
      {showIndicatiors = true, VoidCallback? onError}) async {
    Map<String, String> headers = {'Content-Type': 'application/json'};

    // first create the season
    await client
        .put("/teams/$teamId/seasons/$seasonId/update", headers,
            jsonEncode(body))
        .then((response) {
      if (response == null) {
        if (showIndicatiors) {
          addIndicator(
              IndicatorItem.error("There was an issue updating the season"));
        }
        onError != null ? onError() : null;
      } else if (response['status'] == 200) {
        completion();
        print(response);
        if (showIndicatiors) {
          addIndicator(IndicatorItem.success("Successfully updated season"));
        }
      } else if (response['status'] < 400) {
        completion();
        if (showIndicatiors) {
          addIndicator(IndicatorItem.error(
              "Your season was updated, but there was an issue with your custom fields or stats"));
        }
        print(response['message']);
      } else {
        print(response['message']);
        if (showIndicatiors) {
          addIndicator(
              IndicatorItem.error("There was an issue updating your season"));
        }
        onError != null ? onError() : null;
      }
    });
  }

  Future<void> sendChatNotification(String teamId, String seasonId,
      Map<String, dynamic> body, VoidCallback completion) async {
    Map<String, String> headers = {'Content-Type': 'application/json'};

    // first create the season
    await client
        .put("/teams/$teamId/seasons/$seasonId/sendChatNotification2", headers,
            jsonEncode(body))
        .then((response) {
      if (response == null) {
        print("There was an issue sending the notification");
      } else if (response['status'] == 200) {
        completion();
        print(response);
        print("Successfully sent chat notifications");
      } else {
        print(response);
        print("There was an issue sending the notification");
      }
    });
  }

  Future<void> addTeamUserEmailList(String teamId, String seasonId,
      Map<String, dynamic> body, VoidCallback completion,
      {VoidCallback? onError}) async {
    Map<String, String> headers = {'Content-Type': 'application/json'};

    // first create the season
    await client
        .post("/teams/$teamId/seasons/$seasonId/addTeamUsers", headers,
            jsonEncode(body))
        .then((response) {
      if (response == null) {
        print("There was an issue adding the list of season users");
        addIndicator(IndicatorItem.error("There was an issue adding users"));
        onError != null ? onError() : null;
      } else if (response['status'] == 200) {
        print(response);
        addIndicator(IndicatorItem.success("Successfully added users"));
        print("Successfully added list of team users");
        completion();
      } else {
        print(response);
        print("There was an issue adding the list of season users");
        addIndicator(IndicatorItem.error("There was an issue adding users"));
        onError != null ? onError() : null;
      }
    });
  }

  Future<void> deleteSeasonUser(String teamId, String seasonId, String email,
      VoidCallback completion) async {
    // first create the season
    await client
        .delete("/teams/$teamId/seasons/$seasonId/users/$email/delete")
        .then((response) {
      if (response == null) {
        addIndicator(
            IndicatorItem.error("There was an issue removing this user"));
      } else if (response['status'] == 200) {
        print(response);
        addIndicator(IndicatorItem.success("Successfully removed user"));
        completion();
      } else {
        print(response);
        addIndicator(
            IndicatorItem.error("There was an issue removing this user"));
      }
    });
  }

  Future<void> deleteSeason(
      String teamId, String seasonId, VoidCallback completion,
      {VoidCallback? onError}) async {
    await client
        .delete("/teams/$teamId/seasons/$seasonId/delete")
        .then((response) {
      if (response == null) {
        addIndicator(
            IndicatorItem.error("There was an issue deleting this season"));
      } else if (response['status'] == 200) {
        print(response);
        addIndicator(IndicatorItem.success("Successfully deleted season"));
        completion();
      } else {
        print(response);
        addIndicator(
            IndicatorItem.error("There was an issue deleting this season"));
      }
    });
  }

  Future<void> getAllSeasons(String teamId, Function(List<Season>) completion,
      {VoidCallback? onError}) async {
    await client.fetch("/teams/$teamId/seasons").then((response) {
      if (response == null) {
        addIndicator(
            IndicatorItem.error("There was an issue getting all seasons"));
      } else if (response['status'] == 200) {
        log("Successfully got all seasons");
        List<Season> seasons = [];
        for (var i in response['body']) {
          seasons.add(Season.fromJson(i));
        }
        completion(seasons);
      } else {
        print(response);
        addIndicator(
            IndicatorItem.error("There was an issue getting all seasons"));
      }
    });
  }

  Future<void> getAuthenticatedSeasons(
      String teamId, String email, Function(List<Season>) completion,
      {VoidCallback? onError}) async {
    await client
        .fetch("/teams/$teamId/authenticatedSeasons/$email")
        .then((response) {
      if (response == null) {
        addIndicator(
            IndicatorItem.error("There was an issue getting the seasons"));
      } else if (response['status'] == 200) {
        log("Successfully got auth seasons");
        List<Season> seasons = [];
        for (var i in response['body']) {
          seasons.add(Season.fromJson(i));
        }
        completion(seasons);
      } else {
        print(response);
        addIndicator(
            IndicatorItem.error("There was an issue getting the seasons"));
      }
    });
  }

  Future<void> uploadCalendar(
    String teamId,
    String seasonId,
    String calendarText,
    VoidCallback completion, {
    VoidCallback? onError,
  }) async {
    Map<String, String> headers = {'Content-Type': 'application/json'};

    Map<String, dynamic> body = {"calendarText": calendarText};

    // first create the season
    await client
        .post("/teams/$teamId/seasons/$seasonId/uploadCalendar", headers,
            jsonEncode(body))
        .then((response) {
      if (response == null) {
        print("There was an issue uploading the calendar");
        addIndicator(
            IndicatorItem.error("There was an issue uploading the calendar"));
        onError != null ? onError() : null;
      } else if (response['status'] == 200) {
        completion();
      } else {
        print("There was an issue uploading the calendar");
        addIndicator(
            IndicatorItem.error("There was an issue uploading the calendar"));
        onError != null ? onError() : null;
      }
    });
  }

  Future<void> loadCalendar(
    String teamId,
    String seasonId,
    Map<String, dynamic> body,
    Function(List<Event>) completion, {
    VoidCallback? onError,
  }) async {
    Map<String, String> headers = {'Content-Type': 'application/json'};

    // first create the season
    await client
        .post("/teams/$teamId/seasons/$seasonId/loadCalendar", headers,
            jsonEncode(body))
        .then((response) {
      if (response == null) {
        print("There was an issue verifying the calendar");
        onError != null ? onError() : null;
      } else if (response['status'] == 200) {
        print("successfully verified calendar");
        List<Event> e = [];
        for (var i in response['body']) {
          e.add(Event.fromJson(i));
        }
        completion(e);
      } else {
        if (response['status'] == 410) {
          print("The calendar is invalid");
          addIndicator(IndicatorItem.error("The calendar is invalid"));
        } else {
          // TODO: Add feedback form here
          print("There was an unknown error processing this request");
          addIndicator(IndicatorItem.error(
              "There was an unknown error processing this request"));
        }
        onError != null ? onError() : null;
      }
    });
  }

  Future<void> syncCalendar(
      String teamId, String seasonId, VoidCallback completion,
      {VoidCallback? onError}) async {
    await client
        .fetch("/teams/$teamId/seasons/$seasonId/syncCalendar")
        .then((response) {
      if (response == null) {
        addIndicator(
            IndicatorItem.error("There was an issue syncing the calendar"));
      } else if (response['status'] == 200) {
        log("Successfully synced calendar");
        completion();
      } else {
        print(response);
        addIndicator(
            IndicatorItem.error("There was an issue syncing the calendar"));
      }
    });
  }

  Future<void> uploadRosterExcel(
    String teamId,
    String seasonId,
    List<SUExcel> users,
    VoidCallback completion, {
    VoidCallback? onError,
  }) async {
    Map<String, String> headers = {'Content-Type': 'application/json'};
    Map<String, dynamic> body = {};
    body['excelUsers'] = users.map((e) => e.toMap()).toList();
    body['date'] = dateToString(DateTime.now());

    // first create the season
    await client
        .post("/teams/$teamId/seasons/$seasonId/addRosterExcel", headers,
            jsonEncode(body))
        .then((response) {
      if (response == null) {
        print(
            "There was an unknown issue adding the users from the excel sheet. Feel free to contact support.");
        addIndicator(IndicatorItem.error(
            "There was an unknown issue adding the users from the excel sheet. Feel free to contact support."));
        onError != null ? onError() : null;
      } else if (response['status'] == 200) {
        print("Successfully created the users from the excel sheet.");
        addIndicator(IndicatorItem.status(
            "Successfully created the users from the excel sheet."));
        completion();
      } else {
        print(response);
        addIndicator(IndicatorItem.error(
            "There was an unknown issue adding the users from the excel sheet. Feel free to contact support."));
        onError != null ? onError() : null;
      }
    });
  }
}

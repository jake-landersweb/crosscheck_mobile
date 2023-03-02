// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:developer';

import 'package:crosscheck_sports/client/root.dart';
import 'package:crosscheck_sports/data/indicator_item.dart';
import 'package:crosscheck_sports/data/root.dart';
import 'package:crosscheck_sports/data/season/poll.dart';
import 'package:crosscheck_sports/extras/global_funcs.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';

extension PollCalls on DataModel {
  Future<void> getFuturePolls(String teamId, String seasonId, String email,
      Function(List<Poll>) completion,
      {VoidCallback? onError}) async {
    Map<String, String> headers = {'Content-Type': 'application/json'};

    Map<String, String> body = {
      "date": dateToString(DateTime.now()),
      "email": email,
    };

    await client
        .put(
            "/teams/$teamId/seasons/$seasonId/polls", headers, jsonEncode(body))
        .then((response) {
      if (response == null) {
        addIndicator(
            IndicatorItem.error("There was an issue fetching the polls"));
        onError != null ? onError() : null;
      } else if (response['status'] == 200) {
        log("successfully found polls");
        List<Poll> polls = [];
        for (var i in response['body']) {
          polls.add(Poll.fromJson(i));
        }
        completion(polls);
      } else {
        addIndicator(
            IndicatorItem.error("There was an issue fetching the polls"));
        onError != null ? onError() : null;
      }
    });
  }

  Future<void> updatePollStatus(String teamId, String seasonId, String sortKey,
      String email, List<String> selections, VoidCallback completion,
      {VoidCallback? onError}) async {
    Map<String, String> headers = {'Content-Type': 'application/json'};

    Map<String, dynamic> body = {
      "selections": selections,
    };

    await client
        .put(
            "/teams/$teamId/seasons/$seasonId/polls/$sortKey/users/$email/update",
            headers,
            jsonEncode(body))
        .then((response) async {
      if (response == null) {
        addIndicator(
            IndicatorItem.error("There was an issue recording your response"));
        onError != null ? onError() : null;
      } else if (response['status'] == 200) {
        await FirebaseAnalytics.instance.logEvent(
          name: "poll_checkin",
          parameters: {"platform": "mobile"},
        );
        addIndicator(IndicatorItem.success("Successfully recorded response"));
        completion();
      } else {
        addIndicator(
            IndicatorItem.error("There was an issue recording your response"));
        onError != null ? onError() : null;
      }
    });
  }

  Future<void> getPollUsers(String teamId, String seasonId, String sortKey,
      Function(List<SeasonUser>) completion,
      {VoidCallback? onError}) async {
    await client
        .fetch("/teams/$teamId/seasons/$seasonId/polls/$sortKey/users")
        .then((response) {
      if (response == null) {
        addIndicator(IndicatorItem.error(
            "There was an issue getting the poll responses"));
        onError != null ? onError() : null;
      } else if (response['status'] == 200) {
        print("successfully got poll users");
        List<SeasonUser> users = [];
        for (var i in response['body']) {
          users.add(SeasonUser.fromJson(i));
        }
        completion(users);
      } else {
        addIndicator(IndicatorItem.error(
            "There was an issue getting the poll responses"));
        onError != null ? onError() : null;
      }
    });
  }

  Future<void> getPollUser(String teamId, String seasonId, String sortKey,
      String email, Function(SUPollFields) completion,
      {VoidCallback? onError}) async {
    await client
        .fetch("/teams/$teamId/seasons/$seasonId/polls/$sortKey/users/$email")
        .then((response) {
      if (response == null) {
        addIndicator(IndicatorItem.error(
            "There was an issue getting the user response"));
        onError != null ? onError() : null;
      } else if (response['status'] == 200) {
        print("successfully got poll user");
        completion(SUPollFields.fromJson(response['body']));
      } else {
        addIndicator(IndicatorItem.error(
            "There was an issue getting the user response"));
        onError != null ? onError() : null;
      }
    });
  }

  Future<void> createPoll(String teamId, String seasonId,
      Map<String, dynamic> body, VoidCallback completion,
      {VoidCallback? onError}) async {
    Map<String, String> headers = {'Content-Type': 'application/json'};
    await client
        .post("/teams/$teamId/seasons/$seasonId/createPoll", headers,
            jsonEncode(body))
        .then((response) async {
      if (response == null) {
        addIndicator(
            IndicatorItem.error("There was an issue creating the poll"));
        onError != null ? onError() : null;
      } else if (response['status'] == 200) {
        await FirebaseAnalytics.instance.logEvent(
          name: "create_poll",
          parameters: {"platform": "mobile"},
        );
        addIndicator(IndicatorItem.success("Successfully created the poll"));
        completion();
      } else {
        addIndicator(
            IndicatorItem.error("There was an issue creating the poll"));
        onError != null ? onError() : null;
      }
    });
  }

  Future<void> updatePoll(String teamId, String seasonId, String sortKey,
      Map<String, dynamic> body, VoidCallback completion,
      {VoidCallback? onError}) async {
    Map<String, String> headers = {'Content-Type': 'application/json'};
    await client
        .put("/teams/$teamId/seasons/$seasonId/polls/$sortKey/update", headers,
            jsonEncode(body))
        .then((response) {
      if (response == null) {
        addIndicator(
            IndicatorItem.error("There was an issue updaing the poll"));
        onError != null ? onError() : null;
      } else if (response['status'] == 200) {
        addIndicator(IndicatorItem.success("Successfully updaing the poll"));
        completion();
      } else {
        addIndicator(
            IndicatorItem.error("There was an issue updaing the poll"));
        onError != null ? onError() : null;
      }
    });
  }

  Future<void> deletePoll(
      String teamId, String seasonId, String sortKey, VoidCallback completion,
      {VoidCallback? onError}) async {
    await client
        .delete("/teams/$teamId/seasons/$seasonId/polls/$sortKey/delete")
        .then((response) {
      if (response == null) {
        addIndicator(
            IndicatorItem.error("There was an issue deleting the poll"));
        onError != null ? onError() : null;
      } else if (response['status'] == 200) {
        addIndicator(IndicatorItem.success("Successfully deleted the poll"));
        completion();
      } else {
        addIndicator(
            IndicatorItem.error("There was an issue deleting the poll"));
        onError != null ? onError() : null;
      }
    });
  }

  Future<void> getAllPolls(String teamId, String seasonId, String email,
      Function(List<Poll>) completion,
      {VoidCallback? onError}) async {
    Map<String, String> headers = {'Content-Type': 'application/json'};

    Map<String, String> body = {
      "email": email,
    };
    await client
        .put(
      "/teams/$teamId/seasons/$seasonId/polls",
      headers,
      jsonEncode(body),
    )
        .then((response) {
      if (response == null) {
        addIndicator(
            IndicatorItem.error("There was an issue getting the polls"));
        onError != null ? onError() : null;
      } else if (response['status'] == 200) {
        print("sucessfuly fetched the polls");
        List<Poll> polls = [];
        for (var i in response['body']) {
          polls.add(Poll.fromJson(i));
        }
        completion(polls);
      } else {
        addIndicator(
            IndicatorItem.error("There was an issue getting the polls"));
        onError != null ? onError() : null;
      }
    });
  }

  Future<void> sendPollReminder(
      String teamId, String seasonId, String sortKey, VoidCallback completion,
      {VoidCallback? onError}) async {
    await client
        .fetch("/teams/$teamId/seasons/$seasonId/polls/$sortKey/sendReminder")
        .then((response) {
      if (response == null) {
        addIndicator(IndicatorItem.error(
            "There was an issue sending the poll reminder. Our team will be looking into this shortly"));
        onError != null ? onError() : null;
      } else if (response['status'] == 200) {
        print("successfully sent poll notification");
        addIndicator(IndicatorItem.success(
            "The notification will be sent out shortly."));
        completion();
      } else {
        addIndicator(IndicatorItem.error(
            "There was an issue sending the poll reminder. Our team will be looking into this shortly"));
        onError != null ? onError() : null;
      }
    });
  }

  Future<String?> getMessagePresignedUrl(String filename) async {
    var response = await client.fetch("/getPresignedUrl/$filename");
    if (response == null) {
      log("there was a fatal issue getting the presigned url");
      return null;
    } else if (response['status'] != 200) {
      print("There was an error getting the presigned url");
      print(response);
      return null;
    } else {
      print("successfully got presigned url");
      return response['body'];
    }
  }

  Future<void> getUnansweredPollCount(
      String teamId, String seasonId, String email, Function(int) completion,
      {VoidCallback? onError}) async {
    Map<String, String> headers = {'Content-Type': 'application/json'};

    Map<String, String> body = {
      "date": dateToString(DateTime.now()),
      "email": email,
    };

    await client
        .put(
      "/teams/$teamId/seasons/$seasonId/unansweredPolls",
      headers,
      jsonEncode(body),
    )
        .then((response) {
      if (response == null) {
        debugPrint("There was an issue getting the unaswered polls");
        onError != null ? onError() : null;
      } else if (response['status'] == 200) {
        debugPrint("successfully got the unaswered polls");
        completion(response['body']['count']);
      } else {
        debugPrint("There was an issue getting the unaswered polls");
        onError != null ? onError() : null;
      }
    });
  }
}

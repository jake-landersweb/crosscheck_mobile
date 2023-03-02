// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';

import 'root.dart';
import '../data/root.dart';
import '../extras/root.dart';

extension EventCalls on DataModel {
  // Future<void> scheduleGet(String teamId, String seasonId, String email,
  //     Function(Schedule) completion,
  //     {bool? showLoads}) async {
  //   isLoadingSchedule = true;

  //   print("Fetching Schedule");

  //   Map<String, dynamic> body = {
  //     'email': email.toLowerCase(),
  //     "date": dateToString(DateTime.now()),
  //   };

  //   Map<String, String> headers = {'Content-Type': 'application/json'};

  //   var response = await client.put(
  //       "/teams/$teamId/seasons/$seasonId/eventsSorted",
  //       headers,
  //       jsonEncode(body));

  //   if (response == null) {
  //     addIndicator(IndicatorItem.error("There was an issue getting the schedule", true);
  //   } else if (response['status'] == 200) {
  //     addIndicator(IndicatorItem.success("Successfully fetched current schedule", false);
  //     completion(Schedule.fromjson(response['body']));
  //   } else {
  //     addIndicator(IndicatorItem.error("There was an issue getting the schedule", true);
  //     print(response['message']);
  //   }
  // }

  void getUserStatus(String teamId, String seasonId, String eventId,
      String email, Function(SeasonUserEventFields) completion) async {
    final response = await client
        .fetch("/teams/$teamId/seasons/$seasonId/events/$eventId/users/$email");

    if (response == null) {
      addIndicator(
          IndicatorItem.error("There was an issue getting your status"));
    } else if (response['status'] == 200) {
      print("Successfully got user status");
      completion(SeasonUserEventFields.fromJson(response['body']));
    } else {
      print(response['message']);
      addIndicator(
          IndicatorItem.error("There was an issue getting your status"));
    }
  }

  Future<void> updateUserStatus(String teamId, String seasonId, String eventId,
      String email, Map<String, dynamic> body, VoidCallback completion) async {
    Map<String, String> headers = {'Content-Type': 'application/json'};

    final response = await client.put(
        "/teams/$teamId/seasons/$seasonId/events/$eventId/users/$email/checkin",
        headers,
        jsonEncode(body));

    if (response == null) {
      addIndicator(
          IndicatorItem.error("There was an issue updating your status"));
    } else if (response['status'] == 200) {
      addIndicator(IndicatorItem.success("Succesfully updated your status"));
      completion();
    } else {
      print(response['message']);
      addIndicator(
          IndicatorItem.error("There was an issue updating your status"));
    }
  }

  Future<void> getEventUsers(String teamId, String seasonId, String eventId,
      Function(List<SeasonUserEventFields>) completion) async {
    await client
        .fetch("/teams/$teamId/seasons/$seasonId/events/$eventId/usersRaw")
        .then((response) {
      if (response == null) {
        addIndicator(
            IndicatorItem.error("There was an issue getting the users"));
      } else if (response['status'] == 200) {
        List<SeasonUserEventFields> users = [];
        for (var i in response['body']) {
          users.add(SeasonUserEventFields.fromJson(i));
        }
        completion(users);
      } else {
        addIndicator(
            IndicatorItem.error("There was an issue getting the users"));
        print(response['message']);
      }
    });
  }

  Future<void> replyToStatus(
    String teamId,
    String seasonId,
    String eventId,
    Map<String, dynamic> body,
    VoidCallback completion,
  ) async {
    Map<String, String> headers = {'Content-Type': 'application/json'};

    await client
        .put("/teams/$teamId/seasons/$seasonId/events/$eventId/replyToStatus",
            headers, jsonEncode(body))
        .then((response) async {
      if (response == null) {
        addIndicator(
            IndicatorItem.error("There was an issue replying to this user"));
      } else if (response['status'] == 200) {
        await FirebaseAnalytics.instance.logEvent(
          name: "status_reply",
          parameters: {"platform": "mobile"},
        );
        addIndicator(IndicatorItem.success("Successfully posted reply"));
        completion();
      } else {
        addIndicator(
            IndicatorItem.error("There was an issue replying to this user"));
        print(response['message']);
      }
    });
  }

  Future<void> createEvent(String teamId, String seasonId,
      Map<String, dynamic> body, VoidCallback completion) async {
    Map<String, String> headers = {'Content-Type': 'application/json'};

    await client
        .post("/teams/$teamId/seasons/$seasonId/createEvent", headers,
            jsonEncode(body))
        .then((response) async {
      if (response == null) {
        addIndicator(
            IndicatorItem.error("There was an issue creating the event"));
      } else if (response['status'] == 200) {
        await FirebaseAnalytics.instance.logEvent(
          name: "create_event",
          parameters: {"platform": "mobile"},
        );
        addIndicator(IndicatorItem.success("Successfully created event"));
        completion();
      } else {
        addIndicator(
            IndicatorItem.error("There was an issue creating the eventr"));
        print(response['message']);
      }
    });
  }

  Future<void> updateEvent(String teamId, String seasonId, String eventId,
      Map<String, dynamic> body, VoidCallback completion) async {
    Map<String, String> headers = {'Content-Type': 'application/json'};

    await client
        .put("/teams/$teamId/seasons/$seasonId/events/$eventId/update", headers,
            jsonEncode(body))
        .then((response) {
      if (response == null) {
        addIndicator(
            IndicatorItem.error("There was an issue updating the event"));
      } else if (response['status'] == 200) {
        print(response);
        addIndicator(IndicatorItem.success("Successfully updated event"));
        completion();
      } else {
        addIndicator(
            IndicatorItem.error("There was an issue updating the event"));
        print(response['message']);
      }
    });
  }

  Future<void> getPagedEventsHelper(
      String teamId,
      String seasonId,
      String email,
      int startIndex,
      bool isPrevious,
      Function(List<Event>) completion) async {
    print("Getting paged events");
    Map<String, String> headers = {'Content-Type': 'application/json'};

    Map<String, dynamic> body = {
      "email": email,
      "date": dateToString(DateTime.now()),
      "startIndex": startIndex,
      "isPrevious": isPrevious,
      "pageSize": 5,
    };

    await client
        .put("/teams/$teamId/seasons/$seasonId/pagedEvents", headers,
            jsonEncode(body))
        .then((response) async {
      if (response == null) {
        addIndicator(
            IndicatorItem.error("There was an issue fetching the events"));
      } else if (response['status'] == 200) {
        print("Successfully fetched events");
        List<Event> list = [];
        for (var i in response['body']['events']) {
          list.add(Event.fromJson(i));
        }
        if (isPrevious) {
          await FirebaseAnalytics.instance.logEvent(
            name: "previous_events",
            parameters: {"platform": "mobile"},
          );
          hasMorePreviousEvents = response['body']['hasMoreResults'];
          previousEventsStartIndex = response['body']['lastIndex'];
        } else {
          hasMoreUpcomingEvents = response['body']['hasMoreResults'];
          upcomingEventsStartIndex = response['body']['lastIndex'];
        }
        completion(list);
      } else {
        print("There was an issue fetching the events");
        print(response['message']);
      }
    });
  }

  Future<void> updateEventUser(String teamId, String seasonId, String eventId,
      String email, Map<String, dynamic> body, VoidCallback completion) async {
    Map<String, String> headers = {'Content-Type': 'application/json'};

    await client
        .put(
            "/teams/$teamId/seasons/$seasonId/events/$eventId/users/$email/update",
            headers,
            jsonEncode(body))
        .then((response) async {
      if (response == null) {
        await FirebaseAnalytics.instance.logEvent(
          name: "check_in",
          parameters: {"platform": "mobile"},
        );
        addIndicator(
            IndicatorItem.error("There was an issue updating the event user"));
      } else if (response['status'] == 200) {
        print("Successfully updated event user");
        completion();
      } else {
        addIndicator(
            IndicatorItem.error("There was an issue updating the event user"));
        print(response['message']);
      }
    });
  }

  Future<void> deleteEvent(String teamId, String seasonId, String eventId,
      VoidCallback completion) async {
    await client
        .delete("/teams/$teamId/seasons/$seasonId/events/$eventId/delete")
        .then((response) {
      if (response == null) {
        addIndicator(
            IndicatorItem.error("There was an issue deleting the event"));
      } else if (response['status'] == 200) {
        addIndicator(IndicatorItem.success("Successfully deleted event"));
        completion();
      } else {
        addIndicator(
            IndicatorItem.error("There was an issue deleting the event"));
        print(response['message']);
      }
    });
  }

  Future<void> sendEventMessage(String teamId, String seasonId, String eventId,
      Map<String, dynamic> body, VoidCallback completion,
      {VoidCallback? onError}) async {
    Map<String, String> headers = {'Content-Type': 'application/json'};

    await client
        .post(
            "/teams/$teamId/seasons/$seasonId/events/$eventId/sendNotifications",
            headers,
            jsonEncode(body))
        .then((response) async {
      print(response);
      if (response == null) {
        addIndicator(
            IndicatorItem.error("There was an issue sending the notification"));
        onError == null ? null : onError();
      } else if (response['status'] == 200) {
        await FirebaseAnalytics.instance.logEvent(
          name: "event_reminder",
          parameters: {"platform": "mobile"},
        );
        addIndicator(
            IndicatorItem.success("Your notification will send out shortly."));
        completion();
      } else {
        addIndicator(
            IndicatorItem.error("There was an issue sending the notification"));
        print(response['message']);
        onError == null ? null : onError();
      }
    });
  }

  Future<void> getFutureEvents(String teamId, String seasonId,
      void Function(List<Event>) completion, VoidCallback onError) async {
    Map<String, String> headers = {'Content-Type': 'application/json'};

    Map<String, dynamic> body = {"date": dateToString(DateTime.now())};

    var response = await client.put(
      "/teams/$teamId/seasons/$seasonId/futureEvents",
      headers,
      jsonEncode(body),
    );

    if (response == null) {
      debugPrint("There was an issue getting the future events");
      onError();
    } else if (response['status'] == 200) {
      debugPrint("Successfully got future events");
      List<Event> events = [];
      for (var i in response['body']) {
        events.add(Event.fromJson(i));
      }
      completion(events);
    } else {
      debugPrint("There was an issue getting the future events");
      print(response);
      onError();
    }
  }
}

// ignore_for_file: avoid_print

import 'dart:convert';

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
  //     setError("There was an issue getting the schedule", true);
  //   } else if (response['status'] == 200) {
  //     setSuccess("Successfully fetched current schedule", false);
  //     completion(Schedule.fromjson(response['body']));
  //   } else {
  //     setError("There was an issue getting the schedule", true);
  //     print(response['message']);
  //   }
  // }

  void getUserStatus(String teamId, String seasonId, String eventId,
      String email, Function(SeasonUserEventFields) completion) async {
    final response = await client
        .fetch("/teams/$teamId/seasons/$seasonId/events/$eventId/users/$email");

    if (response == null) {
      setError("There was an issue getting your status", true);
    } else if (response['status'] == 200) {
      setSuccess("Successfully got user status", false);
      completion(SeasonUserEventFields.fromJson(response['body']));
    } else {
      print(response['message']);
      setError("There was an issue getting your status", true);
    }
  }

  Future<void> updateUserStatus(String teamId, String seasonId, String eventId,
      String email, Map<String, dynamic> body, VoidCallback completion) async {
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
      String title,
      VoidCallback completion) async {
    Map<String, dynamic> body = {
      'date': dateToString(DateTime.now()),
      "name": name,
      "message": message,
      "email": email,
      "title": title,
    };

    Map<String, String> headers = {'Content-Type': 'application/json'};

    await client
        .put("/teams/$teamId/seasons/$seasonId/events/$eventId/replyToStatus",
            headers, jsonEncode(body))
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

  Future<void> createEvent(String teamId, String seasonId,
      Map<String, dynamic> body, VoidCallback completion) async {
    Map<String, String> headers = {'Content-Type': 'application/json'};

    await client
        .post("/teams/$teamId/seasons/$seasonId/createEvent", headers,
            jsonEncode(body))
        .then((response) {
      if (response == null) {
        setError("There was an issue creating the event", true);
      } else if (response['status'] == 200) {
        setSuccess("Successfully created event", true);
        completion();
      } else {
        setError("There was an issue creating the eventr", true);
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
        setError("There was an issue updating the event", true);
      } else if (response['status'] == 200) {
        print(response);
        setSuccess("Successfully updated event", true);
        completion();
      } else {
        setError("There was an issue updating the event", true);
        print(response['message']);
      }
    });
  }

  Future<void> getNextEvents(String teamId, String seasonId, String email,
      bool fromIndex, Function(List<Event>) completion) async {
    Map<String, String> headers = {'Content-Type': 'application/json'};

    print(fromIndex
        ? "Getting upcoming events from index"
        : "Getting upcoming events until index");

    Map<String, dynamic> body = {
      "email": email,
      "date": dateToString(DateTime.now()),
      "fromIndex": fromIndex,
    };

    await client
        .put("/teams/$teamId/seasons/$seasonId/nextEvents", headers,
            jsonEncode(body))
        .then((response) {
      if (response == null) {
        setError("There was an issue fetching the events", true);
      } else if (response['status'] == 200) {
        setSuccess("Successfully fetched events", false);
        List<Event> list = [];
        for (var i in response['body']) {
          list.add(Event.fromJson(i));
        }
        completion(list);
      } else {
        setError("Successfully fetched events", false);
        print(response['message']);
      }
    });
  }

  Future<void> getPreviousEvents(String teamId, String seasonId, String email,
      Function(List<Event>) completion) async {
    Map<String, String> headers = {'Content-Type': 'application/json'};

    print("getting previous events ...");

    Map<String, dynamic> body = {
      "email": email,
      "date": dateToString(DateTime.now())
    };

    await client
        .put("/teams/$teamId/seasons/$seasonId/previousEvents", headers,
            jsonEncode(body))
        .then((response) {
      if (response == null) {
        setError("There was an issue fetching the events", true);
      } else if (response['status'] == 200) {
        setSuccess("Successfully fetched events", false);
        List<Event> list = [];
        for (var i in response['body']) {
          list.add(Event.fromJson(i));
        }
        completion(list);
      } else {
        setError("Successfully fetched events", false);
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
        .then((response) {
      if (response == null) {
        setError("There was an issue fetching the events", true);
      } else if (response['status'] == 200) {
        setSuccess("Successfully fetched events", false);
        List<Event> list = [];
        for (var i in response['body']['events']) {
          list.add(Event.fromJson(i));
        }
        if (isPrevious) {
          hasMorePreviousEvents = response['body']['hasMoreResults'];
          previousEventsStartIndex = response['body']['lastIndex'];
          print(previousEventsStartIndex);
          print(list.length);
        } else {
          hasMoreUpcomingEvents = response['body']['hasMoreResults'];
          upcomingEventsStartIndex = response['body']['lastIndex'];
        }
        completion(list);
      } else {
        setError("Successfully fetched events", false);
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
        .then((response) {
      if (response == null) {
        setError("There was an issue updating the event user", true);
      } else if (response['status'] == 200) {
        setSuccess("Successfully updated event user", false);
        completion();
      } else {
        setError("There was an issue updating the event user", true);
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
        setError("There was an issue deleting the event", true);
      } else if (response['status'] == 200) {
        setSuccess("Successfully deleted event", true);
        completion();
      } else {
        setError("There was an issue deleting the event", true);
        print(response['message']);
      }
    });
  }
}

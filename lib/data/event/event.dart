import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';
import 'package:pnflutter/data/event/event_location.dart';
import 'package:pnflutter/data/root.dart';
import 'root.dart';
import '../../extras/root.dart';
import 'package:flutter/material.dart';

class Event extends Equatable {
  late String eDescription;
  late String eventId;
  late String eTitle;
  late String eLocation;
  late bool hasAttendance;
  late String teamId;
  late String seasonId;
  EventTeam? homeTeam;
  EventTeam? awayTeam;
  late String eDate;
  late String eLink;
  late int inCount;
  late int outCount;
  late int undecidedCount;
  late int noResponse;
  int? userStatus;
  late EventLocation eventLocation;
  late bool showAttendance;
  late int eventType;
  late List<CustomField> customFields;
  late List<CustomField> customUserFields;
  late String eventColor;

  Event({
    required this.eDescription,
    required this.eventId,
    required this.eTitle,
    required this.eLocation,
    required this.hasAttendance,
    required this.teamId,
    required this.seasonId,
    this.homeTeam,
    this.awayTeam,
    required this.eDate,
    required this.eLink,
    required this.inCount,
    required this.outCount,
    required this.undecidedCount,
    required this.noResponse,
    this.userStatus,
    required this.eventLocation,
    required this.showAttendance,
    required this.eventType,
    required this.customFields,
    required this.customUserFields,
    required this.eventColor,
  });

  // empty object
  Event.empty() {
    eDescription = "";
    eventId = "";
    eTitle = "";
    eLocation = "";
    hasAttendance = true;
    teamId = "";
    seasonId = "";
    homeTeam = EventTeam.empty();
    eDate = dateToString(DateTime.now());
    eLink = "";
    awayTeam = EventTeam.empty();
    inCount = 0;
    outCount = 0;
    undecidedCount = 0;
    noResponse = 0;
    userStatus = 0;
    eventLocation = EventLocation.empty();
    showAttendance = true;
    eventType = 0;
    customFields = [];
    customUserFields = [];
    eventColor = "";
  }

  // for creating a copy
  Event.of(Event event) {
    eDescription = event.eDescription;
    eventId = event.eventId;
    eTitle = event.eTitle;
    eLocation = event.eLocation;
    hasAttendance = event.hasAttendance;
    teamId = event.teamId;
    seasonId = event.seasonId;
    if (event.homeTeam != null) {
      homeTeam = EventTeam.of(event.homeTeam!);
    }
    eDate = event.eDate;
    eLink = event.eLink;
    if (event.awayTeam != null) {
      awayTeam = EventTeam.of(event.awayTeam!);
    }
    inCount = event.inCount;
    outCount = event.outCount;
    undecidedCount = event.undecidedCount;
    noResponse = event.noResponse;
    userStatus = event.userStatus;
    eventLocation = event.eventLocation;
    showAttendance = event.showAttendance;
    eventType = event.eventType;
    customFields = [for (var i in event.customFields) i.clone()];
    customUserFields = [for (var i in event.customUserFields) i.clone()];
    eventColor = event.eventColor;
  }

  Event clone() => Event(
        eDescription: eDescription,
        eventId: eventId,
        eTitle: eTitle,
        eLocation: eLocation,
        hasAttendance: hasAttendance,
        teamId: teamId,
        seasonId: seasonId,
        eDate: eDate,
        eLink: eLink,
        inCount: inCount,
        outCount: outCount,
        homeTeam: homeTeam?.clone(),
        awayTeam: awayTeam?.clone(),
        undecidedCount: undecidedCount,
        noResponse: noResponse,
        eventLocation: eventLocation.clone(),
        showAttendance: showAttendance,
        eventType: eventType,
        customFields: [for (var i in customFields) i.clone()],
        customUserFields: [for (var i in customUserFields) i.clone()],
        eventColor: eventColor,
      );

  // Event.fromRaw(EventRaw event) {
  //   eDescription = event.eDescription;
  //   eventId = event.eventId;
  //   eTitle = event.eTitle;
  //   eLocation = event.eLocation;
  //   hasAttendance = event.hasAttendance;
  //   teamId = event.teamId;
  //   seasonId = event.seasonId;
  //   if (event.homeTeam != null) {
  //     homeTeam = EventTeam.of(event.homeTeam!);
  //   }
  //   eDate = event.eDate;
  //   eLink = event.eLink;
  //   if (event.awayTeam != null) {
  //     awayTeam = EventTeam.of(event.awayTeam!);
  //   }
  //   inCount = 0;
  //   outCount = 0;
  //   undecidedCount = 0;
  //   noResponse = 0;
  //   userStatus = 0;
  //   eventLocation = event.eventLocation;
  //   showAttendance = event.showAttendance;
  //   eventType = event.eventType;
  // }

  // object from json
  Event.fromJson(Map<String, dynamic> json) {
    eDescription = json['eDescription'] ?? "";
    eventId = json['eventId'];
    eTitle = json['eTitle'];
    eLocation = json['eLocation'] ?? "";
    hasAttendance = json['hasAttendance'] ?? false;
    teamId = json['teamId'] ?? "";
    seasonId = json['seasonId'] ?? "";
    homeTeam =
        json['homeTeam'] != null ? EventTeam.fromJson(json['homeTeam']) : null;
    eDate = json['eDate'];
    eLink = json['eLink'];
    awayTeam =
        json['awayTeam'] != null ? EventTeam.fromJson(json['awayTeam']) : null;
    inCount = json['inCount'];
    outCount = json['outCount'];
    undecidedCount = json['undecidedCount'];
    noResponse = json['noResponse'];
    userStatus = json['userStatus']?.round();
    if (json['eventLocation'] != null) {
      eventLocation = EventLocation.fromJson(json['eventLocation']);
    }
    showAttendance = json['showAttendance'];
    eventType = json['eventType']?.round() ?? 0;
    customFields = [];
    if (json['customFields'] != null) {
      json['customFields']
          .forEach((v) => customFields.add(CustomField.fromJson(v)));
    }
    customUserFields = [];
    if (json['customUserFields'] != null) {
      json['customUserFields']
          .forEach((v) => customUserFields.add(CustomField.fromJson(v)));
    }
    eventColor = json['eventColor'] ?? "";
  }

  // object to json
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['eDescription'] = eDescription;
    data['eventId'] = eventId;
    data['eTitle'] = eTitle;
    data['eLocation'] = eLocation;
    data['hasAttendance'] = hasAttendance;
    data['teamId'] = teamId;
    data['seasonId'] = seasonId;
    if (homeTeam != null) {
      data['homeTeam'] = homeTeam!.toJson();
    }
    data['eDate'] = dateToString(eventDate());
    data['eLink'] = eLink;
    if (awayTeam != null) {
      data['awayTeam'] = awayTeam!.toJson();
    }
    data['eventLocation'] = eventLocation.toJson();
    data['showAttendance'] = showAttendance;
    data['eventType'] = eventType;
    data['customFields'] = customFields.map((e) => e.toJson()).toList();
    data['eventColor'] = eventColor;
    return data;
  }

  // for painting correct title
  String getTitle() {
    if (eventType == 1) {
      if (homeTeam != null && awayTeam != null) {
        return "${homeTeam!.title} vs ${awayTeam!.title}";
      } else {
        return eTitle;
      }
    } else {
      return eTitle;
    }
  }

  String getOpponentTitle(String teamId) {
    if (eventType == 1) {
      if (teamId == homeTeam!.teamId) {
        return awayTeam!.title;
      } else {
        return homeTeam!.title;
      }
    } else {
      return "";
    }
  }

  String getDate() {
    DateTime date = DateTime.parse(eDate);
    DateFormat format = DateFormat('E, MMM dd');
    return format.format(date);
  }

  String getTime() {
    DateTime date = DateTime.parse(eDate);
    DateFormat format = DateFormat('hh:mm a');
    return format.format(date);
  }

  bool isHome() {
    if (eventType == 1) {
      if (teamId == homeTeam!.teamId) {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  DateTime eventDate() {
    return DateTime.parse(eDate);
  }

  String day() {
    return weekDayFromInt(eventDate().day);
  }

  String month() {
    return monthFromInt(eventDate().month);
  }

  bool isSameDayAs(DateTime date) {
    DateTime d1 = eventDate();
    if (d1.day == date.day && d1.month == date.month && d1.year == date.year) {
      return true;
    } else {
      return false;
    }
  }

  bool isSameMonthAs(DateTime date) {
    DateTime d1 = eventDate();
    if (d1.month == date.month && d1.year == date.year) {
      return true;
    } else {
      return false;
    }
  }

  bool isSameYearAs(DateTime date) {
    DateTime d1 = eventDate();
    if (d1.year == date.year) {
      return true;
    } else {
      return false;
    }
  }

  Color? getStatusColor(int userStatus) {
    switch (userStatus) {
      case -1:
        return Colors.red[300];
      case 1:
        return Colors.green[300];
      case 2:
        return Colors.amber[300];
    }
  }

  IconData getStatusIcon() {
    switch (userStatus) {
      case -1:
        return Icons.close;
      case 1:
        return Icons.done;
      case 2:
        return Icons.more_horiz;
      default:
        return Icons.horizontal_rule;
    }
  }

  Color? getColor() {
    try {
      return CustomColors.fromHex(eventColor);
    } catch (e) {
      // ignore
    }
  }

  // values to compare
  @override
  List<Object> get props => [eventId, eTitle, seasonId];
}

class EventTeam {
  late String title;
  int? score;
  String? teamId;

  EventTeam({
    required this.title,
    this.score,
    this.teamId,
  });

  EventTeam.empty() {
    title = "";
    score = 0;
    teamId = "";
  }

  EventTeam.of(EventTeam team) {
    title = team.title;
    score = team.score;
    teamId = team.teamId;
  }

  EventTeam clone() => EventTeam(title: title, score: score, teamId: teamId);

  EventTeam.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    score = json['score']?.round();
    teamId = json['teamId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['title'] = title;
    data['score'] = score;
    data['teamId'] = teamId;
    return data;
  }
}

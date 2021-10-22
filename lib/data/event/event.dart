import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';
import 'package:pnflutter/data/event/event_location.dart';
import 'root.dart';
import '../../extras/root.dart';

class Event extends Equatable {
  String? eDescription;
  late String eventId;
  late String eTitle;
  String? eLocation;
  late bool hasAttendance;
  String? teamId;
  late String seasonId;
  late int eType;
  EventTeam? homeTeam;
  late String eDate;
  String? eLink;
  EventTeam? awayTeam;
  late int inCount;
  late int outCount;
  late int undecidedCount;
  late int noResponse;
  int? userStatus;
  // new fields
  EventLocation? eventLocation;
  bool? showAttendance;
  late int eventType;

  Event({
    this.eDescription,
    required this.eventId,
    required this.eTitle,
    this.eLocation,
    required this.hasAttendance,
    required this.teamId,
    required this.seasonId,
    required this.eType,
    this.homeTeam,
    required this.eDate,
    this.eLink,
    this.awayTeam,
    required this.inCount,
    required this.outCount,
    required this.undecidedCount,
    required this.noResponse,
    this.userStatus,
    this.eventLocation,
    this.showAttendance,
    required this.eventType,
  });

  // empty object
  Event.empty() {
    eDescription = "";
    eventId = "";
    eTitle = "";
    eLocation = "";
    hasAttendance = false;
    teamId = "";
    seasonId = "";
    eType = 2;
    homeTeam = EventTeam.empty();
    eDate = "2021-06-15 12:00:00";
    eLink = "";
    awayTeam = EventTeam.empty();
    inCount = 0;
    outCount = 0;
    undecidedCount = 0;
    noResponse = 0;
    userStatus = 0;
    eventLocation = EventLocation();
    showAttendance = true;
    eventType = 0;
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
    eType = event.eType;
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
  }

  Event.fromRaw(EventRaw event) {
    eDescription = event.eDescription;
    eventId = event.eventId;
    eTitle = event.eTitle;
    eLocation = event.eLocation;
    hasAttendance = event.hasAttendance;
    teamId = event.teamId;
    seasonId = event.seasonId;
    eType = event.eType;
    if (event.homeTeam != null) {
      homeTeam = EventTeam.of(event.homeTeam!);
    }
    eDate = event.eDate;
    eLink = event.eLink;
    if (event.awayTeam != null) {
      awayTeam = EventTeam.of(event.awayTeam!);
    }
    inCount = 0;
    outCount = 0;
    undecidedCount = 0;
    noResponse = 0;
    userStatus = 0;
    eventLocation = event.eventLocation;
    showAttendance = event.showAttendance;
    eventType = event.eventType;
  }

  // object from json
  Event.fromJson(Map<String, dynamic> json) {
    eDescription = json['eDescription'];
    eventId = json['eventId'];
    eTitle = json['eTitle'];
    eLocation = json['eLocation'];
    hasAttendance = json['hasAttendance'];
    teamId = json['teamId'];
    seasonId = json['seasonId'];
    eType = json['eType']?.round();
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
    data['eType'] = eType;
    if (homeTeam != null) {
      data['homeTeam'] = homeTeam!.toJson();
    }
    data['eDate'] = dateToString(eventDate());
    data['eLink'] = eLink;
    if (awayTeam != null) {
      data['awayTeam'] = awayTeam!.toJson();
    }
    data['inCount'] = inCount;
    data['outCount'] = outCount;
    data['undecidedCount'] = undecidedCount;
    data['noResponse'] = noResponse;
    data['userStatus'] = userStatus;
    data['eventLocation'] = eventLocation?.toJson();
    data['showAttendance'] = showAttendance;
    data['eventType'] = eventType;
    return data;
  }

  // for painting correct title
  String getTitle() {
    if (eventType == 1) {
      return "${homeTeam!.title} vs ${awayTeam!.title}";
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
    if (eType == 1) {
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

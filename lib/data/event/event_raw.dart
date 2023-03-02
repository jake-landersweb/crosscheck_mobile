import 'package:equatable/equatable.dart';
import 'package:crosscheck_sports/data/event/event_location.dart';

import 'root.dart';

class EventRaw extends Equatable {
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
  String? color;
  // new fields
  EventLocation? eventLocation;
  bool? showAttendance;
  late int eventType;

  EventRaw({
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
    this.color,
    this.eventLocation,
    this.showAttendance,
    required this.eventType,
  });

  // empty object
  EventRaw.empty() {
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
    color = '';
    eventLocation = EventLocation();
    showAttendance = true;
    eventType = 0;
  }

  // for creating a copy
  EventRaw.of(EventRaw event) {
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
    color = event.color;
    eventLocation = event.eventLocation;
    showAttendance = event.showAttendance;
    eventType = event.eventType;
  }

  // object from json
  EventRaw.fromJson(Map<String, dynamic> json) {
    eDescription = json['eDescription'];
    eventId = json['eventId'];
    eTitle = json['eTitle'];
    eLocation = json['eLocation'];
    hasAttendance = json['hasAttendance'];
    teamId = json['teamId'];
    seasonId = json['seasonId'];
    eType = json['eType']?.round() ?? 0;
    homeTeam =
        json['homeTeam'] != null ? EventTeam.fromJson(json['homeTeam']) : null;
    eDate = json['eDate'];
    eLink = json['eLink'];
    awayTeam =
        json['awayTeam'] != null ? EventTeam.fromJson(json['awayTeam']) : null;
    color = json['color'];
    eventLocation = EventLocation.fromJson(json['eventLocation']);
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
    data['eDate'] = eDate;
    data['eLink'] = eLink;
    if (awayTeam != null) {
      data['awayTeam'] = awayTeam!.toJson();
    }
    data['color'] = color;
    data['eventLocation'] = eventLocation?.toJson();
    data['showAttendance'] = showAttendance;
    data['eventType'] = eventType;
    return data;
  }

  // for painting correct title
  String getTitle() {
    if (eType == 1) {
      return "${homeTeam!.title} vs ${awayTeam!.title}";
    } else {
      return eTitle;
    }
  }

  // title for the calendar
  String getShortTitle(String teamId) {
    if (eType == 1) {
      if (homeTeam!.teamId == teamId) {
        return "vs ${awayTeam!.title}";
      } else {
        return "vs ${homeTeam!.title}";
      }
    } else {
      return eTitle;
    }
  }

  // values to compare
  @override
  List<Object> get props => [eventId, eTitle, seasonId];
}

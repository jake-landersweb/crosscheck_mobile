import 'package:crosscheck_sports/extras/global_funcs.dart';
import 'package:crosscheck_sports/extras/root.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Poll {
  late String id;
  late String sortKey;
  late String pollId;
  late String teamId;
  late String seasonId;
  late String date;
  late int pollType;
  late String description;
  late List<String> choices;
  late String title;
  String? color;
  late List<String> userSelections;
  late bool userIsOn;
  late bool showResponses;
  late bool showResults;

  Poll({
    required this.id,
    required this.sortKey,
    required this.pollId,
    required this.teamId,
    required this.seasonId,
    required this.date,
    required this.pollType,
    required this.description,
    required this.choices,
    required this.title,
    this.color,
    required this.userSelections,
    required this.userIsOn,
    required this.showResponses,
    required this.showResults,
  });

  Poll.empty() {
    id = "";
    sortKey = "";
    pollId = "";
    teamId = "";
    seasonId = "";
    date = dateToString(DateTime.now());
    pollType = 1;
    description = "";
    choices = [];
    title = "";
    userSelections = [];
    userIsOn = false;
    showResponses = true;
    showResults = true;
  }

  Poll clone() => Poll(
        id: id,
        sortKey: sortKey,
        pollId: pollId,
        teamId: teamId,
        seasonId: seasonId,
        date: date,
        pollType: pollType,
        description: description,
        choices: choices,
        title: title,
        color: color,
        userSelections: userSelections,
        userIsOn: userIsOn,
        showResponses: showResponses,
        showResults: showResults,
      );

  Poll.fromJson(dynamic j) {
    id = j['id'];
    sortKey = j['sortKey'];
    pollId = j['pollId'];
    teamId = j['teamId'];
    seasonId = j['seasonId'];
    date = j['date'];
    pollType = j['pollType'].round();
    description = j['description'];
    choices = [];
    j['choices'].forEach((v) => choices.add(v));
    title = j['title'];
    color = j['color'] == "" ? null : j['color'];
    userSelections = [];
    if (j['userSelections'] != null) {
      j['userSelections'].forEach((v) => userSelections.add(v));
    }
    userIsOn = j['userIsOn'] ?? false;
    showResponses = j['showResponses'] ?? true;
    showResults = j['showResults'] ?? true;
  }

  Map<String, dynamic> toJson() {
    return {
      "date": date,
      "pollType": pollType,
      "description": description,
      "choices": choices,
      "title": title,
      "color": color,
      "showResponses": showResponses,
      "showResults": showResults,
    };
  }

  Color? getColor() {
    try {
      return CustomColors.fromHex(color ?? "");
    } catch (e) {
      // ignore
      return null;
    }
  }

  String getDate() {
    DateTime date = DateTime.parse(this.date);
    DateFormat format = DateFormat('E, MMM dd');
    return format.format(date);
  }

  DateTime getDateTime() {
    return DateTime.parse(date);
  }

  bool isFuture() {
    return getDateTime().isAfter(DateTime.now());
  }

  String getTime() {
    DateTime date = DateTime.parse(this.date);
    DateFormat format = DateFormat('hh:mm a');
    var d = format.format(date);
    if (d[0] == "0") {
      d = d.substring(1);
    }
    return d;
  }

  Color actionColor(BuildContext context) {
    if (userSelections.isEmpty) {
      return CustomColors.sheetCell(context);
    } else {
      return Colors.green[300]!;
    }
  }

  IconData actionIcon(BuildContext context) {
    if (userSelections.isEmpty) {
      return Icons.close;
    } else {
      return Icons.done;
    }
  }

  String getDescription() {
    if (description.length > 100) {
      return "${description.substring(0, 100)}...";
    } else {
      return description;
    }
  }

  int hourOffset() {
    DateTime date = stringToDate(this.date);
    return date.difference(DateTime.now()).inHours;
  }
}

import 'dart:io';

import 'package:crosscheck_sports/client/root.dart';
import 'package:crosscheck_sports/crosscheck_engine.dart';
import 'package:crosscheck_sports/data/root.dart';
import 'package:crosscheck_sports/extras/root.dart';
import 'package:crosscheck_sports/views/season/root.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:crosscheck_sports/custom_views/root.dart' as cv;
import 'package:flutter_switch/flutter_switch.dart';
import 'package:provider/provider.dart';
import 'package:crosscheck_sports/views/components/root.dart' as comp;
import 'dart:math' as math;

class SyncCalendar extends StatefulWidget {
  const SyncCalendar({
    super.key,
    required this.team,
    required this.season,
  });
  final Team team;
  final Season season;

  @override
  State<SyncCalendar> createState() => _SyncCalendarState();
}

class _SyncCalendarState extends State<SyncCalendar> {
  late String _calendarUrl;
  late String _timezone;
  late String _ignoreString;
  late bool _parseOpponents;
  bool _verifyingLink = false;
  bool _linkIsValid = false;
  bool _syncingCalendar = false;

  List<Event>? _events;

  @override
  void initState() {
    if (widget.season.calendarUrl.isNotEmpty) {
      _calendarUrl = widget.season.calendarUrl;
    } else {
      _calendarUrl = "";
    }
    if (widget.season.timezone.isNotEmpty) {
      _timezone = widget.season.timezone;
    } else {
      _timezone = "US/Pacific";
    }
    if (widget.season.calendarTitleIgnoreString.isNotEmpty) {
      _ignoreString = widget.season.calendarTitleIgnoreString;
    } else {
      _ignoreString = defaultIgnoreString;
    }
    _parseOpponents = widget.season.parseOpponents;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var dmodel = Provider.of<DataModel>(context);
    return cv.AppBar.sheet(
      title: "Sync Calendar",
      leading: [
        cv.BasicButton(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: Icon(Icons.close, color: dmodel.color),
        ),
      ],
      trailing: [
        cv.BasicButton(
          onTap: () {
            if (_linkIsValid) {
              _syncCalendar(dmodel);
            }
          },
          child: _syncingCalendar
              ? cv.LoadingIndicator(color: dmodel.color)
              : Text(
                  "Sync",
                  style: TextStyle(
                      color: _linkIsValid
                          ? dmodel.color
                          : CustomColors.textColor(context).withOpacity(0.5),
                      fontSize: 18),
                ),
        ),
      ],
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Row(
            children: const [
              Expanded(
                child: Center(
                  child: Text(
                    "Paste the url of a *.ics calendar file",
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        cv.TextField2(
          value: _calendarUrl,
          labelText: "Url",
          hintText: "Calendar Url",
          maxLines: 4,
          labelEdgePadding: 16,
          onChanged: (val) {
            setState(() {
              _linkIsValid = false;
              _calendarUrl = val;
              _events = null;
            });
          },
        ),
        CalendarAdvancedSettings(
            timezone: _timezone,
            onTimezoneChanged: (tz) {
              setState(() {
                _timezone = tz;
                _linkIsValid = false;
                _events = null;
              });
            },
            parseOpponents: _parseOpponents,
            onParseOpponentsChanged: (v) {
              setState(() {
                _parseOpponents = v;
                _linkIsValid = false;
                _events = null;
              });
            },
            ignoreString: _ignoreString,
            onIgnoreStringChanged: (v) {
              setState(() {
                _ignoreString = v;
                _linkIsValid = false;
                _events = null;
              });
            }),
        const SizedBox(height: 16),
        SizedBox(
          height: 30,
          child: Center(
            child: _verifyingLink
                ? cv.LoadingIndicator(color: dmodel.color)
                : cv.BasicButton(
                    onTap: () {
                      _validateLink(dmodel);
                    },
                    child: Text(
                      "Load Calendar",
                      style: TextStyle(
                        color: dmodel.color,
                        fontSize: 18,
                      ),
                    ),
                  ),
          ),
        ),
        if (_events != null)
          cv.Section(
            "Event Previews",
            child: cv.ListView<Event>(
              children: _events!,
              horizontalPadding: 0,
              childBuilder: (context, item) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_parseOpponents)
                      RichText(
                        text: TextSpan(
                            text: "Opponent: ",
                            style: TextStyle(
                              fontSize: 14,
                              color: CustomColors.textColor(context)
                                  .withOpacity(0.5),
                            ),
                            children: [
                              TextSpan(
                                text: "\"${item.awayTeam?.title ?? ''}\"",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: CustomColors.textColor(context),
                                ),
                              ),
                            ]),
                      )
                    else
                      Text(
                        item.getTitle(overrideTitle: true),
                        style: TextStyle(
                          fontSize: 18,
                          color: CustomColors.textColor(context),
                        ),
                      ),
                    const SizedBox(height: 4),
                    Text(
                      "${item.getDate()} · ${item.getTime()}",
                      style: TextStyle(
                        fontSize: 18,
                        color: CustomColors.textColor(context),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
      ],
    );
  }

  Future<void> _validateLink(DataModel dmodel) async {
    setState(() {
      _verifyingLink = true;
    });

    Map<String, dynamic> body = {
      "calendarUrl": _calendarUrl,
      "parseOpponents": _parseOpponents,
      "ignoreString": _ignoreString,
      "tz": _timezone,
    };

    await dmodel.loadCalendar(
      widget.team.teamId,
      widget.season.seasonId,
      body,
      (events) {
        setState(() {
          _linkIsValid = true;
          _events = events;
        });
      },
      onError: () {
        setState(() {
          _linkIsValid = false;
        });
      },
    );

    setState(() {
      _verifyingLink = false;
    });
  }

  Future<void> _syncCalendar(DataModel dmodel) async {
    setState(() {
      _syncingCalendar = true;
    });
    bool cont = false;
    // update the season with the calendar url
    await dmodel.updateSeason(
        widget.team.teamId,
        widget.season.seasonId,
        {
          "calendarUrl": _calendarUrl,
          "tz": _timezone,
          "parseOpponents": _parseOpponents,
          "calendarTitleIgnoreString": _ignoreString
        },
        showIndicatiors: false, () async {
      cont = true;
    }, onError: () {
      dmodel.addIndicator(
          IndicatorItem.error("There was an issue syncing the calendar"));
    });
    if (cont) {
      // send the sycn calendar call
      await dmodel.syncCalendar(
        widget.team.teamId,
        widget.season.seasonId,
        () {
          RestartWidget.restartApp(context);
        },
      );
    }
    setState(() {
      _syncingCalendar = false;
    });
  }
}

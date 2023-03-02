import 'dart:io';

import 'package:crosscheck_sports/client/root.dart';
import 'package:crosscheck_sports/crosscheck_engine.dart';
import 'package:crosscheck_sports/data/root.dart';
import 'package:crosscheck_sports/extras/root.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:crosscheck_sports/custom_views/root.dart' as cv;
import 'package:provider/provider.dart';
import 'package:crosscheck_sports/views/components/root.dart' as comp;

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
  bool _verifyingLink = false;
  bool _didVerify = false;
  bool _linkIsValid = false;
  bool _syncingCalendar = false;

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
          onChanged: (val) {
            setState(() {
              _didVerify = false;
              _linkIsValid = false;
              _calendarUrl = val;
            });
          },
        ),
        const SizedBox(height: 8),
        cv.BasicButton(
          onTap: () {
            cv.cupertinoSheet(
              context: context,
              builder: (context) => cv.TimezoneSelector(
                initTimezone: _timezone,
                onSelect: (tz) {
                  setState(() {
                    _timezone = tz;
                  });
                },
              ),
            );
          },
          child: Container(
            constraints: const BoxConstraints(
              minHeight: 50,
            ),
            decoration: BoxDecoration(
              color: CustomColors.cellColor(context),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Center(
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Timezone: $_timezone",
                        style: TextStyle(
                          color: CustomColors.textColor(context),
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _verifyingLink
            ? cv.LoadingIndicator(color: dmodel.color)
            : cv.BasicButton(
                onTap: () {
                  _validateLink(dmodel);
                },
                child: Text(
                  "Verify Link",
                  style: TextStyle(
                    color: dmodel.color,
                    fontSize: 18,
                  ),
                ),
              ),
        const SizedBox(height: 16),
        if (_didVerify && _linkIsValid)
          comp.ActionButton(
            title: "Sync Calendar",
            color: dmodel.color,
            isLoading: _syncingCalendar,
            onTap: () {
              _syncCalendar(dmodel);
            },
          ),
        if (_didVerify && !_linkIsValid)
          Row(
            children: const [
              Expanded(
                child: Center(
                  child: Text(
                    "This link is not valid!",
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Future<void> _validateLink(DataModel dmodel) async {
    setState(() {
      _verifyingLink = true;
    });

    await dmodel.verifyCalendar(
        widget.team.teamId, widget.season.seasonId, _calendarUrl, () {
      setState(() {
        _linkIsValid = true;
      });
    }, onError: () {
      setState(() {
        _linkIsValid = false;
      });
    });

    setState(() {
      _didVerify = true;
      _verifyingLink = false;
    });
  }

  Future<void> _syncCalendar(DataModel dmodel) async {
    setState(() {
      _syncingCalendar = true;
    });
    bool cont = false;
    // update the season with the calendar url
    await dmodel.updateSeason(widget.team.teamId, widget.season.seasonId,
        {"calendarUrl": _calendarUrl, "tz": _timezone}, showIndicatiors: false,
        () async {
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

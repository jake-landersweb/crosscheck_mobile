import 'dart:io';

import 'package:crosscheck_sports/client/root.dart';
import 'package:crosscheck_sports/crosscheck_engine.dart';
import 'package:crosscheck_sports/data/root.dart';
import 'package:crosscheck_sports/extras/root.dart';
import 'package:crosscheck_sports/views/root.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:crosscheck_sports/components/layer/header_bar.dart';
import 'package:provider/provider.dart';
import 'package:crosscheck_sports/components/core/clickable.dart';
import 'package:crosscheck_sports/components/core/cell_list.dart';
import 'package:crosscheck_sports/components/layer/section.dart';
import 'package:crosscheck_sports/components/core/loading_indicator.dart';

class UploadCalendar extends StatefulWidget {
  const UploadCalendar({
    super.key,
    required this.team,
    required this.season,
  });
  final Team team;
  final Season season;

  @override
  State<UploadCalendar> createState() => _UploadCalendarState();
}

class _UploadCalendarState extends State<UploadCalendar> {
  bool _loading = false;
  bool _isLoaded = false;
  bool _isUploading = false;

  List<Event>? _events;
  late String _timezone;
  late bool _parseOpponents;
  late String _ignoreString;
  String? _contents;

  @override
  void initState() {
    if (widget.season.timezone.isNotEmpty) {
      _timezone = widget.season.timezone;
    } else {
      _timezone = "US/Pacific";
    }
    if (widget.season.calendarTitleIgnoreString.isNotEmpty) {
      _ignoreString = widget.season.calendarTitleIgnoreString;
    } else {
      _ignoreString =
          "versus, vs, at, @, ., ${widget.team.title.toLowerCase()}";
    }
    _parseOpponents = widget.season.parseOpponents;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var dmodel = Provider.of<DataModel>(context);
    return HeaderBar.sheet(
      title: "Upload Calendar",
      leading: Clickable(
        onTap: () {
          Navigator.of(context).pop();
        },
        child: Icon(Icons.close, color: dmodel.color),
      ),
      trailing: Clickable(
        onTap: () {
          if (_isLoaded) {
            _upload(dmodel);
          }
        },
        child: _isUploading
            ? XCLoadingIndicator(color: dmodel.color)
            : Text(
                "Upload",
                style: TextStyle(
                  color: _isLoaded
                      ? dmodel.color
                      : CustomColors.textColor(context).withOpacity(0.5),
                  fontSize: 18,
                ),
              ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Center(
              child: Text(
                "Note: Crosscheck calendar upload only supports games at this time.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: CustomColors.textColor(context).withOpacity(0.5),
                ),
              ),
            ),
          ),
          CalendarAdvancedSettings(
            timezone: _timezone,
            onTimezoneChanged: (tz) {
              setState(() {
                _timezone = tz;
                _isLoaded = false;
                _events = null;
                _contents = null;
              });
            },
            parseOpponents: _parseOpponents,
            onParseOpponentsChanged: (v) {
              setState(() {
                _parseOpponents = v;
                _isLoaded = false;
                _events = null;
                _contents = null;
              });
            },
            ignoreString: _ignoreString,
            onIgnoreStringChanged: (v) {
              setState(() {
                _ignoreString = v;
                _isLoaded = false;
                _events = null;
                _contents = null;
              });
            },
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 30,
            child: Clickable(
              onTap: () {
                _selectFile(dmodel);
              },
              child: Center(
                child: _loading
                    ? XCLoadingIndicator(color: dmodel.color)
                    : Text("Select File:", style: TextStyle(color: dmodel.color)),
              ),
            ),
          ),
          if (_events != null)
            XCSection(
              "Event Previews",
              child: XCCellList<Event>(
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
      ),
    );
  }

  Future<void> _selectFile(DataModel dmodel) async {
    setState(() {
      _loading = true;
    });
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['ics'],
    );
    if (result != null && result.files.single.path != null) {
      File file = File(result.files.single.path!);
      var contents = await file.readAsString();

      Map<String, dynamic> body = {
        "calendarText": contents,
        "parseOpponents": _parseOpponents,
        "ignoreString": _ignoreString,
        "tz": _timezone,
      };

      // get the calendar preview
      await dmodel
          .loadCalendar(widget.team.teamId, widget.season.seasonId, body, (p0) {
        setState(() {
          _events = p0;
          _isLoaded = true;
          _contents = contents;
        });
      }, onError: () {
        setState(() {
          _isLoaded = false;
          _events = null;
          _contents = null;
        });
      });
    } else {
      // User canceled the picker
    }
    setState(() {
      _loading = false;
    });
  }

  Future<void> _upload(DataModel dmodel) async {
    setState(() {
      _isUploading = true;
    });

    bool cont = false;

    await dmodel.updateSeason(
        widget.team.teamId,
        widget.season.seasonId,
        {
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
      await dmodel.uploadCalendar(
        widget.team.teamId,
        widget.season.seasonId,
        _contents!,
        () {
          RestartWidget.restartApp(context);
        },
      );
    }

    setState(() {
      _isUploading = false;
    });
  }
}

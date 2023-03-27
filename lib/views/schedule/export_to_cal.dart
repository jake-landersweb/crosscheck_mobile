// ignore_for_file: use_build_context_synchronously

import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:uuid/uuid.dart';

import '../../custom_views/root.dart' as cv;
import '../../client/root.dart';
import '../../extras/root.dart';
import '../../data/root.dart';
import '../components/root.dart' as comp;
import 'package:device_calendar/device_calendar.dart' as cal;
import 'package:ical/serializer.dart';

class ExportToCalendar extends StatefulWidget {
  const ExportToCalendar({
    super.key,
    required this.team,
    required this.season,
  });
  final Team team;
  final Season season;

  @override
  State<ExportToCalendar> createState() => _ExportToCalendarState();
}

class _ExportToCalendarState extends State<ExportToCalendar> {
  List<Event>? _events;
  bool _isLoading = true;
  bool _isLoadingExport = false;

  late String _title;
  late Color _color;

  List<Event> _selectedEvents = [];

  var _deviceCalendar = cal.DeviceCalendarPlugin();

  @override
  void initState() {
    _getFutureEvents(context.read<DataModel>());
    _title = _calendarName();
    if (widget.team.color.isNotEmpty) {
      _color = CustomColors.fromHex(widget.team.color);
    } else {
      _color = CustomColors.random(const Uuid().v4());
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    return cv.AppBar.sheet(
      title: "Calendar Export",
      color: dmodel.color,
      leading: [
        cv.CancelButton(
          color: CustomColors.textColor(context).withOpacity(0.5),
        ),
      ],
      children: [
        cv.Section(
          "Information",
          child: cv.ListView<Widget>(
            horizontalPadding: 0,
            childPadding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              cv.TextField2(
                showBackground: false,
                value: _title,
                labelText: "Title",
                onChanged: (p0) {
                  setState(() {
                    _title = p0;
                  });
                },
              ),
              cv.BasicButton(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        titlePadding: const EdgeInsets.all(0),
                        contentPadding: const EdgeInsets.all(0),
                        shape: RoundedRectangleBorder(
                          borderRadius: MediaQuery.of(context).orientation ==
                                  Orientation.portrait
                              ? const BorderRadius.vertical(
                                  top: Radius.circular(500),
                                  bottom: Radius.circular(100),
                                )
                              : const BorderRadius.horizontal(
                                  right: Radius.circular(500)),
                        ),
                        content: SingleChildScrollView(
                          child: HueRingPicker(
                            pickerColor: _color,
                            onColorChanged: (color) {
                              setState(() {
                                _color = color;
                              });
                            },
                            displayThumbColor: false,
                          ),
                        ),
                      );
                    },
                  );
                },
                child: cv.LabeledWidget(
                  "Color",
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: _color,
                          shape: BoxShape.circle,
                        ),
                        height: 30,
                        width: 30,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "#${_color.value.toRadixString(16).substring(2)}",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: CustomColors.textColor(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: comp.ActionButton(
            onTap: () async => _exportToCalendar(context, dmodel),
            title: "Export",
            color: dmodel.color,
            isLoading: _isLoadingExport,
          ),
        ),
        if (_events != null)
          cv.Section(
            "Select Events",
            child: cv.ListView<Event>(
              children: _events!,
              horizontalPadding: 0,
              selected: _selectedEvents,
              color: dmodel.color,
              selectedLogic: (item) {
                return _selectedEvents
                    .any((element) => element.eventId == item.eventId);
              },
              allowsSelect: true,
              onSelect: (item) {
                if (_selectedEvents
                    .any((element) => element.eventId == item.eventId)) {
                  setState(() {
                    _selectedEvents.removeWhere(
                        (element) => element.eventId == item.eventId);
                  });
                } else {
                  setState(() {
                    _selectedEvents.add(item);
                  });
                }
              },
              childBuilder: (context, item) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.getTitle(),
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 22,
                          color: CustomColors.textColor(context)),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: _detailChildren(context, dmodel, item),
                    ),
                  ],
                );
              },
            ),
          )
        else
          cv.LoadingIndicator(color: dmodel.color),
      ],
    );
  }

  List<Widget> _detailChildren(
      BuildContext context, DataModel dmodel, Event event) {
    return [
      _detailCell(Icons.event_rounded, event.getDate()),
      if (!event.eventLocation.name.isEmpty())
        _detailCell(Icons.location_on_outlined, event.eventLocation.name!),
      if (event.eDescription.isNotEmpty)
        _detailCell(
            Icons.description_outlined,
            event.eDescription.length > 150
                ? "${event.eDescription.substring(0, 150)}..."
                : event.eDescription),
      if (event.customFields.isNotEmpty)
        for (var i in event.customFields)
          if (i.value.isNotEmpty) _customCell(i.title, i.value),
    ];
  }

  Widget _detailCell(IconData icon, String value) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: 35,
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(children: [
              Icon(
                icon,
                color: CustomColors.textColor(context).withOpacity(0.5),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  value,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 18,
                    color: CustomColors.textColor(context).withOpacity(0.5),
                  ),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _customCell(String label, String value) {
    return cv.LabeledCell(
      label: label,
      value: value,
      height: 35,
      textColor: CustomColors.textColor(context).withOpacity(0.5),
    );
  }

  void _getFutureEvents(DataModel dmodel) async {
    setState(() {
      _isLoading = true;
    });

    // first get access to calendar
    // get permission to calendars
    var permissionsGranted = await _deviceCalendar.hasPermissions();
    if (permissionsGranted.isSuccess &&
        (permissionsGranted.data == null || permissionsGranted.data == false)) {
      permissionsGranted = await _deviceCalendar.requestPermissions();
      if (!permissionsGranted.isSuccess ||
          permissionsGranted.data == null ||
          permissionsGranted.data == false) {
        // does not have access, leave the page
        dmodel.addIndicator(IndicatorItem.error(
            "There was an issue getting access to your calendar"));
        setState(() {
          _isLoadingExport = false;
        });
        Navigator.of(context).pop();
        return;
      }
    }

    // get the future events
    await dmodel.getFutureEvents(widget.team.teamId, widget.season.seasonId,
        (p0) {
      setState(() {
        _events = p0;
        _selectedEvents = [for (var i in _events!) i.clone()];
      });
    }, () {
      dmodel.addIndicator(
          IndicatorItem.error("There was an issue getting the future events"));
    });
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _exportToCalendar(BuildContext context, DataModel dmodel) async {
    setState(() {
      _isLoadingExport = true;
    });

    // get the calendars
    List<cal.Calendar>? calendars = await _getCalendars();
    if (calendars == null) {
      dmodel.addIndicator(
          IndicatorItem.error("There was an error getting your calendars"));
      setState(() {
        _isLoadingExport = false;
      });
      return;
    }

    // if a season calendar has already been created, delete it.
    if (calendars.any((element) => element.name == _title)) {
      var oldCalendar =
          calendars.firstWhere((element) => element.name == _title);
      _deviceCalendar.deleteCalendar(oldCalendar.id!);
      print("DELETED CALENDAR");
    }

    // create a new calendar
    var calCreateResult = await _deviceCalendar.createCalendar(
      _title,
      calendarColor: _color,
    );
    if (!calCreateResult.isSuccess) {
      dmodel.addIndicator(
          IndicatorItem.error("There was an issue creating the calendar"));
      setState(() {
        _isLoadingExport = false;
      });
      return;
    }

    // refresh the calendar list
    calendars = await _getCalendars();
    if (calendars == null) {
      dmodel.addIndicator(
          IndicatorItem.error("There was an error getting your calendars"));
      setState(() {
        _isLoadingExport = false;
      });
      return;
    }

    // bind the season calendar
    var seasonCalendar =
        calendars.firstWhere((element) => element.name == _calendarName());

    // get the timezone
    tz.initializeTimeZones();
    final String locationName = await FlutterNativeTimezone.getLocalTimezone();
    var currentLocation = tz.getLocation(locationName);

    int totalSaved = 0;

    // loop through future events and add to the calendar
    for (var event in _selectedEvents) {
      var e = cal.Event(
        seasonCalendar.id,
        title: event.getTitle(),
        start: tz.TZDateTime.from(event.eventDate(), currentLocation),
        end: tz.TZDateTime.from(event.eventDate(), currentLocation)
            .add(const Duration(hours: 2)),
        description: event.eDescription.length > 250
            ? event.eDescription.substring(0, 250)
            : event.eDescription,
      );
      if (event.eventLocation.address.isNotEmpty()) {
        e.location = event.eventLocation.address;
      } else if (event.eventLocation.name.isNotEmpty()) {
        e.location = event.eventLocation.name;
      }
      if (event.eLink.isNotEmpty) {
        e.url = Uri.parse(event.eLink);
      }

      // add the event to the calendar
      var res = await _deviceCalendar.createOrUpdateEvent(e);
      if (res?.isSuccess ?? false) {
        totalSaved += 1;
      } else {
        print(res?.errors
            .map((err) => '[${err.errorCode}] ${err.errorMessage}')
            .join(' | ') as String);
      }
    }
    dmodel.addIndicator(IndicatorItem.success(
        "Successfully saved $totalSaved/${_selectedEvents.length} events"));
    Navigator.of(context).pop();
    setState(() {
      _isLoadingExport = false;
    });
  }

  Future<List<cal.Calendar>?> _getCalendars() async {
    final calendarsResult = await _deviceCalendar.retrieveCalendars();
    if (calendarsResult.isSuccess) {
      return calendarsResult.data as List<cal.Calendar>;
    } else {
      return null;
    }
  }

  String _calendarName() {
    return "${widget.team.title} - ${widget.season.title}";
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_switch/flutter_switch.dart';

import '../../root.dart';
import 'root.dart';
import '../../../data/root.dart';
import '../../../client/root.dart';
import '../../../custom_views/root.dart' as cv;
import '../../../extras/root.dart';

class EventCreateEdit extends StatefulWidget {
  const EventCreateEdit({
    Key? key,
    required this.isCreate,
    this.initialEvent,
    required this.teamId,
    required this.seasonId,
    required this.completion,
  }) : super(key: key);
  final bool isCreate;
  final Event? initialEvent;
  final String teamId;
  final String seasonId;
  final VoidCallback completion;

  @override
  _EventCreateEditState createState() => _EventCreateEditState();
}

class _EventCreateEditState extends State<EventCreateEdit> {
  late Event _event;

  String _opponent = "";
  late DateTime _eDate;
  late bool _isHome;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialEvent != null) {
      _event = Event.of(widget.initialEvent!);
      _opponent = widget.initialEvent!.getOpponentTitle(widget.teamId);
      _eDate = widget.initialEvent!.eventDate();
      _isHome = widget.initialEvent!.isHome();
    } else {
      _event = Event.empty();
      _eDate = DateTime.now();
      _isHome = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    return cv.AppBar(
      title: widget.isCreate ? "Create Event" : "Edit Event",
      isLarge: false,
      leading: cv.BackButton(color: dmodel.color),
      children: [
        if (widget.isCreate)
          Column(
            children: [
              // event type
              cv.SegmentedPicker<int>(
                initialSelection: _event.eType,
                titles: const ["Game", "Practice", "Other"],
                selections: const [1, 2, 0],
                onSelection: (value) {
                  setState(() {
                    _event.eType = value;
                  });
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        // event date
        _eventDate(context, dmodel),
        const SizedBox(height: 16),
        // event title or opponent
        _title(context),
        const SizedBox(height: 16),
        _details(context, dmodel),
        const SizedBox(height: 16),
        _location(context, dmodel),
        const SizedBox(height: 16),
        _actionButton(context, dmodel),
        const SizedBox(height: 48),
      ],
    );
  }

  Widget _eventDate(BuildContext context, DataModel dmodel) {
    return cv.NativeList(
      itemPadding: const EdgeInsets.fromLTRB(16, 7, 16, 7),
      children: [
        Row(
          children: [
            cv.BasicButton(
              onTap: () {
                DatePicker.showDatePicker(
                  context,
                  showTitleActions: true,
                  minTime: DateTime(2018, 3, 5),
                  maxTime: DateTime(2023, 6, 7),
                  theme: DatePickerTheme(
                    backgroundColor: CustomColors.cellColor(context),
                    doneStyle: TextStyle(color: dmodel.color, fontSize: 18),
                    cancelStyle: TextStyle(
                        color: CustomColors.textColor(context).withOpacity(0.5),
                        fontSize: 14),
                    itemStyle: TextStyle(
                      color: CustomColors.textColor(context),
                    ),
                  ),
                  onChanged: (date) {
                    print('change $date');
                  },
                  onConfirm: (date) {
                    print('confirm $date');
                    setState(() {
                      _eDate = DateTime(date.year, date.month, date.day,
                          _eDate.hour, _eDate.minute);
                    });
                  },
                  currentTime: _eDate,
                  locale: LocaleType.en,
                );
              },
              child: Material(
                color: CustomColors.textColor(context).withOpacity(0.2),
                shape: ContinuousRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    dateToString(_eDate).getDate(),
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 7),
            cv.BasicButton(
              onTap: () {
                DatePicker.showTimePicker(
                  context,
                  showSecondsColumn: false,
                  showTitleActions: true,
                  theme: DatePickerTheme(
                    backgroundColor: CustomColors.cellColor(context),
                    doneStyle: TextStyle(color: dmodel.color, fontSize: 18),
                    cancelStyle: TextStyle(
                        color: CustomColors.textColor(context).withOpacity(0.5),
                        fontSize: 14),
                    itemStyle: TextStyle(
                      color: CustomColors.textColor(context),
                    ),
                  ),
                  onChanged: (date) {
                    print('change $date');
                  },
                  onConfirm: (date) {
                    print('confirm $date');
                    setState(() {
                      _eDate = date;
                    });
                  },
                  currentTime: _eDate,
                  locale: LocaleType.en,
                );
              },
              child: Material(
                color: CustomColors.textColor(context).withOpacity(0.2),
                shape: ContinuousRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    dateToString(_eDate).getTime()[0] == "0"
                        ? dateToString(_eDate).getTime().substring(1)
                        : dateToString(_eDate).getTime(),
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ),
            const Spacer(),
            const cv.BasicLabel(label: "Event Date"),
          ],
        )
      ],
    );
  }

  Widget _title(BuildContext context) {
    return cv.NativeList(
      itemPadding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        (_event.eType == 1)
            ? cv.TextField(
                labelText: "Opponent",
                showBackground: false,
                initialvalue: _opponent,
                isLabeled: true,
                onChanged: (value) {
                  setState(() {
                    _opponent = value;
                  });
                },
                validator: (value) {},
              )
            : cv.TextField(
                labelText: "Title",
                showBackground: false,
                isLabeled: true,
                initialvalue: _event.eTitle,
                onChanged: (value) {
                  setState(() {
                    _event.eTitle = value;
                  });
                },
                validator: (value) {},
              )
      ],
    );
  }

  Widget _details(BuildContext context, DataModel dmodel) {
    return cv.Section(
      "Details",
      child: cv.NativeList(
        children: [
          // description
          cv.TextField(
            labelText: "Description",
            onChanged: (value) {
              setState(() {
                _event.eDescription = value;
              });
            },
            validator: (value) {},
            showBackground: false,
            initialvalue: _event.eDescription ?? "",
            isLabeled: true,
          ),

          // track attendace
          if (widget.isCreate)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Row(
                children: [
                  FlutterSwitch(
                    value: _event.hasAttendance,
                    height: 25,
                    width: 50,
                    toggleSize: 18,
                    activeColor: dmodel.color,
                    onToggle: (value) {
                      setState(() {
                        _event.hasAttendance = value;
                      });
                    },
                  ),
                  const Spacer(),
                  const cv.BasicLabel(
                    label: "Track Attendance",
                  ),
                ],
              ),
            ),
          // show attendance
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Row(
              children: [
                FlutterSwitch(
                  value: _event.showAttendance!,
                  height: 25,
                  width: 50,
                  toggleSize: 18,
                  activeColor: dmodel.color,
                  onToggle: (value) {
                    setState(() {
                      _event.showAttendance = value;
                    });
                  },
                ),
                const Spacer(),
                const cv.BasicLabel(
                  label: "Show Attendance",
                ),
              ],
            ),
          ),
          //  is home or away
          if (_event.eType == 1)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Row(
                children: [
                  FlutterSwitch(
                    value: _isHome,
                    height: 25,
                    width: 50,
                    toggleSize: 18,
                    activeColor: dmodel.color,
                    onToggle: (value) {
                      setState(() {
                        _isHome = value;
                      });
                    },
                  ),
                  const Spacer(),
                  const cv.BasicLabel(
                    label: "Is Home Team",
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _location(BuildContext context, DataModel dmodel) {
    return cv.Section(
      "Location",
      allowsCollapse: true,
      child: cv.NativeList(
        children: [
          // location
          cv.TextField(
            labelText: "Name",
            onChanged: (value) {
              setState(() {
                _event.eventLocation?.name = value;
              });
            },
            validator: (value) {},
            showBackground: false,
            initialvalue: _event.eventLocation?.name ?? "",
            isLabeled: true,
          ),
          cv.TextField(
            labelText: "Address 1",
            onChanged: (value) {
              setState(() {
                _event.eventLocation?.address1 = value;
              });
            },
            validator: (value) {},
            showBackground: false,
            initialvalue: _event.eventLocation?.address1 ?? "",
            isLabeled: true,
          ),
          cv.TextField(
            labelText: "Address 2",
            onChanged: (value) {
              setState(() {
                _event.eventLocation?.address2 = value;
              });
            },
            validator: (value) {},
            showBackground: false,
            initialvalue: _event.eventLocation?.address2 ?? "",
            isLabeled: true,
          ),
          cv.TextField(
            labelText: "City",
            onChanged: (value) {
              setState(() {
                _event.eventLocation?.city = value;
              });
            },
            validator: (value) {},
            showBackground: false,
            initialvalue: _event.eventLocation?.city ?? "",
            isLabeled: true,
          ),
          cv.TextField(
            labelText: "State",
            onChanged: (value) {
              setState(() {
                _event.eventLocation?.state = value;
              });
            },
            validator: (value) {},
            showBackground: false,
            initialvalue: _event.eventLocation?.state ?? "",
            isLabeled: true,
          ),
          cv.TextField(
            labelText: "Zip",
            keyboardType: TextInputType.number,
            onChanged: (value) {
              try {
                int zip = int.parse(value);
                setState(() {
                  _event.eventLocation?.zip = zip;
                });
              } catch (error) {
                dmodel.setError("Invalid Character", true);
              }
            },
            validator: (value) {},
            showBackground: false,
            initialvalue: "${_event.eventLocation?.zip ?? ""}",
            isLabeled: true,
          ),
        ],
      ),
    );
  }

  Widget _actionButton(BuildContext context, DataModel dmodel) {
    return cv.NativeList(
      children: [
        cv.BasicButton(
          onTap: () {
            _action(context, dmodel);
          },
          child: SizedBox(
            height: 40,
            child: Center(
              child: _isLoading
                  ? cv.LoadingIndicator()
                  : Text(
                      widget.isCreate ? "Create Event" : "Edit Event",
                      style: TextStyle(
                        color: dmodel.color,
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }

  void _action(BuildContext context, DataModel dmodel) async {
    if (_event.eType == 1) {
      if (_opponent == "") {
        dmodel.setError("Opponent cannot be empty", true);
        return;
      }
    } else {
      if (_event.eTitle == "") {
        dmodel.setError("Title cannot be empty", true);
        return;
      }
    }
    setState(() {
      _isLoading = true;
    });
    // create teams
    EventTeam homeTeam = EventTeam.empty();
    EventTeam awayTeam = EventTeam.empty();

    if (_event.eType == 1) {
      if (_isHome) {
        homeTeam = EventTeam(
            title: dmodel.tus!.team.title,
            teamId: dmodel.tus!.team.teamId,
            score: 0);
        awayTeam = EventTeam(title: _opponent, score: 0);
      } else {
        homeTeam = EventTeam(title: _opponent, score: 0);
        awayTeam = EventTeam(
            title: dmodel.tus!.team.title,
            teamId: dmodel.tus!.team.teamId,
            score: 0);
      }
    }
    // create the event
    Map<String, dynamic> _eventBody = _event.toJson();
    _eventBody['eDate'] = dateToString(_eDate);
    _eventBody['isHome'] = _isHome;
    _eventBody['homeTeam'] = homeTeam.toJson();
    _eventBody['awayTeam'] = awayTeam.toJson();
    _eventBody['teamId'] = widget.teamId;
    _eventBody['seasonId'] = widget.seasonId;
    _eventBody['eLocation'] = _event.eventLocation?.name ?? "";

    // send the request
    if (widget.isCreate) {
      await dmodel.createEvent(widget.teamId, widget.seasonId, _eventBody, () {
        setState(() {
          dmodel.schedule == null;
        });
        Navigator.of(context).pop();
        widget.completion();
      });
    } else {
      // update the event
      await dmodel.updateEvent(
          widget.teamId, widget.seasonId, _event.eventId, _eventBody, () {
        Navigator.of(context).pop();
        widget.completion();
      });
    }
    setState(() {
      _isLoading = false;
    });
  }
}

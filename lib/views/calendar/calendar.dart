import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../data/root.dart';
import '../../custom_views/root.dart' as cv;
import '../../client/root.dart';
import '../../extras/root.dart';
import '../root.dart';

class Calendar extends StatefulWidget {
  const Calendar({
    Key? key,
    required this.teamId,
    required this.seasonId,
    required this.email,
  }) : super(key: key);

  final String teamId;
  final String seasonId;
  final String email;

  @override
  _CalendarState createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  List<Event> _selectedEvents = [];

  List<Event> _fullEventList = [];

  @override
  void initState() {
    super.initState();
    _composeList(context.read<DataModel>());
  }

  @override
  void dispose() {
    super.dispose();
    _fullEventList = [];
  }

  @override
  Widget build(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    return Column(
      children: [
        TableCalendar(
          availableGestures: AvailableGestures.horizontalSwipe,
          firstDay: DateTime.utc(2018, 10, 16),
          lastDay: DateTime.utc(2024, 3, 14),
          availableCalendarFormats: const {CalendarFormat.month: 'Month'},
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) {
            return isSameDay(_selectedDay, day);
          },
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay; // update `_focusedDay` here as well
              _selectedEvents = _getEventsFromDay(selectedDay);
            });
          },
          eventLoader: (day) {
            return _getBubbles(day);
          },
          onFormatChanged: (format) {},
          calendarBuilders: CalendarBuilders(
            selectedBuilder: (context, day, day2) {
              return Padding(
                padding: const EdgeInsets.all(5.0),
                child: Stack(
                  alignment: AlignmentDirectional.center,
                  children: [
                    Material(
                      color: dmodel.color.withOpacity(0.7),
                      shape: ContinuousRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      child: Container(),
                    ),
                    Text("${day.day}",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.white)),
                  ],
                ),
              );
            },
            todayBuilder: (context, day, day2) {
              return Padding(
                padding: const EdgeInsets.all(5.0),
                child: Stack(
                  alignment: AlignmentDirectional.center,
                  children: [
                    Material(
                      color: CustomColors.textColor(context).withOpacity(0.1),
                      shape: ContinuousRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      child: Container(),
                    ),
                    Text("${day.day}",
                        style: TextStyle(fontWeight: FontWeight.bold))
                  ],
                ),
              );
            },
            singleMarkerBuilder: (context, date, object) {
              return Transform.translate(
                offset: const Offset(0, -3),
                child: cv.Circle(
                  7,
                  CustomColors.textColor(context).withOpacity(0.5),
                ),
              );
            },
            defaultBuilder: (context, day, day2) {
              return Padding(
                padding: const EdgeInsets.all(5.0),
                child: Stack(
                  alignment: AlignmentDirectional.center,
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                    ),
                    Text("${day.day}",
                        style: const TextStyle(fontWeight: FontWeight.w600))
                  ],
                ),
              );
            },
            dowBuilder: (context, date) {
              return SizedBox(
                width: MediaQuery.of(context).size.width / 7,
                child: Center(
                  child: Text(_getWeekday(date.weekday),
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 12)),
                ),
              );
            },
            outsideBuilder: (context, day, day2) {
              return Padding(
                padding: const EdgeInsets.all(5.0),
                child: Stack(
                  alignment: AlignmentDirectional.center,
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                    ),
                    Opacity(
                      opacity: 0.5,
                      child: Text(
                        "${day.day}",
                        style: const TextStyle(
                            fontWeight: FontWeight.w400, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        // list of the events for that current calendar day
        ListView.builder(
          shrinkWrap: true,
          itemCount: _selectedEvents.length,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return Column(
              children: [
                EventCell(
                  event: _selectedEvents[index],
                  email: dmodel.user!.email,
                  teamId: dmodel.tus!.team.teamId,
                  seasonId: _selectedEvents[index].seasonId,
                ),
                const SizedBox(height: 16),
              ],
            );
          },
        ),
      ],
    );
  }

  String _getWeekday(int i) {
    switch (i) {
      case 1:
        return "M";
      case 2:
        return "T";
      case 3:
        return "W";
      case 4:
        return "T";
      case 5:
        return "F";
      case 6:
        return "S";
      default:
        return "S";
    }
  }

  List<Event> _getBubbles(DateTime day) {
    return _fullEventList
        .where((element) => generalSameDate(stringToDate(element.eDate), day))
        .toList();
  }

  List<Event> _getEventsFromDay(DateTime day) {
    List<Event> events = [];
    for (Event event in _fullEventList) {
      DateTime eventDate = stringToDate(event.eDate);
      if (eventDate.day == day.day && eventDate.month == day.month) {
        events.add(event);
      }
    }
    events.sort((a, b) => a.eDate.compareTo(b.eDate));
    return events;
  }

  void _composeList(DataModel dmodel) {
    if (dmodel.schedule != null) {
      _fullEventList.addAll(dmodel.schedule!.previousEvents);
      if (dmodel.schedule!.nextEvent != null) {
        _fullEventList.add(dmodel.schedule!.nextEvent!);
        _fullEventList.addAll(dmodel.schedule!.upcomingEvents);
      }
      _selectedEvents = _getEventsFromDay(_selectedDay);
    }
    setState(() {});
  }
}
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
  }) : super(key: key);

  final String teamId;

  @override
  _CalendarState createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  List<EventRaw> _selectedEvents = [];

  @override
  void initState() {
    super.initState();
    _getCalendar(context.read<DataModel>());
  }

  @override
  Widget build(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    return Column(
      children: [
        TableCalendar(
          firstDay: DateTime.utc(2010, 10, 16),
          lastDay: DateTime.utc(2030, 3, 14),
          availableCalendarFormats: const {CalendarFormat.month: 'Month'},
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) {
            return isSameDay(_selectedDay, day);
          },
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay; // update `_focusedDay` here as well
              _selectedEvents = _getEventsFromDay(selectedDay, dmodel);
            });
          },
          eventLoader: (day) {
            return _getBubbles(day, dmodel);
          },
          onFormatChanged: (format) {},
          calendarBuilders: CalendarBuilders(
            selectedBuilder: (context, day, day2) {
              return Padding(
                padding: const EdgeInsets.all(5.0),
                child: Stack(
                  alignment: AlignmentDirectional.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: dmodel.color.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                    ),
                    Text("${day.day}",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: dmodel.color)),
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
                    Container(
                      decoration: BoxDecoration(
                        color: CustomColors.textColor(context).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
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
                Stack(
                  alignment: AlignmentDirectional.topEnd,
                  children: [
                    EventCell(
                      event: Event.fromRaw(_selectedEvents[index]),
                      email: dmodel.user!.email,
                      teamId: dmodel.tus!.team.teamId,
                      seasonId: _selectedEvents[index].seasonId,
                      showStatus: false,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: cv.Circle(
                        10,
                        CustomColors.fromHex(
                            _selectedEvents[index].color ?? "FFFFFF"),
                      ),
                    ),
                  ],
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

  List<CalendarEvent> _getBubbles(DateTime day, DataModel dmodel) {
    if (dmodel.calendar == null) {
      return [];
    } else {
      List<CalendarEvent> list = [];
      for (CalendarEvent i in dmodel.calendar!) {
        var event = i.events.firstWhere(
            (element) => generalSameDate(stringToDate(element.eDate), day),
            orElse: () => EventRaw.empty());

        if (event.eventId != '') {
          list.add(i);
        }
      }
      return list;
    }
  }

  List<EventRaw> _getEventsFromDay(DateTime day, DataModel dmodel) {
    if (dmodel.calendar != null) {
      List<EventRaw> events = [];
      for (CalendarEvent ce in dmodel.calendar!) {
        for (EventRaw event in ce.events) {
          DateTime eventDate = stringToDate(event.eDate);
          if (eventDate.day == day.day && eventDate.month == day.month) {
            event.color = ce.color;
            events.add(event);
          }
        }
      }
      return events;
    } else {
      return [];
    }
  }

  void _getCalendar(DataModel dmodel) {
    if (dmodel.calendar == null) {
      dmodel.getCalendar(widget.teamId, (calendar) {
        dmodel.setCalendar(calendar);
        setState(() {
          _selectedEvents =
              _getEventsFromDay(_selectedDay, context.read<DataModel>());
        });
      });
    }
  }
}

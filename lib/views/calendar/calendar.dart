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
                        color: dmodel.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Text("${day.day}")
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
                        color: dmodel.color.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                    ),
                    Text("${day.day}")
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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../custom_views/root.dart' as cv;
import '../../client/root.dart';
import '../../extras/root.dart';
import '../../data/root.dart';
import '../../extras/root.dart';
import 'root.dart';

class Schedule extends StatefulWidget {
  const Schedule({Key? key}) : super(key: key);

  @override
  _ScheduleState createState() => _ScheduleState();
}

class _ScheduleState extends State<Schedule> {
  String _currentTitle = "Upcoming";

  @override
  Widget build(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    if (dmodel.schedule != null) {
      return Column(
        children: [
          cv.SegmentedPicker(
            titles: const ["Upcoming", "Previous"],
            onSelection: (selection) {
              setState(() {
                _currentTitle = selection;
              });
            },
            initialSelection: "Upcoming",
          ),
          if (_currentTitle == "Upcoming")
            Column(
              children: [
                _next(context, dmodel),
                _scheduleList(
                    context, dmodel, dmodel.schedule!.upcomingEvents, false),
              ],
            )
          else
            _scheduleList(context, dmodel,
                List.from(dmodel.schedule!.previousEvents.reversed), true),
          const SizedBox(height: 48),
        ],
      );
    } else {
      if (!dmodel.noSeason) {
        return const ScheduleLoading();
      } else {
        return const Center(child: Text("There are no seasons for this team."));
      }
    }
  }

  Widget _next(BuildContext context, DataModel dmodel) {
    if (dmodel.schedule!.nextEvent != null) {
      DateTime eventDate = stringToDate(dmodel.schedule!.nextEvent!.eDate);
      return Column(
        children: [
          const SizedBox(height: 15),
          Row(
            children: [
              Text(
                monthFromInt(eventDate.month).capitalize(),
                style: TextStyle(
                    color: CustomColors.textColor(context).withOpacity(0.5),
                    fontSize: 20,
                    fontWeight: FontWeight.w400),
              ),
              Divider(),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 15,
                child: Align(
                  alignment: Alignment.topLeft,
                  child: _withDateSide(
                    weekDayFromInt(eventDate.weekday),
                    eventDate.day,
                    dmodel,
                    generalSameDate(
                      DateTime.now(),
                      eventDate,
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 85,
                child: EventCell(
                  event: dmodel.schedule!.nextEvent!,
                  email: dmodel.user!.email,
                  teamId: dmodel.tus!.team.teamId,
                  seasonId: dmodel.currentSeason!.seasonId,
                  isExpaded: true,
                ),
              ),
            ],
          ),
          if (dmodel.schedule!.upcomingEvents.isNotEmpty)
            const SizedBox(height: 10),
        ],
      );
    } else {
      return const Padding(
        padding: EdgeInsets.only(top: 20),
        child: Text(
          "There are no future events for this season.",
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
      );
    }
  }

  Widget _scheduleList(BuildContext context, DataModel dmodel, List<Event> list,
      bool isPrevious) {
    if (list.isNotEmpty) {
      return ListView.builder(
        padding: const EdgeInsets.all(0),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: list.length,
        itemBuilder: (context, index) {
          DateTime eventDate = stringToDate(list[index].eDate);
          Widget child;
          if (list[index].eventId == list.first.eventId) {
            DateTime nextEventDate =
                stringToDate(dmodel.schedule!.nextEvent!.eDate);
            if (generalSameDate(nextEventDate, eventDate) && !isPrevious) {
              child = Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 15,
                    child: Container(),
                  ),
                  Expanded(
                    flex: 85,
                    child: EventCell(
                      event: list[index],
                      email: dmodel.user!.email,
                      teamId: dmodel.tus!.team.teamId,
                      seasonId: dmodel.currentSeason!.seasonId,
                    ),
                  ),
                ],
              );
            } else {
              child = Column(
                children: [
                  if (eventDate.month != nextEventDate.month || isPrevious)
                    Column(
                      children: [
                        const SizedBox(height: 15),
                        Row(
                          children: [
                            Text(
                              monthFromInt(eventDate.month).capitalize(),
                              style: TextStyle(
                                  color: CustomColors.textColor(context)
                                      .withOpacity(0.5),
                                  fontSize: 20,
                                  fontWeight: FontWeight.w400),
                            ),
                            Divider(),
                          ],
                        ),
                        const SizedBox(height: 15),
                      ],
                    )
                  else
                    const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 15,
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: _withDateSide(
                            weekDayFromInt(eventDate.weekday),
                            eventDate.day,
                            dmodel,
                            false,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 85,
                        child: EventCell(
                          event: list[index],
                          email: dmodel.user!.email,
                          teamId: dmodel.tus!.team.teamId,
                          seasonId: dmodel.currentSeason!.seasonId,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }
          } else {
            DateTime previousDate = stringToDate(list[index - 1].eDate);
            if (eventDate.day == previousDate.day) {
              child = Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 15,
                    child: Container(),
                  ),
                  Expanded(
                    flex: 85,
                    child: EventCell(
                      event: list[index],
                      email: dmodel.user!.email,
                      teamId: dmodel.tus!.team.teamId,
                      seasonId: dmodel.currentSeason!.seasonId,
                    ),
                  ),
                ],
              );
            } else {
              child = Column(
                children: [
                  if (eventDate.month != previousDate.month)
                    Column(
                      children: [
                        const SizedBox(height: 15),
                        Row(
                          children: [
                            Text(
                              monthFromInt(eventDate.month).capitalize(),
                              style: TextStyle(
                                  color: CustomColors.textColor(context)
                                      .withOpacity(0.5),
                                  fontSize: 20,
                                  fontWeight: FontWeight.w400),
                            ),
                            Divider(),
                          ],
                        ),
                        const SizedBox(height: 15),
                      ],
                    )
                  else
                    const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 15,
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: _withDateSide(
                            weekDayFromInt(eventDate.weekday),
                            eventDate.day,
                            dmodel,
                            false,
                          ),
                        ),
                      ),
                      Expanded(
                          flex: 85,
                          child: EventCell(
                              event: list[index],
                              email: dmodel.user!.email,
                              teamId: dmodel.tus!.team.teamId,
                              seasonId: dmodel.currentSeason!.seasonId)),
                    ],
                  ),
                ],
              );
            }
          }
          return Column(
            children: [
              child,
              if (list[index] != list.last) const SizedBox(height: 10),
            ],
          );
        },
      );
    } else {
      return Container();
    }
  }

  Widget _withDateSide(String day, int date, DataModel dmodel, bool isToday) {
    return Column(
      children: [
        Text(
          day,
          style: TextStyle(
            color: CustomColors.textColor(context).withOpacity(0.7),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 8),
        if (isToday)
          Stack(
            alignment: AlignmentDirectional.center,
            children: [
              cv.Circle(35, dmodel.color),
              Text(
                date.toString(),
                style: const TextStyle(color: Colors.white, fontSize: 20),
              )
            ],
          )
        else
          Stack(
            alignment: AlignmentDirectional.center,
            children: [
              cv.Circle(35, Colors.transparent),
              Text(
                date.toString(),
                style: TextStyle(color: dmodel.color, fontSize: 20),
              )
            ],
          )
      ],
    );
  }
}

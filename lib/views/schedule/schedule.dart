import 'package:flutter/material.dart';
import 'package:pnflutter/theme/root.dart';
import 'package:pnflutter/views/root.dart';
import 'package:pnflutter/views/schedule/event_edit/event_create_edit.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_svg/svg.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import '../../custom_views/root.dart' as cv;
import '../../client/root.dart';
import '../../extras/root.dart';
import '../../data/root.dart';
import 'root.dart';
import '../team/root.dart';

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
    return cv.AppBar(
      title: "Schedule",
      // isLarge: true,
      refreshable: true,
      backgroundColor: CustomColors.backgroundColor(context),
      color: dmodel.color,
      leading: const [MenuButton()],
      onRefresh: () => _refreshAction(dmodel),
      trailing: [
        if (dmodel.currentSeasonUser?.isSeasonAdmin() ??
            false ||
                (dmodel.tus?.user.isTeamAdmin() ?? false) &&
                    dmodel.currentSeason != null)
          cv.BasicButton(
            onTap: () {
              showMaterialModalBottomSheet(
                context: context,
                builder: (context) {
                  return EventCreateEdit(
                    isCreate: true,
                    teamId: dmodel.tus!.team.teamId,
                    season: dmodel.currentSeason!,
                    completion: () {
                      // reload the schedule
                      dmodel.reloadHomePage(
                        dmodel.tus!.team.teamId,
                        dmodel.currentSeason!.seasonId,
                        dmodel.user!.email,
                        true,
                      );
                    },
                  );
                },
              );
            },
            child: Icon(Icons.add, color: dmodel.color),
          )
        else if (dmodel.seasonUsers == null &&
            !(dmodel.noTeam || dmodel.noSeason))
          const SizedBox(
            height: 25,
            width: 25,
            child: cv.LoadingIndicator(),
          )
      ],
      children: [
        _body(context, dmodel),
      ],
    );
  }

  Widget _body(BuildContext context, DataModel dmodel) {
    if (dmodel.upcomingEvents != null) {
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
            if (dmodel.upcomingEvents!.isEmpty)
              cv.NoneFound("There are no upcoming events", color: dmodel.color)
            else
              Column(
                children: [
                  EventList(
                    list: dmodel.upcomingEvents!,
                    isPrevious: false,
                  ),
                  const SizedBox(height: 32),
                  if (dmodel.hasMoreUpcomingEvents)
                    cv.RoundedLabel(
                      "",
                      width: MediaQuery.of(context).size.width / 2,
                      color: CustomColors.cellColor(context),
                      onTap: () {
                        dmodel.getMoreEvents(
                          dmodel.tus!.team.teamId,
                          dmodel.currentSeason!.seasonId,
                          dmodel.user!.email,
                          false,
                        );
                      },
                      child: Center(
                        child: dmodel.isFetchingEvents
                            ? const cv.LoadingIndicator()
                            : const Opacity(
                                opacity: 0.5,
                                child: Center(
                                  child: Text(
                                    "Get More",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ),
                      ),
                    ),
                ],
              )
          else
            PreviousEvents(
              teamId: dmodel.tus!.team.teamId,
              seasonId: dmodel.currentSeason!.seasonId,
              email: dmodel.user!.email,
            ),
          const SizedBox(height: 48),
        ],
      );
    } else {
      if (!dmodel.noSeason) {
        return const ScheduleLoading();
      } else {
        if (dmodel.noTeam) {
          return const NoTeam();
        } else {
          return const NoSeason();
        }
      }
    }
  }

  Future<void> _refreshAction(DataModel dmodel) async {
    if (dmodel.currentSeason != null) {
      await dmodel.reloadHomePage(
        dmodel.tus!.team.teamId,
        dmodel.currentSeason!.seasonId,
        dmodel.user!.email,
        false,
      );
    } else if (!dmodel.noTeam && dmodel.tus != null) {
      await dmodel.teamUserSeasonsGet(
          dmodel.tus!.team.teamId, dmodel.user!.email, (tus) {
        dmodel.setTUS(tus);
        return;
      });
    }
  }
}

class PreviousEvents extends StatefulWidget {
  const PreviousEvents({
    Key? key,
    required this.teamId,
    required this.seasonId,
    required this.email,
  }) : super(key: key);
  final String teamId;
  final String seasonId;
  final String email;

  @override
  _PreviousEventsState createState() => _PreviousEventsState();
}

class _PreviousEventsState extends State<PreviousEvents> {
  @override
  void initState() {
    super.initState();
    _getPreviousEvents(context.read<DataModel>());
  }

  @override
  Widget build(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    if (dmodel.previousEvents == null) {
      return const ScheduleLoading();
    } else if (dmodel.previousEvents!.isEmpty) {
      return cv.NoneFound("There are no previous events", color: dmodel.color);
    } else {
      return Column(
        children: [
          EventList(list: dmodel.previousEvents!, isPrevious: true),
          const SizedBox(height: 32),
          if (dmodel.hasMorePreviousEvents)
            cv.RoundedLabel(
              "",
              width: MediaQuery.of(context).size.width / 2,
              color: CustomColors.cellColor(context),
              onTap: () {
                dmodel.getMoreEvents(
                  dmodel.tus!.team.teamId,
                  dmodel.currentSeason!.seasonId,
                  dmodel.user!.email,
                  true,
                );
              },
              child: Center(
                child: dmodel.isFetchingEvents
                    ? const cv.LoadingIndicator()
                    : const Opacity(
                        opacity: 0.5,
                        child: Center(
                          child: Text(
                            "Get More",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
              ),
            ),
        ],
      );
    }
  }

  Future<void> _getPreviousEvents(DataModel dmodel) async {
    if (dmodel.previousEvents == null) {
      dmodel.getPagedEvents(widget.teamId, widget.seasonId, widget.email,
          dmodel.previousEventsStartIndex, true, (events) {
        dmodel.setPreviousEvents(events);
      }, hasLoads: false);
    }
  }
}

class EventList extends StatefulWidget {
  EventList({
    Key? key,
    required this.list,
    required this.isPrevious,
  }) : super(key: key);
  List<Event> list;
  bool isPrevious;

  @override
  _EventListState createState() => _EventListState();
}

class _EventListState extends State<EventList> {
  @override
  Widget build(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    if (widget.list.isNotEmpty) {
      return ListView.builder(
        padding: const EdgeInsets.all(0),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: widget.list.length,
        itemBuilder: (context, index) {
          DateTime eventDate = widget.list[index].eventDate();
          Widget child;
          if (widget.list[index].eventId == widget.list.first.eventId) {
            child = Column(
              children: [
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
                        const Divider(),
                      ],
                    ),
                    const SizedBox(height: 15),
                  ],
                ),
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
                          isSameDay(eventDate, DateTime.now()),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 85,
                      child: EventCell(
                        event: widget.list[index],
                        email: dmodel.user!.email,
                        teamId: dmodel.tus!.team.teamId,
                        season: dmodel.currentSeason!,
                        isExpaded: widget.isPrevious ? false : true,
                        isUpcoming: !widget.isPrevious,
                      ),
                    ),
                  ],
                ),
              ],
            );
          } else {
            DateTime previousDate = widget.list[index - 1].eventDate();
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
                      event: widget.list[index],
                      email: dmodel.user!.email,
                      teamId: dmodel.tus!.team.teamId,
                      season: dmodel.currentSeason!,
                      isUpcoming: !widget.isPrevious,
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
                            const Divider(),
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
                            isSameDay(eventDate, DateTime.now()),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 85,
                        child: EventCell(
                            event: widget.list[index],
                            email: dmodel.user!.email,
                            teamId: dmodel.tus!.team.teamId,
                            season: dmodel.currentSeason!,
                            isUpcoming: !widget.isPrevious),
                      ),
                    ],
                  ),
                ],
              );
            }
          }
          return Column(
            children: [
              child,
              if (widget.list[index] != widget.list.last)
                const SizedBox(height: 10),
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

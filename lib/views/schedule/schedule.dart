import 'dart:developer';
import 'package:crosscheck_sports/views/schedule/notifications_view.dart';
import 'package:crosscheck_sports/views/team/team_model.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:crosscheck_sports/views/root.dart';
import 'package:flutter/scheduler.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../client/root.dart';
import '../../extras/root.dart';
import '../../data/root.dart';
import '../../custom_views/root.dart' as cv;
import '../components/root.dart' as comp;
import 'dart:math' as math;
import 'package:auto_size_text/auto_size_text.dart';

class Schedule extends StatefulWidget {
  const Schedule({Key? key}) : super(key: key);

  @override
  _ScheduleState createState() => _ScheduleState();
}

class _ScheduleState extends State<Schedule> {
  late ScrollController _controller;
  @override
  void initState() {
    DataModel dmodel = context.read<DataModel>();
    _controller = ScrollController();
    // listen for at end of list
    _controller.addListener(() {
      if (!dmodel.noSeason) {
        if (_controller.position.pixels >
            _controller.position.maxScrollExtent - 100) {
          // handle upcomming
          if (dmodel.currentScheduleTitle == "Upcoming" &&
              dmodel.hasMoreUpcomingEvents &&
              !dmodel.isFetchingEvents) {
            print("Load upcoming");
            dmodel.getMoreEvents(
              dmodel.tus!.team.teamId,
              dmodel.currentSeason!.seasonId,
              dmodel.user!.email,
              false,
            );
          } else if (dmodel.currentScheduleTitle == "Previous" &&
              dmodel.hasMorePreviousEvents &&
              !dmodel.isFetchingEvents) {
            print("Load previous");
            dmodel.getMoreEvents(
              dmodel.tus!.team.teamId,
              dmodel.currentSeason!.seasonId,
              dmodel.user!.email,
              true,
            );
          }
        }
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        cv.RefreshWrapper(
          controller: _controller,
          onRefresh: () async => _refreshAction(dmodel),
          topPadding: MediaQuery.of(context).viewPadding.top + 100,
          color: dmodel.color,
          child: Column(
            children: [
              // mock header to add padding
              Opacity(
                opacity: 0.001,
                child: Column(
                  children: [
                    SizedBox(
                        height: MediaQuery.of(context).viewPadding.top + 72),
                    Text(
                      "hello",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: CustomColors.textColor(context),
                      ),
                    ),
                  ],
                ),
              ),
              Stack(
                alignment: Alignment.topCenter,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: _body(context, dmodel),
                  ),
                ],
              ),
            ],
          ),
        ),
        _header(context, dmodel),
      ],
    );
  }

  Widget _header(BuildContext context, DataModel dmodel) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        cv.GlassContainer(
          backgroundColor: CustomColors.cellColor(context),
          borderRadius: BorderRadius.circular(0),
          opacity: 0.7,
          blur: 10,
          width: double.infinity,
          child: SafeArea(
            top: true,
            bottom: false,
            right: false,
            left: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // title with logo
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (dmodel.tus != null)
                              cv.BasicButton(
                                onTap: () {
                                  cv.showFloatingSheet(
                                    context: context,
                                    builder: (context) =>
                                        TeamModel(team: dmodel.tus!.team),
                                  );
                                },
                                child: TeamLogo(
                                  url: dmodel.tus!.team.image,
                                  size: 40,
                                  color: dmodel.color,
                                  borderRadius: 5,
                                ),
                              ),
                            const SizedBox(width: 8),
                            if (dmodel.currentSeason != null)
                              Expanded(
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: _seasonSelect(context, dmodel),
                                ),
                              ),
                          ],
                        ),
                      ),
                      Stack(
                        alignment: Alignment.topRight,
                        children: [
                          cv.BasicButton(
                            onTap: () {
                              if (dmodel.user != null) {
                                cv.cupertinoSheet(
                                    context: context,
                                    builder: (context) {
                                      return NotificationsView(
                                          user: dmodel.user!);
                                    });
                              }
                            },
                            child: Icon(
                              Icons.notifications_outlined,
                              color: dmodel.color,
                              size: 28,
                            ),
                          ),
                          if (dmodel.user?.notifications.isNotEmpty ?? false)
                            Transform.translate(
                              offset: const Offset(3, -3),
                              child: Material(
                                shadowColor: CustomColors.textColor(context),
                                borderRadius: BorderRadius.circular(6),
                                elevation: 2.0,
                                child: Container(
                                  height: 12,
                                  width: 12,
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 8),
                      if ((dmodel.currentSeasonUser?.isSeasonAdmin() ??
                              false ||
                                  (dmodel.tus?.user.isTeamAdmin() ?? false)) &&
                          dmodel.seasonUsers != null)
                        cv.BasicButton(
                          onTap: () {
                            cv.cupertinoSheet(
                                context: context,
                                wrapInNavigator: true,
                                builder: (context) {
                                  return ECERoot(
                                    isCreate: true,
                                    team: dmodel.tus!.team,
                                    season: dmodel.currentSeason!,
                                    user: dmodel.user!,
                                    teamUser: dmodel.tus!.user,
                                    seasonUser: dmodel.currentSeasonUser,
                                  );
                                });
                          },
                          child: Icon(
                            Icons.add,
                            color: dmodel.color,
                            size: 28,
                          ),
                        )
                      else if (dmodel.seasonUsers == null &&
                          !(dmodel.noTeam || dmodel.noSeason))
                        SizedBox(
                          height: 28,
                          width: 28,
                          child: cv.LoadingIndicator(
                            color: dmodel.color,
                          ),
                        )
                    ],
                  ),
                  const SizedBox(height: 8),
                  _timeToggle(context, dmodel),
                ],
              ),
            ),
          ),
        ),
        Divider(
          color: Colors.white.withValues(alpha: 0.1),
          indent: 0,
          height: 0.5,
        ),
      ],
    );
  }

  Widget _seasonSelect(BuildContext context, DataModel dmodel) {
    if (dmodel.noSeason || dmodel.noTeam) {
      return Container();
    } else {
      return cv.BasicButton(
        onTap: () {
          if (dmodel.currentSeason != null) {
            cv.showFloatingSheet(
              context: context,
              enableDrag: false,
              builder: (context) {
                return SeasonSelectAll(
                  team: dmodel.tus!.team,
                  onSelect: ((season, isPrevious) async {
                    await FirebaseAnalytics.instance.logEvent(
                      name: "change_season",
                      parameters: {"platform": "mobile"},
                    );
                    dmodel.setCurrentSeason(season, isPrevious: isPrevious);
                    dmodel.seasonUsers = null;
                    // Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  }),
                );
              },
            );
          }
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // season title
            Flexible(
              child: AutoSizeText(
                dmodel.currentSeason?.title ?? "",
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                minFontSize: 16,
                maxFontSize: 24,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: CustomColors.textColor(context),
                ),
              ),
            ),
            const SizedBox(width: 4),
            // icon to show this is clickable
            Transform.rotate(
              angle: math.pi * 1.5,
              child: Icon(
                Icons.chevron_left,
                color: CustomColors.textColor(context).withOpacity(0.5),
                size: 20,
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _timeToggle(BuildContext context, DataModel dmodel) {
    if (dmodel.noSeason || dmodel.noTeam) {
      return Container();
    } else {
      return Row(
        children: [
          cv.BasicButton(
            onTap: () => dmodel.toggleScheduleTitle(),
            child: Container(
              decoration: BoxDecoration(
                color: CustomColors.textColor(context).withOpacity(0.1),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                child: Text(
                  dmodel.currentScheduleTitle,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: CustomColors.textColor(context),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }
  }

  Widget _body(BuildContext context, DataModel dmodel) {
    if (dmodel.upcomingEvents != null) {
      return const ScheduleHome();
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
      if (dmodel.currentScheduleTitle == "Upcoming") {
        dmodel.upcomingEventsStartIndex = 0;
        await dmodel.getPagedEvents(
            dmodel.tus!.team.teamId,
            dmodel.currentSeason!.seasonId,
            dmodel.user!.email,
            0,
            false, (events) {
          dmodel.setUpcomingEvents(events);
        });
        await dmodel.getFuturePolls(
          dmodel.tus!.team.teamId,
          dmodel.currentSeason!.seasonId,
          dmodel.user!.email,
          (p0) => dmodel.setPolls(p0),
        );
      } else {
        dmodel.previousEventsStartIndex = 0;
        await dmodel.getPagedEvents(
            dmodel.tus!.team.teamId,
            dmodel.currentSeason!.seasonId,
            dmodel.user!.email,
            0,
            true, (events) {
          dmodel.setPreviousEvents(events);
        });
      }
    } else if (!dmodel.noTeam && dmodel.tus != null) {
      await dmodel.teamUserSeasonsGet(
          dmodel.tus!.team.teamId, dmodel.user!.email, (tus) {
        dmodel.setTUS(tus);
        return;
      });
    }
  }
}

class ScheduleHome extends StatefulWidget {
  const ScheduleHome({
    super.key,
  });

  @override
  State<ScheduleHome> createState() => _ScheduleHomeState();
}

class _ScheduleHomeState extends State<ScheduleHome> {
  @override
  void initState() {
    _handleDeepLink(context.read<DataModel>());
    super.initState();
  }

  void _handleDeepLink(DataModel dmodel) {
    if (dmodel.deepLink != null) {
      print("[DEEP LINK] handling the deep link");
      // check the upcoming events to see if the event id matches
      switch (dmodel.deepLink!.type) {
        case DeepLinkType.event:
          for (var event in dmodel.upcomingEvents!) {
            if (event.eventId == dmodel.deepLink!.args[2]) {
              log("deep link eventId matches an upcoming event, navigating to event");
              // navigate to the event
              SchedulerBinding.instance.addPostFrameCallback((_) {
                cv.Navigate(
                  context,
                  EventDetail2(
                    email: dmodel.user!.email,
                    event: event,
                    team: dmodel.tus!.team,
                    season: dmodel.currentSeason!,
                    isUpcoming: true,
                  ),
                );
              });
              dmodel.deepLink = null;
              return;
            } else {
              // TODO -- handle getting more upcoming events here and checking if it is any of them
            }
          }
          print(
              "no valid event was found in this season matching this deep link");
          break;
        case DeepLinkType.chat:
          // navigate to the chat page
          WidgetsBinding.instance.addPostFrameCallback((_) {
            dmodel.setScheduleIndex(3);
          });
          break;
        case DeepLinkType.settings:
          print("[DEEP LINK] SETTINGS PAGE DEEP LINK NO LONGER IMPLEMENTED");
          break;
        case DeepLinkType.none:
          print(
              "[DEEP LINK] the deep link type was not able to be ascertained");
          break;
      }
      dmodel.deepLink = null;
    } else {
      log("There was no deep link detected");
    }
  }

  @override
  Widget build(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    return Column(
      children: [
        if (dmodel.currentScheduleTitle == "Upcoming")
          if (dmodel.upcomingEvents?.isEmpty ?? true)
            if (dmodel.currentSeason!.seasonStatus > 0 &&
                (dmodel.tus!.user.isTeamAdmin() ||
                    (dmodel.currentSeasonUser?.isSeasonAdmin() ?? false)))
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Text(
                      "It looks like you have no events on this season yet. Either upload / paste the link of a webcal, or create an event with Crosscheck.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        color: CustomColors.textColor(context),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  cv.ListView<_MorePageItem>(
                    horizontalPadding: 0,
                    childPadding: const EdgeInsets.symmetric(horizontal: 16),
                    onChildTap: ((context, item) {
                      if (item.useSheet) {
                        cv.cupertinoSheet(
                          context: context,
                          builder: (context) {
                            return item.view;
                          },
                        );
                      } else {
                        cv.Navigate(context, item.view);
                      }
                    }),
                    childBuilder: ((context, item) {
                      return ConstrainedBox(
                        constraints: const BoxConstraints(minHeight: 50),
                        child: Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: item.color,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(4),
                                child: Icon(item.icon,
                                    size: 20, color: Colors.white),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                item.title,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: CustomColors.textColor(context),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Transform.rotate(
                              angle: item.useSheet ? -math.pi / 2 : 0,
                              child: Icon(
                                Icons.chevron_right_rounded,
                                color: CustomColors.textColor(context)
                                    .withOpacity(0.5),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    children: [
                      _MorePageItem(
                        title: "Calendar Upload",
                        color: Colors.blue,
                        icon: Icons.calendar_month_rounded,
                        useSheet: true,
                        view: UploadCalendar(
                          team: dmodel.tus!.team,
                          season: dmodel.currentSeason!,
                        ),
                      ),
                      _MorePageItem(
                        title: "Calendar Sync",
                        color: Colors.blue,
                        icon: Icons.event_repeat_rounded,
                        useSheet: true,
                        view: SyncCalendar(
                          team: dmodel.tus!.team,
                          season: dmodel.currentSeason!,
                        ),
                      ),
                      _MorePageItem(
                        title: "Create Event In App",
                        icon: Icons.design_services_rounded,
                        color: Colors.green,
                        useSheet: true,
                        view: ECERoot(
                          isCreate: true,
                          team: dmodel.tus!.team,
                          season: dmodel.currentSeason!,
                          user: dmodel.user!,
                          teamUser: dmodel.tus!.user,
                          seasonUser: dmodel.currentSeasonUser,
                        ),
                      ),
                    ],
                  ),
                ],
              )
            else
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
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 2,
                    child: comp.SubActionButton(
                      title: "Get More",
                      isLoading: dmodel.isFetchingEvents,
                      onTap: () {
                        dmodel.getMoreEvents(
                          dmodel.tus!.team.teamId,
                          dmodel.currentSeason!.seasonId,
                          dmodel.user!.email,
                          false,
                        );
                      },
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
    _getPreviousEvents(context.read<DataModel>());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    if (dmodel.previousEvents == null) {
      return const ScheduleLoading(
        includeHeader: false,
      );
    } else if (dmodel.previousEvents!.isEmpty) {
      return cv.NoneFound("There are no previous events", color: dmodel.color);
    } else {
      return Column(
        children: [
          EventList(
            list: dmodel.previousEvents!,
            isPrevious: true,
          ),
          const SizedBox(height: 32),
          if (dmodel.hasMorePreviousEvents)
            SizedBox(
              width: MediaQuery.of(context).size.width / 2,
              child: comp.SubActionButton(
                title: "Get More",
                isLoading: dmodel.isFetchingEvents,
                onTap: () {
                  dmodel.getMoreEvents(
                    dmodel.tus!.team.teamId,
                    dmodel.currentSeason!.seasonId,
                    dmodel.user!.email,
                    true,
                  );
                },
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
  const EventList({
    Key? key,
    required this.list,
    required this.isPrevious,
  }) : super(key: key);
  final List<Event> list;
  final bool isPrevious;

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
                    // const SizedBox(height: 16),
                    Row(
                      children: [
                        Text(
                          monthFromInt(eventDate.month).capitalize(),
                          style: TextStyle(
                            color: CustomColors.textColor(context)
                                .withOpacity(0.5),
                            fontSize: 25,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Divider(
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
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
                        team: dmodel.tus!.team,
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
            if (eventDate.day == previousDate.day &&
                eventDate.month == previousDate.month) {
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
                      team: dmodel.tus!.team,
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
                        // const SizedBox(height: 15),
                        Row(
                          children: [
                            Text(
                              monthFromInt(eventDate.month).capitalize(),
                              style: TextStyle(
                                  color: CustomColors.textColor(context)
                                      .withOpacity(0.5),
                                  fontSize: 25,
                                  fontWeight: FontWeight.w700),
                            ),
                            Divider(
                              color: Colors.white.withValues(alpha: 0.1),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
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
                          team: dmodel.tus!.team,
                          season: dmodel.currentSeason!,
                          isUpcoming: !widget.isPrevious,
                        ),
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

class _MorePageItem {
  _MorePageItem({
    required this.title,
    required this.icon,
    required this.view,
    required this.color,
    required this.useSheet,
  });
  final String title;
  final IconData icon;
  final Widget view;
  final bool useSheet;
  final Color color;
}

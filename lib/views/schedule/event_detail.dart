import 'dart:developer';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:crosscheck_sports/views/stats/team/root.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';

import '../../custom_views/root.dart' as cv;
import '../../data/root.dart';
import '../../client/root.dart';
import '../../extras/root.dart';
import '../root.dart';
import 'package:flutter/services.dart';

// import 'package:device_calendar/device_calendar.dart' as cal;

class EventUserModel extends ChangeNotifier {
  List<SeasonUser>? eventUsers;

  void setEventUsers(List<SeasonUser> users, {required bool showNicknames}) {
    // sort by nickname, then first name, then email
    eventUsers = sortSeasonUsers(users, showNicknames: showNicknames);
    notifyListeners();
  }
}

class EventDetail2 extends StatefulWidget {
  const EventDetail2({
    Key? key,
    required this.event,
    required this.email,
    required this.team,
    required this.season,
    required this.isUpcoming,
  }) : super(key: key);

  final Event event;
  final String email;
  final Team team;
  final Season season;
  final bool isUpcoming;

  @override
  State<EventDetail2> createState() => _EventDetail2State();
}

class _EventDetail2State extends State<EventDetail2> {
  @override
  void initState() {
    print(widget.team.teamId);
    print(widget.season.seasonId);
    print(widget.event.eventId);
    super.initState();
  }

  void logEvent() async {
    await FirebaseAnalytics.instance
        .setCurrentScreen(screenName: "event_detail");
  }

  @override
  Widget build(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    return ChangeNotifierProvider(
      create: (context) => EventUserModel(),
      builder: ((context, child) {
        return cv.AppBar(
          title: widget.event.getTitle(dmodel.tus!.team.title),
          isLarge: true,
          leading: [
            cv.BackButton(color: _accentColor(dmodel)),
          ],
          backgroundColor: CustomColors.backgroundColor(context),
          trailing: [_editButton(context, dmodel)],
          itemBarPadding: const EdgeInsets.fromLTRB(8, 0, 15, 8),
          childPadding: const EdgeInsets.fromLTRB(16, 16, 16, 48),
          children: [
            _body(context, dmodel),
          ],
        );
      }),
    );
  }

  Widget _body(BuildContext context, DataModel dmodel) {
    EventUserModel euModel = Provider.of<EventUserModel>(context);
    return Column(
      children: [
        _detailField(
          context,
          dmodel,
          Icons.schedule_outlined,
          "${widget.event.getDate()} · ${widget.event.getTime()}",
        ),
        _location(context, dmodel),
        if (widget.event.eDescription.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: _detailField(
              context,
              dmodel,
              Icons.description_outlined,
              widget.event.eDescription.trim(),
            ),
          ),
        if (widget.event.eventType == 1)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: EventScoreCell(
              event: widget.event,
              height: 50,
              iconSize: 28,
              defaultIconColor: _accentColor(dmodel),
            ),
          ),
        if (widget.event.eventType == 1 && !widget.event.overrideTitle)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: _detailField(context, dmodel, Icons.person_outline,
                widget.event.getOpponentTitle(widget.team.teamId)),
          ),
        if (widget.event.hasAttendance && widget.event.eventType == 1)
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: cv.BasicButton(
                  onTap: () {
                    if (euModel.eventUsers != null) {
                      cv.Navigate(
                        context,
                        EventLineup(
                          team: widget.team,
                          season: widget.season,
                          event: widget.event,
                          eventUsers: euModel.eventUsers!,
                          teamUser: dmodel.tus!.user,
                          seasonUser: dmodel.currentSeasonUser,
                        ),
                      );
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: CustomColors.cellColor(context),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(
                            Icons.group_work_rounded,
                            color: _accentColor(dmodel),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              "Game Lineup",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: CustomColors.textColor(context),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.chevron_right_rounded,
                            color: widget.event.textColor(context),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: _stats(context, dmodel),
              ),
            ],
          ),
        if (widget.event.hasAttendance)
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 16.0),
                child: Divider(indent: 0),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: _statusCounts(context, dmodel),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: _participants(context, dmodel),
              ),
            ],
          ),
      ],
    );
  }

  Widget _location(BuildContext context, DataModel dmodel) {
    if (widget.event.eventLocation.name.isEmpty()) {
      if (widget.event.eventLocation.address.isEmpty()) {
        return Container();
      } else {
        return Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: _detailField(
            context,
            dmodel,
            Icons.near_me_outlined,
            widget.event.eventLocation.address!,
          ),
        );
      }
    } else {
      if (widget.event.eventLocation.address.isEmpty()) {
        return Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: _detailField(
            context,
            dmodel,
            Icons.near_me_outlined,
            widget.event.eventLocation.name!,
          ),
        );
      } else {
        return Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: Row(
            children: [
              Icon(
                Icons.near_me_outlined,
                color: _accentColor(dmodel),
                size: 28,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.event.eventLocation.name!,
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.event.eventLocation.address!,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: CustomColors.textColor(context).withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }
    }
  }

  Widget _detailField(
      BuildContext context, DataModel dmodel, IconData icon, String title) {
    return Row(
      children: [
        Icon(
          icon,
          color: _accentColor(dmodel),
          size: 28,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: SelectableText(
            title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  Widget _participants(BuildContext context, DataModel dmodel) {
    if (dmodel.seasonUsers == null) {
      return cv.LoadingWrapper(
        child: Column(
          children: [
            for (int i = 0; i < 25; i++)
              Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: widget.event.cellColor(context),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: RosterLoadingCell(size: 40),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              )
          ],
        ),
      );
    } else {
      return EventDetailUsers(
        team: widget.team,
        season: widget.season,
        event: widget.event,
        isUpcoming: widget.isUpcoming,
        email: widget.email,
      );
    }
  }

  Widget _stats(BuildContext context, DataModel dmodel) {
    return Column(
      children: [
        cv.BasicButton(
          onTap: () {
            cv.Navigate(
              context,
              StatsEvent(
                team: dmodel.tus!.team,
                teamUser: dmodel.tus!.user,
                season: dmodel.currentSeason!,
                seasonUser: dmodel.currentSeasonUser!,
                event: widget.event,
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: CustomColors.cellColor(context),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.bar_chart,
                    color: _accentColor(dmodel),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      "Statistics",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: CustomColors.textColor(context),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: widget.event.textColor(context),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        cv.BasicButton(
          onTap: () {
            if (dmodel.currentSeasonUser?.isSeasonAdmin() ??
                false || dmodel.tus!.user.isTeamAdmin()) {
              cv.showFloatingSheet(
                context: context,
                builder: (context) {
                  return EventScore(
                      team: widget.team,
                      season: widget.season,
                      event: widget.event);
                },
              );
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: CustomColors.cellColor(context),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.sports_score,
                    color: _accentColor(dmodel),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      "Score",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: CustomColors.textColor(context),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: widget.event.textColor(context),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _statusCounts(BuildContext context, DataModel dmodel) {
    return Column(
      children: [
        if (dmodel.currentSeasonUser?.isSeasonAdmin() ??
            false || dmodel.tus!.user.isTeamAdmin())
          cv.BasicButton(
            onTap: () {
              cv.showFloatingSheet(
                context: context,
                builder: (context) {
                  return EventNotification(
                    teamId: widget.team.teamId,
                    seasonId: widget.season.seasonId,
                    event: widget.event,
                  );
                },
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: CustomColors.cellColor(context),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.mail_outline_rounded,
                      color: _accentColor(dmodel),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        "Send Check-in Reminder",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: CustomColors.textColor(context),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        const SizedBox(height: 8),
        EventStatuses(
          team: widget.team,
          season: widget.season,
          event: widget.event,
          textColor: CustomColors.textColor(context),
          backgroundColor: CustomColors.cellColor(context),
          height: 50,
          borderRadius: 10,
        ),
      ],
    );
  }

  Widget _editButton(BuildContext context, DataModel dmodel) {
    EventUserModel euModel = Provider.of<EventUserModel>(context);
    if (dmodel.currentSeasonUser?.isSeasonAdmin() ?? false) {
      return cv.BasicButton(
        onTap: () {
          if (euModel.eventUsers != null || !widget.event.hasAttendance) {
            cv.cupertinoSheet(
                context: context,
                wrapInNavigator: true,
                builder: ((context) {
                  return ECERoot(
                    isCreate: false,
                    team: widget.team,
                    season: widget.season,
                    teamUser: dmodel.tus!.user,
                    user: dmodel.user!,
                    seasonUser: dmodel.currentSeasonUser,
                    event: widget.event,
                    eventUsers: euModel.eventUsers,
                  );
                }));
          }
        },
        child: Text(
          "Edit",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: _accentColor(dmodel),
          ),
        ),
      );
    } else {
      return Container(height: 0);
    }
  }

  Color _accentColor(DataModel dmodel) {
    return widget.event.getColor() ?? dmodel.color;
  }
}

class EventDetail extends StatefulWidget {
  const EventDetail({
    Key? key,
    required this.event,
    required this.email,
    required this.team,
    required this.season,
    required this.isUpcoming,
  }) : super(key: key);

  final Event event;
  final String email;
  final Team team;
  final Season season;
  final bool isUpcoming;

  @override
  _EventDetailState createState() => _EventDetailState();
}

class _EventDetailState extends State<EventDetail> {
  @override
  void initState() {
    print(widget.team.teamId);
    print(widget.season.seasonId);
    print(widget.event.eventId);
    super.initState();
  }

  void logEvent() async {
    await FirebaseAnalytics.instance
        .setCurrentScreen(screenName: "event_detail");
  }

  @override
  Widget build(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    return ChangeNotifierProvider(
      create: (context) => EventUserModel(),
      builder: ((context, child) {
        return cv.AppBar(
          title: widget.event.getTitle(dmodel.tus!.team.title),
          isLarge: true,
          backgroundColor: widget.event.getColor()?.lighten(0.1) ??
              CustomColors.backgroundColor(context),
          color: _accentColor(dmodel),
          leading: [
            cv.BackButton(color: _accentColor(dmodel)),
          ],
          titleColor: widget.event.eventColor.isEmpty ? null : Colors.white,
          trailing: [_editButton(context, dmodel)],
          itemBarPadding: const EdgeInsets.fromLTRB(8, 0, 15, 8),
          // titlePadding: const EdgeInsets.only(left: 8),
          childPadding: const EdgeInsets.fromLTRB(16, 16, 16, 48),
          children: [
            _body(context, dmodel),
          ],
        );
      }),
    );
  }

  Widget _body(BuildContext context, DataModel dmodel) {
    EventUserModel euModel = Provider.of<EventUserModel>(context);
    return Column(
      children: [
        // _title(context, dmodel),
        // const SizedBox(height: 16),
        _detail2(context, dmodel),
        const SizedBox(height: 16),
        if (widget.event.eventType == 1 && euModel.eventUsers != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: cv.BasicButton(
              onTap: () {
                cv.Navigate(
                  context,
                  EventLineup(
                    team: widget.team,
                    season: widget.season,
                    event: widget.event,
                    eventUsers: euModel.eventUsers!,
                    teamUser: dmodel.tus!.user,
                    seasonUser: dmodel.currentSeasonUser,
                  ),
                );
              },
              child: cv.ListAppearance(
                backgroundColor: widget.event.cellColor(context),
                child: Row(
                  children: [
                    Icon(
                      Icons.format_list_bulleted_rounded,
                      color: _accentColor(dmodel).withOpacity(0.5),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        "Game Lineup",
                        style: TextStyle(
                          color: widget.event.textColor(context),
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: widget.event.textColor(context),
                    )
                  ],
                ),
              ),
            ),
          ),
        if (widget.event.customFields.isNotEmpty)
          Column(
            children: [
              _customFields(context, dmodel),
              const SizedBox(height: 16),
            ],
          ),
        if (widget.event.eventType == 1)
          Column(
            children: [
              _stats(context, dmodel),
              const SizedBox(height: 16),
            ],
          ),
        if (widget.event.hasAttendance)
          Column(
            children: [
              _statusCounts(context, dmodel),
              const SizedBox(height: 16),
            ],
          ),
        if (widget.event.hasAttendance) _participants(context, dmodel)
      ],
    );
  }

  Widget _detail2(BuildContext context, DataModel dmodel) {
    return cv.ListView<Widget>(
      backgroundColor: widget.event.cellColor(context),
      horizontalPadding: 0,
      childPadding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        // date
        _detailCell2(context, dmodel, Icons.calendar_today_outlined,
            widget.event.getDate()),
        // time
        _detailCell2(
            context, dmodel, Icons.schedule_outlined, widget.event.getTime()),
        // description
        if (widget.event.eDescription.isNotEmpty)
          _detailCell2(context, dmodel, Icons.description_outlined,
              widget.event.eDescription),
        // opponent
        if (widget.event.eventType == 1)
          _detailCell2(context, dmodel, Icons.person_outline,
              widget.event.getOpponentTitle(widget.team.teamId)),
        // location
        if (widget.event.eventLocation.name.isNotEmpty())
          _detailCell2(context, dmodel, Icons.location_on_outlined,
              widget.event.eventLocation.name!),
        // address
        if (widget.event.eventLocation.address.isNotEmpty())
          _detailCell2(context, dmodel, Icons.near_me_outlined,
              widget.event.eventLocation.address!),
        // score
        if (widget.event.eventType == 1)
          EventScoreCell(
            event: widget.event,
            height: 50,
            iconSize: 28,
            defaultIconColor: _accentColor(dmodel).withOpacity(0.5),
          ),
        // cv.BasicButton(
        //   onTap: () async {
        //     await initializeTimeZone();
        //     final loc = getLocation("America/Los_Angeles");
        //     final eventDate = widget.event.eventDate();
        //     var e = cal.Event(
        //       widget.event.eventId,
        //       title: widget.event.getTitle(),
        //       start: TZDateTime.from(
        //         eventDate,
        //         loc,
        //       ),
        //       end: TZDateTime.from(
        //         eventDate.add(const Duration(hours: 2)),
        //         loc,
        //       ),
        //     );
        //     if (widget.event.eventLocation.name.isNotEmpty()) {
        //       e.location = widget.event.eventLocation.name!;
        //     } else if (widget.event.eventLocation.address.isNotEmpty()) {
        //       e.location = widget.event.eventLocation.address!;
        //     }
        //     if (widget.event.eLink.isNotEmpty) {
        //       e.url = Uri.parse(widget.event.eLink);
        //     }
        //     print(e);
        //   },
        //   child: ConstrainedBox(
        //     constraints: const BoxConstraints(
        //       minHeight: 50,
        //     ),
        //     child: Center(
        //       child: Row(
        //         children: [
        //           Icon(
        //             Icons.calendar_month,
        //             color: _accentColor(dmodel).withOpacity(0.5),
        //             size: 28,
        //           ),
        //           const SizedBox(width: 8),
        //           Expanded(
        //             child: Text(
        //               "Add to Calendar",
        //               style: TextStyle(
        //                 color: widget.event.eventColor.isEmpty
        //                     ? CustomColors.textColor(context)
        //                     : Colors.white,
        //                 fontWeight: FontWeight.w600,
        //                 fontSize: 18,
        //               ),
        //             ),
        //           ),
        //         ],
        //       ),
        //     ),
        //   ),
        // ),
      ],
    );
  }

  Widget _detailCell2(
      BuildContext context, DataModel dmodel, IconData icon, String value) {
    return cv.BasicButton(
      onTap: () {
        Clipboard.setData(ClipboardData(text: value));
        dmodel.addIndicator(IndicatorItem.success("Successfully copied!"));
      },
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minHeight: 50,
        ),
        child: Center(
          child: Row(
            children: [
              Icon(
                icon,
                color: _accentColor(dmodel).withOpacity(0.5),
                size: 28,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  value,
                  style: TextStyle(
                    color: widget.event.textColor(context),
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _customFields(BuildContext context, DataModel dmodel) {
    return cv.ListView<CustomField>(
      backgroundColor: widget.event.cellColor(context),
      horizontalPadding: 0,
      children: widget.event.customFields,
      childPadding: const EdgeInsets.symmetric(horizontal: 16),
      childBuilder: (context, i) {
        return cv.LabeledCell(
          label: i.getTitle(),
          value: i.getValue(),
          textColor: widget.event.textColor(context),
        );
      },
    );
  }

  Widget _stats(BuildContext context, DataModel dmodel) {
    return cv.ListView<Tuple<IconData, String>>(
      children: [
        if (dmodel.currentSeason!.hasStats)
          Tuple(Icons.bar_chart, "Statistics"),
        if (dmodel.currentSeasonUser?.isSeasonAdmin() ??
            false || dmodel.tus!.user.isTeamAdmin())
          Tuple(Icons.sports_score, "Score"),
      ],
      childPadding: const EdgeInsets.symmetric(horizontal: 16),
      onChildTap: (context, item) {
        if (item.v2() == "Statistics") {
          cv.Navigate(
            context,
            StatsEvent(
              team: dmodel.tus!.team,
              teamUser: dmodel.tus!.user,
              season: dmodel.currentSeason!,
              seasonUser: dmodel.currentSeasonUser!,
              event: widget.event,
            ),
          );
        } else {
          if (dmodel.currentSeasonUser?.isSeasonAdmin() ??
              false || dmodel.tus!.user.isTeamAdmin()) {
            cv.showFloatingSheet(
              context: context,
              builder: (context) {
                return EventScore(
                    team: widget.team,
                    season: widget.season,
                    event: widget.event);
              },
            );
          }
        }
      },
      backgroundColor: widget.event.cellColor(context),
      horizontalPadding: 0,
      borderRadius: 10,
      childBuilder: (context, item) {
        return Row(
          children: [
            Icon(
              item.v1(),
              color: _accentColor(dmodel).withOpacity(0.5),
              size: 28,
            ),
            const SizedBox(width: 8, height: 50),
            Expanded(
              child: Text(
                item.v2(),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: widget.event.textColor(context),
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: widget.event.eventColor.isEmpty
                  ? dmodel.color.withOpacity(0.5)
                  : _accentColor(dmodel),
            ),
          ],
        );
      },
    );
  }

  Widget _statusCounts(BuildContext context, DataModel dmodel) {
    return Column(
      children: [
        if (dmodel.currentSeasonUser?.isSeasonAdmin() ??
            false || dmodel.tus!.user.isTeamAdmin())
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: cv.ListView<Widget>(
              backgroundColor: widget.event.cellColor(context),
              horizontalPadding: 0,
              borderRadius: 10,
              childPadding: const EdgeInsets.symmetric(horizontal: 16),
              onChildTap: (context, p1) {
                cv.showFloatingSheet(
                  context: context,
                  builder: (context) {
                    return EventNotification(
                      teamId: widget.team.teamId,
                      seasonId: widget.season.seasonId,
                      event: widget.event,
                    );
                  },
                );
              },
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.mail_outline_rounded,
                      color: _accentColor(dmodel).withOpacity(0.5),
                      size: 28,
                    ),
                    const SizedBox(width: 8, height: 50),
                    Text(
                      "Send Check-in Reminder",
                      style: TextStyle(
                        color: widget.event.textColor(context),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        EventStatuses(
          team: widget.team,
          season: widget.season,
          event: widget.event,
          textColor: widget.event.textColor(context),
          backgroundColor: widget.event.cellColor(context),
          height: 50,
          borderRadius: 10,
        ),
      ],
    );
  }

  Widget _participants(BuildContext context, DataModel dmodel) {
    if (dmodel.seasonUsers == null) {
      return cv.LoadingWrapper(
        child: Column(
          children: [
            for (int i = 0; i < 25; i++)
              Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: widget.event.cellColor(context),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: RosterLoadingCell(size: 40),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              )
          ],
        ),
      );
    } else {
      return EventDetailUsers(
        team: widget.team,
        season: widget.season,
        event: widget.event,
        isUpcoming: widget.isUpcoming,
        email: widget.email,
      );
    }
  }

  Widget _editButton(BuildContext context, DataModel dmodel) {
    EventUserModel euModel = Provider.of<EventUserModel>(context);
    if (dmodel.currentSeasonUser?.isSeasonAdmin() ?? false) {
      return cv.BasicButton(
        onTap: () {
          if (euModel.eventUsers != null || !widget.event.hasAttendance) {
            cv.cupertinoSheet(
                context: context,
                builder: (context) {
                  return ECERoot(
                    isCreate: false,
                    team: widget.team,
                    season: widget.season,
                    teamUser: dmodel.tus!.user,
                    user: dmodel.user!,
                    seasonUser: dmodel.currentSeasonUser,
                    event: widget.event,
                    eventUsers: euModel.eventUsers,
                  );
                });
          }
        },
        child: Text(
          "Edit",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: _accentColor(dmodel),
          ),
        ),
      );
    } else {
      return Container(height: 0);
    }
  }

  Color _accentColor(DataModel dmodel) {
    return widget.event.eventColor.isEmpty ? dmodel.color : Colors.white;
  }
}

class EventDetailUsers extends StatefulWidget {
  const EventDetailUsers({
    super.key,
    required this.team,
    required this.season,
    required this.event,
    required this.isUpcoming,
    required this.email,
  });
  final Team team;
  final Season season;
  final Event event;
  final bool isUpcoming;
  final String email;

  @override
  State<EventDetailUsers> createState() => _EventDetailUsersState();
}

class _EventDetailUsersState extends State<EventDetailUsers> {
  @override
  void initState() {
    _getUsers(context.read<DataModel>(), context.read<EventUserModel>());
    super.initState();
  }

  List<SeasonUser> _users(EventUserModel euModel) {
    var list = euModel.eventUsers!
        .where((element) => element.eventFields!.isParticipant)
        .toList();
    list.sort((a, b) => a.eventFields!.message.isNotEmpty() ? -1 : 1);

    return list;
  }

  @override
  Widget build(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    EventUserModel euModel = Provider.of<EventUserModel>(context);
    return Column(
      children: [
        if (euModel.eventUsers != null)
          for (SeasonUser i in _users(euModel))
            Column(
              children: [
                _userRow(context, dmodel, i),
                const SizedBox(height: 8),
              ],
            )
        else
          cv.LoadingWrapper(
            child: Column(
              children: [
                for (int i = 0; i < 25; i++)
                  Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: widget.event.cellColor(context),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: RosterLoadingCell(size: 40),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  )
              ],
            ),
          ),
      ],
    );
  }

  Future<void> _getUsers(DataModel dmodel, EventUserModel euModel) async {
    await dmodel.getEventUsers(
        widget.team.teamId, widget.season.seasonId, widget.event.eventId,
        (eventUsers) {
      List<SeasonUser> users = [];
      // loop through season users and compose list
      for (var i in eventUsers) {
        SeasonUser seasonUser = dmodel.seasonUsers!
            .firstWhere((element) => element.email == i.email, orElse: () {
          return SeasonUser.empty();
        });
        if (seasonUser.email.isNotEmpty) {
          SeasonUser u = SeasonUser.of(seasonUser);
          u.updateEventFields(i);
          users.add(u);
        }
      }
      euModel.setEventUsers(
        users,
        showNicknames: dmodel.tus!.team.showNicknames,
      );
    });
  }

  Widget _userRow(BuildContext context, DataModel dmodel, SeasonUser user) {
    EventUserModel euModel = Provider.of<EventUserModel>(context);
    return Container(
      decoration: BoxDecoration(
        color: CustomColors.cellColor(context),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 4, 16, 4),
            child: Row(
              children: [
                RosterAvatar(
                  name: user.name(widget.team.showNicknames),
                  seed: user.email,
                  size: 48,
                  fontSize: 24,
                ),
                const SizedBox(width: 8),
                Expanded(
                  // child: UserCell(user: user, season: widget.season),
                  child: Text(
                    user.name(widget.team.showNicknames),
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      color: CustomColors.textColor(context),
                    ),
                  ),
                ),

                // show their status, and only let the model open if it is them
                Opacity(
                  opacity: dmodel.user!.email == user.email ? 1 : 0.5,
                  child: EventUserStatus(
                    email: user.email,
                    status: user.eventFields!.eStatus,
                    event: widget.event,
                    showTitle: false,
                    onTap: () {
                      if ((user.email == widget.email &&
                              stringToDate(widget.event.eDate)
                                  .isAfter(DateTime.now())) ||
                          dmodel.currentSeasonUser!.isSeasonAdmin()) {
                        cv.showFloatingSheet(
                          context: context,
                          builder: (context) {
                            return StatusSelectSheet(
                              email: user.email,
                              teamId: widget.team.teamId,
                              event: widget.event,
                              isUpcoming: widget.isUpcoming,
                              season: widget.season,
                              completion: () {
                                _getUsers(dmodel, euModel);
                              },
                            );
                          },
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          // show a message icon if the user left a message
          if (!user.eventFields!.message.isEmpty())
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: CustomColors.textColor(context).withOpacity(0.2),
                  ),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 0, 8),
                  child: cv.BasicButton(
                    onTap: () {
                      cv.cupertinoSheet(
                          context: context,
                          builder: (context) {
                            return UserCommentSheet(
                              user: user,
                              event: widget.event,
                              email: widget.email,
                              team: widget.team,
                              season: widget.season,
                              completion: () {
                                // refresh user data when added reply
                                _getUsers(dmodel, euModel);
                              },
                            );
                          });
                    },
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: CustomColors.cellColor(context),
                                  shape: BoxShape.circle,
                                ),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(8, 8, 6, 6),
                                  child: Icon(
                                    Icons.chat_outlined,
                                    color:
                                        widget.event.getColor() ?? dmodel.color,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  user.eventFields!.message!,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: CustomColors.textColor(context)
                                        .withOpacity(0.7),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (user.eventFields!.statusReplies.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(left: 32),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  for (var i in user.eventFields!.statusReplies)
                                    _replyRow(
                                        context, dmodel, i.name, i.message),
                                ],
                              ),
                            )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          // show custom fields if different than default
          for (var i = 0; i < widget.event.customUserFields.length; i++)
            _customUserCell(
                context, user.email, user.eventFields!.customFields, i),
        ],
      ),
    );
  }

  Widget _replyRow(
      BuildContext context, DataModel dmodel, String name, String message) {
    return Text("- ${name}: ${message}",
        style: TextStyle(
          color: CustomColors.textColor(context).withOpacity(0.5),
          fontSize: 16,
        ));
  }

  Widget _customUserCell(
      BuildContext context, String email, List<CustomField> fields, int index) {
    if (widget.event.customUserFields.length != fields.length) {
      log("ISSUE | user: $email has different length custom fields compared to event.");
      return Container();
    } else {
      if (widget.event.customUserFields[index].getValue() !=
          fields[index].getValue()) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: cv.LabeledCell(
            label: fields[index].getTitle(),
            value: fields[index].getValue(),
          ),
        );
      } else {
        return Container();
      }
    }
  }
}

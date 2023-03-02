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
import 'package:crosscheck_sports/views/components/root.dart' as comp;

class EventLineup extends StatefulWidget {
  const EventLineup({
    super.key,
    required this.team,
    required this.season,
    required this.event,
    required this.teamUser,
    required this.eventUsers,
    this.seasonUser,
  });
  final Team team;
  final Season season;
  final Event event;
  final List<SeasonUser> eventUsers;
  final SeasonUserTeamFields teamUser;
  final SeasonUser? seasonUser;

  @override
  State<EventLineup> createState() => _EventLineupState();
}

class _EventLineupState extends State<EventLineup> {
  Lineup? _lineup;
  bool _isLoading = true;

  @override
  void initState() {
    _getLineup(context.read<DataModel>());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    return cv.AppBar(
      title: "Lineup",
      isLarge: true,
      titleColor: widget.event.eventColor.isEmpty ? null : Colors.white,
      backgroundColor: widget.event.getColor()?.lighten(0.1) ??
          CustomColors.backgroundColor(context),
      itemBarPadding: const EdgeInsets.fromLTRB(8, 0, 16, 8),
      leading: [cv.BackButton(color: _accentColor(dmodel))],
      trailing: [
        if ((widget.teamUser.isTeamAdmin() ||
                (widget.seasonUser?.isSeasonAdmin() ?? false)) &&
            _lineup != null)
          cv.BasicButton(
            onTap: () {
              cv.cupertinoSheet(
                  context: context,
                  builder: (context) {
                    return LineupRoot(
                      team: widget.team,
                      season: widget.season,
                      event: widget.event,
                      eventUsers: widget.eventUsers,
                      lineup: _lineup!,
                      onAction: (lineup) {
                        setState(() {
                          _lineup = lineup;
                        });
                      },
                    );
                  });
            },
            child: Text(
              "Edit",
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 18,
                color: _accentColor(dmodel),
              ),
            ),
          ),
      ],
      children: [_body(context, dmodel)],
    );
  }

  Widget _body(BuildContext context, DataModel dmodel) {
    if (_isLoading) {
      return Center(child: cv.LoadingIndicator(color: dmodel.color));
    } else if (_lineup == null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          cv.NoneFound(
            "This game does not have a lineup",
            textColor: widget.event.textColor(context),
            color: widget.event.getColor() ?? dmodel.color,
          ),
          if (widget.teamUser.isTeamAdmin() ||
              (widget.seasonUser?.isSeasonAdmin() ?? false))
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: cv.ListAppearance(
                backgroundColor: widget.event.cellColor(context),
                onTap: () {
                  cv.cupertinoSheet(
                      context: context,
                      builder: (context) {
                        return LineupRoot(
                          team: widget.team,
                          season: widget.season,
                          event: widget.event,
                          eventUsers: widget.eventUsers,
                          onAction: (lineup) {
                            setState(() {
                              _lineup = lineup;
                            });
                          },
                        );
                      });
                },
                child: Text(
                  "Create Lineup",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: widget.event.textColor(context),
                  ),
                ),
              ),
            ),
        ],
      );
    } else {
      return Column(
        children: [
          for (var i in _lineup!.lineupItems)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _lineupCell(context, dmodel, i),
            ),
          const SizedBox(height: 50),
        ],
      );
    }
  }

  Widget _lineupCell(BuildContext context, DataModel dmodel, LineupItem item) {
    return cv.Section(
      item.title,
      textColor: widget.event.textColor(context),
      child: cv.ListView<String>(
        horizontalPadding: 0,
        children: item.ids,
        backgroundColor: widget.event.cellColor(context),
        childPadding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        childBuilder: ((context, item) {
          var su = widget.eventUsers.firstWhere(
            (element) => element.email == item,
            orElse: () => SeasonUser.empty(),
          );
          if (su.email.isEmpty) {
            return Row(
              children: [
                cv.Circle(50, CustomColors.textColor(context).withOpacity(0.1)),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: CustomColors.textColor(context).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  height: 20,
                  width: MediaQuery.of(context).size.width / 2,
                ),
              ],
            );
          } else {
            return RosterCell(
              name: su.name(widget.team.showNicknames),
              type: RosterListType.none,
              backgroundColor: Colors.transparent,
              textColor: widget.event.textColor(context),
              seed: su.email,
              padding: EdgeInsets.zero,
              trailingWidget: EventUserStatus(
                email: su.email,
                status: su.eventFields!.eStatus,
                event: widget.event,
                onTap: () {},
                clickable: false,
              ),
            );
          }
        }),
      ),
    );
  }

  Future<void> _getLineup(DataModel dmodel) async {
    setState(() {
      _isLoading = true;
    });
    await dmodel.getLineup(
        widget.team.teamId, widget.season.seasonId, widget.event.eventId, (p0) {
      _lineup = p0;
    }, () {});
    setState(() {
      _isLoading = false;
    });
  }

  Color _accentColor(DataModel dmodel) {
    return widget.event.eventColor.isEmpty ? dmodel.color : Colors.white;
  }
}

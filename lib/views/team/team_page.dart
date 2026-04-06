import 'dart:math' as math;

import 'package:crosscheck_sports/components/layer/header_bar.dart';
import 'package:crosscheck_sports/components/layer/snapping_sheet.dart';
import 'package:crosscheck_sports/custom_views/section.dart';
import 'package:crosscheck_sports/views/polls/season_polls.dart';
import 'package:crosscheck_sports/views/root.dart';
import 'package:crosscheck_sports/views/roster/team_roster.dart';
import 'package:crosscheck_sports/views/season/event_duties/event_duty_create.dart';
import 'package:crosscheck_sports/views/season/future_warning.dart';
import 'package:crosscheck_sports/views/season/season_info.dart';
import 'package:crosscheck_sports/views/stats/team/stats_season.dart';
import 'package:crosscheck_sports/views/team/team_model.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../client/root.dart';
import '../../custom_views/root.dart' as cv;
import '../../data/root.dart';
import '../../extras/root.dart';

class SeasonPage extends StatefulWidget {
  const SeasonPage({super.key, required this.team, required this.teamUser});
  final Team team;
  final SeasonUserTeamFields teamUser;

  @override
  _SeasonPageState createState() => _SeasonPageState();
}

class _SeasonPageState extends State<SeasonPage> with TickerProviderStateMixin {
  // ignore: unused_field
  bool _isLoading = false;

  @override
  void initState() {
    _fetchSeasons(context.read<DataModel>());
    super.initState();
  }

  Future<void> _fetchSeasons(DataModel dmodel) async {
    setState(() {
      _isLoading = true;
    });
    await dmodel.getAllSeasons(widget.team.teamId, (p0) {
      setState(() {
        dmodel.allSeasons = p0;
      });
    });
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    return HeaderBar(
      title: "",
      backgroundColor: CustomColors.backgroundColor(context),
      horizontalPadding: 0.0,
      bottomPadding: 48.0,
      trailing:
          (dmodel.currentSeasonUser?.isTeamAdmin() ??
              dmodel.tus!.user.isTeamAdmin())
          ? cv.BasicButton(
              onTap: () {
                showSnappingSheet(
                  context: context,
                  child: SCERoot(
                    team: widget.team,
                    isCreate: false,
                    season: dmodel.currentSeason!,
                  ),
                );
              },
              child: Text(
                "Edit",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 18,
                  color: dmodel.color,
                ),
              ),
            )
          : null,
      // onRefresh: () => _refreshAction(dmodel),
      child: _body(context, dmodel),
    );
  }

  Widget _body(BuildContext context, DataModel dmodel) {
    return Column(
      children: [
        _logo(context, dmodel),
        const SizedBox(height: 16),
        if ((dmodel.currentSeason?.seasonStatus ?? -1) == 2)
          const FutureSeasonWarning(),
        if (dmodel.currentSeasonUser?.isTeamAdmin() ??
            dmodel.tus!.user.isTeamAdmin())
          _edit(context, dmodel),
        _seasonInfo(context, dmodel),
        _calendarInfo(context, dmodel),
        Padding(
          padding: EdgeInsets.all(16),
          child: Container(
            width: double.infinity,
            height: 1,
            color: CustomColors.textColor(context).withValues(alpha: 0.15),
          ),
        ),
        _teamInfo(context, dmodel),
        const SizedBox(height: 100),
        // Column(
        //   children: [
        //     const SizedBox(height: 16),
        //     _stats(context),
        //   ],
        // ),
      ],
    );
  }

  Widget _logo(BuildContext context, DataModel dmodel) {
    return Column(
      children: [
        if (dmodel.tus!.user.isTeamAdmin())
          cv.BasicButton(
            onTap: () {
              cv.showFloatingSheet(
                context: context,
                builder: (context) {
                  return TeamModel(team: widget.team);
                  // return ImageUploader(
                  //   team: widget.team,
                  //   imgIsUrl: widget.team.image
                  //       .contains("https://crosscheck-sports.s3.amazonaws.com"),
                  //   onImageChange: (img) {
                  //     setState(() {
                  //       widget.team.image = img;
                  //       dmodel.tus!.team.image = img;
                  //     });
                  //   },
                  // );
                },
              );
            },
            child: TeamLogo(
              url: widget.team.image,
              size: MediaQuery.of(context).size.width / 2,
              color: dmodel.color,
            ),
            // child: Stack(
            //   alignment: Alignment.bottomRight,
            //   children: [
            //     TeamLogo(
            //       url: widget.team.image,
            //       size: MediaQuery.of(context).size.width / 2,
            //       color: dmodel.color,
            //     ),
            // Padding(
            //   padding: const EdgeInsets.all(16.0),
            //   child: Icon(
            //     Icons.add_a_photo_outlined,
            //     color: CustomColors.textColor(context).withOpacity(0.5),
            //     size: 24,
            //   ),
            // )
            //   ],
            // ),
          )
        else
          TeamLogo(
            url: widget.team.image,
            size: MediaQuery.of(context).size.width / 2,
            color: dmodel.color,
          ),
        const SizedBox(height: 8),
        Text(
          widget.team.title,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        // season selector
        cv.BasicButton(
          onTap: () {
            if (dmodel.currentSeason != null) {
              showSnappingSheet(
                context: context,
                child: SeasonSelectAll(
                  team: dmodel.tus!.team,
                  onSelect: ((season, isPrevious) async {
                    await FirebaseAnalytics.instance.logEvent(
                      name: "change_season",
                      parameters: {"platform": "mobile"},
                    );
                    dmodel.setCurrentSeason(season, isPrevious: isPrevious);
                    dmodel.seasonUsers = null;
                    Navigator.of(context).pop();
                  }),
                ),
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // season title
                Flexible(
                  child: Text(
                    dmodel.currentSeason?.title ?? "",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
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
          ),
        ),
      ],
    );
  }

  Widget _edit(BuildContext context, DataModel dmodel) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: cv.Section(
        "Admin Control",
        child: cv.ListView<_ActionItem>(
          horizontalPadding: 0,
          childPadding: const EdgeInsets.symmetric(horizontal: 16),
          onChildTap: ((context, item) {
            showSnappingSheet(context: context, child: item.view);
          }),
          childBuilder: (context, item) {
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
                      child: Icon(item.icon, size: 20, color: Colors.white),
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
                    angle: -math.pi / 2,
                    child: Icon(
                      Icons.chevron_right_rounded,
                      color: CustomColors.textColor(context).withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            );
          },
          children: [
            _ActionItem(
              title: "Edit Season",
              icon: Icons.settings,
              color: Colors.blue[400]!,
              // view: SCERoot(
              //   team: widget.team,
              //   isCreate: true,
              // ),
              view: SCERoot(
                team: widget.team,
                isCreate: false,
                season: dmodel.currentSeason!,
              ),
              wrapInNavigator: true,
            ),
            if (dmodel.currentSeason != null && dmodel.seasonUsers != null)
              _ActionItem(
                title: "Event Duties",
                icon: Icons.task_alt_rounded,
                color: Colors.amber[400]!,
                view: EventDutyCreate(
                  team: widget.team,
                  season: dmodel.currentSeason!,
                  seasonUsers: dmodel.seasonUsers!,
                  eventDuties: dmodel.eventDuties,
                ),
                wrapInNavigator: true,
              ),
          ],
        ),
      ),
    );
  }

  Widget _seasonInfo(BuildContext context, DataModel dmodel) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Section(
        "Season",
        child: cv.ListView<_ActionItem>(
          horizontalPadding: 0,
          childPadding: const EdgeInsets.symmetric(horizontal: 16),
          onChildTap: ((context, item) {
            if (item.isSheet) {
              showSnappingSheet(context: context, child: item.view);
            } else {
              cv.Navigate(context, item.view);
            }
          }),
          childBuilder: (context, item) {
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
                      child: Icon(item.icon, size: 20, color: Colors.white),
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
                    angle: item.isSheet ? -math.pi / 2 : 0,
                    child: Icon(
                      Icons.chevron_right_rounded,
                      color: CustomColors.textColor(context).withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            );
          },
          children: [
            _ActionItem(
              title: "Season Information",
              icon: Icons.notes_rounded,
              color: Colors.deepOrange[300]!,
              view: SeasonInfo(season: dmodel.currentSeason!),
              wrapInNavigator: true,
            ),
            _ActionItem(
              title: "Roster",
              icon: Icons.people,
              color: Colors.red[300]!,
              view: const SeasonRoster(),
              wrapInNavigator: true,
            ),
            _ActionItem(
              title: "Polls",
              icon: Icons.ballot_rounded,
              color: Colors.purple[300]!,
              view: SeasonPolls(
                team: dmodel.tus!.team,
                season: dmodel.currentSeason!,
                teamUser: dmodel.tus!.user,
                seasonUser: dmodel.currentSeasonUser,
              ),
              wrapInNavigator: true,
            ),
            _ActionItem(
              title: "Stats",
              color: Colors.green,
              icon: Icons.equalizer_rounded,
              view: StatsSeason(
                team: widget.team,
                teamUser: dmodel.tus!.user,
                season: dmodel.currentSeason!,
                seasonUser: dmodel.currentSeasonUser,
              ),
              wrapInNavigator: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _teamInfo(BuildContext context, DataModel dmodel) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Section(
        "Team",
        child: cv.ListView<_ActionItem>(
          horizontalPadding: 0,
          childPadding: const EdgeInsets.symmetric(horizontal: 16),
          onChildTap: ((context, item) {
            if (item.isSheet) {
              showSnappingSheet(context: context, child: item.view);
            } else {
              cv.Navigate(context, item.view);
            }
          }),
          childBuilder: (context, item) {
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
                      child: Icon(item.icon, size: 20, color: Colors.white),
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
                    angle: item.isSheet ? -math.pi / 2 : 0,
                    child: Icon(
                      Icons.chevron_right_rounded,
                      color: CustomColors.textColor(context).withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            );
          },
          children: [
            if (dmodel.currentSeasonUser?.isTeamAdmin() ??
                dmodel.tus!.user.isTeamAdmin())
              _ActionItem(
                title: "Create New Season",
                icon: Icons.settings,
                color: Colors.blue[400]!,
                view: SCERoot(team: widget.team, isCreate: true),
                wrapInNavigator: true,
                isSheet: true,
              ),
            _ActionItem(
              title: "Team Roster",
              icon: Icons.people,
              color: Colors.green[400]!,
              view: TeamRoster(team: dmodel.tus!.team),
              wrapInNavigator: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _calendarInfo(BuildContext context, DataModel dmodel) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Section(
        "Calendar",
        child: cv.ListView<_ActionItem>(
          horizontalPadding: 0,
          childPadding: const EdgeInsets.symmetric(horizontal: 16),
          onChildTap: ((context, item) {
            if (item.isSheet) {
              showSnappingSheet(context: context, child: item.view);
            } else {
              cv.Navigate(context, item.view);
            }
          }),
          childBuilder: (context, item) {
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
                      child: Icon(item.icon, size: 20, color: Colors.white),
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
                    angle: item.isSheet ? -math.pi / 2 : 0,
                    child: Icon(
                      Icons.chevron_right_rounded,
                      color: CustomColors.textColor(context).withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            );
          },
          children: [
            _ActionItem(
              title: "Calendar Export",
              icon: Icons.exit_to_app_rounded,
              color: Colors.purple,
              isSheet: true,
              wrapInNavigator: true,
              view: ExportToCalendar(
                team: widget.team,
                season: dmodel.currentSeason!,
              ),
            ),
            if ((dmodel.tus!.user.isTeamAdmin()) ||
                (dmodel.currentSeasonUser?.isSeasonAdmin() ?? false))
              _ActionItem(
                title: "Calendar Upload",
                color: Colors.blue,
                icon: Icons.calendar_month_rounded,
                isSheet: true,
                wrapInNavigator: true,
                view: UploadCalendar(
                  team: dmodel.tus!.team,
                  season: dmodel.currentSeason!,
                ),
              ),
            if ((dmodel.tus!.user.isTeamAdmin()) ||
                (dmodel.currentSeasonUser?.isSeasonAdmin() ?? false))
              _ActionItem(
                title: "Calendar Sync",
                color: Colors.blue,
                icon: Icons.event_repeat_rounded,
                isSheet: true,
                wrapInNavigator: true,
                view: SyncCalendar(
                  team: dmodel.tus!.team,
                  season: dmodel.currentSeason!,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ActionItem {
  final String title;
  final IconData icon;
  final Color color;
  final Widget view;
  final bool wrapInNavigator;
  final bool isSheet;

  _ActionItem({
    required this.title,
    required this.icon,
    required this.color,
    required this.view,
    required this.wrapInNavigator,
    this.isSheet = false,
  });
}

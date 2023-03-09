import 'package:crosscheck_sports/data/root.dart';
import 'package:crosscheck_sports/extras/root.dart';
import 'package:crosscheck_sports/views/polls/root.dart';
import 'package:flutter/material.dart';
import 'package:crosscheck_sports/client/root.dart';
import 'package:crosscheck_sports/views/stats/team/root.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import '../root.dart';
import '../../custom_views/root.dart' as cv;
import 'dart:math' as math;

class MorePages extends StatefulWidget {
  const MorePages({
    super.key,
    required this.team,
    required this.season,
    required this.tus,
    this.seasonUser,
  });
  final Team? team;
  final Season? season;
  final TeamUserSeasons? tus;
  final SeasonUser? seasonUser;

  @override
  State<MorePages> createState() => _MorePagesState();
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

class _MorePagesState extends State<MorePages> {
  @override
  Widget build(BuildContext context) {
    return cv.AppBar(
      title: "More",
      isLarge: true,
      children: [_body(context)],
    );
  }

  Widget _body(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    return Column(
      children: [
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
                    angle: item.useSheet ? -math.pi / 2 : 0,
                    child: Icon(
                      Icons.chevron_right_rounded,
                      color: CustomColors.textColor(context).withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            );
          }),
          children: [
            _MorePageItem(
              title: "Account",
              icon: Icons.account_circle_rounded,
              color: Colors.grey,
              useSheet: false,
              view: Settings(user: dmodel.user!),
            ),
          ],
        ),
        if (widget.team != null && widget.season != null)
          cv.Section(
            "Pages",
            child: cv.ListView<_MorePageItem>(
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
                        angle: item.useSheet ? -math.pi / 2 : 0,
                        child: Icon(
                          Icons.chevron_right_rounded,
                          color:
                              CustomColors.textColor(context).withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              children: [
                _MorePageItem(
                  title: "Roster",
                  color: Colors.orange,
                  icon: Icons.group_rounded,
                  useSheet: false,
                  view: const SeasonRoster(),
                ),
                _MorePageItem(
                  title: "Stats",
                  color: Colors.green,
                  icon: Icons.equalizer_rounded,
                  useSheet: false,
                  view: StatsSeason(
                    team: widget.team!,
                    teamUser: widget.tus!.user,
                    season: widget.season!,
                    seasonUser: widget.seasonUser,
                  ),
                ),
                _MorePageItem(
                  title: "Season Page",
                  icon: Icons.ac_unit_rounded,
                  color: Colors.red,
                  useSheet: true,
                  view: SeasonHome(
                    team: widget.team!,
                    season: widget.season!,
                    teamUser: widget.tus!.user,
                    seasonUser: widget.seasonUser,
                  ),
                ),
              ],
            ),
          ),
        if (widget.team != null && widget.season != null)
          cv.Section(
            "Calendar Utils",
            child: cv.ListView<_MorePageItem>(
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
                        angle: item.useSheet ? -math.pi / 2 : 0,
                        child: Icon(
                          Icons.chevron_right_rounded,
                          color:
                              CustomColors.textColor(context).withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              children: [
                _MorePageItem(
                  title: "Calendar Export",
                  icon: Icons.exit_to_app_rounded,
                  color: Colors.purple,
                  useSheet: false,
                  view: ExportToCalendar(
                    team: widget.team!,
                    season: widget.season!,
                  ),
                ),
                if ((dmodel.tus!.user.isTeamAdmin()) ||
                    (dmodel.currentSeasonUser?.isSeasonAdmin() ?? false))
                  _MorePageItem(
                    title: "Calendar Upload",
                    color: Colors.blue,
                    icon: Icons.calendar_month_rounded,
                    useSheet: true,
                    view: UploadCalendar(
                      teamId: dmodel.tus!.team.teamId,
                      season: dmodel.currentSeason!,
                    ),
                  ),
                if ((dmodel.tus!.user.isTeamAdmin()) ||
                    (dmodel.currentSeasonUser?.isSeasonAdmin() ?? false))
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
              ],
            ),
          ),
      ],
    );
  }
}

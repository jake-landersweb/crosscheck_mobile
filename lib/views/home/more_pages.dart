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

class MorePages extends StatefulWidget {
  const MorePages({
    super.key,
    required this.team,
    required this.season,
    required this.tus,
    this.seasonUser,
  });
  final Team team;
  final Season season;
  final TeamUserSeasons tus;
  final SeasonUser? seasonUser;

  @override
  State<MorePages> createState() => _MorePagesState();
}

class _MorePageItem {
  _MorePageItem({
    required this.title,
    required this.icon,
    required this.view,
    required this.useSheet,
  });
  final String title;
  final IconData icon;
  final Widget view;
  final bool useSheet;
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
    return cv.ListView<_MorePageItem>(
      horizontalPadding: 0,
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
        return Row(
          children: [
            Icon(item.icon, color: dmodel.color),
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
            Icon(
              Icons.chevron_right_rounded,
              color: CustomColors.textColor(context).withOpacity(0.5),
            ),
          ],
        );
      }),
      children: [
        _MorePageItem(
          title: "Roster",
          icon: Icons.group_rounded,
          useSheet: false,
          view: const SeasonRoster(),
        ),
        _MorePageItem(
          title: "Stats",
          icon: Icons.equalizer_rounded,
          useSheet: false,
          view: StatsSeason(
            team: widget.team,
            teamUser: widget.tus.user,
            season: widget.season,
            seasonUser: widget.seasonUser,
          ),
        ),
        _MorePageItem(
          title: "Calendar Export",
          icon: Icons.calendar_month_rounded,
          useSheet: false,
          view: ExportToCalendar(
            team: widget.team,
            season: widget.season,
          ),
        ),
        if (dmodel.currentSeasonUser?.isSeasonAdmin() ?? false)
          _MorePageItem(
            title: "Calendar Upload",
            icon: Icons.calendar_month_rounded,
            useSheet: true,
            view: UploadCalendar(
              teamId: dmodel.tus!.team.teamId,
              seasonId: dmodel.currentSeason!.seasonId,
            ),
          ),
        if (dmodel.currentSeasonUser?.isSeasonAdmin() ?? false)
          _MorePageItem(
            title: "Calendar Sync",
            icon: Icons.calendar_month_rounded,
            useSheet: true,
            view: SyncCalendar(
              team: dmodel.tus!.team,
              season: dmodel.currentSeason!,
            ),
          ),
        _MorePageItem(
          title: "Season Page",
          icon: Icons.ac_unit_rounded,
          useSheet: true,
          view: SeasonHome(
            team: widget.team,
            season: widget.season,
            teamUser: widget.tus.user,
            seasonUser: widget.seasonUser,
            useRoot: true,
          ),
        ),
      ],
    );
  }
}

import 'package:crosscheck_sports/views/season/event_duties/event_duty_create.dart';
import 'package:crosscheck_sports/views/team/tce/image_uploader.dart';
import 'package:crosscheck_sports/views/team/team_model.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:crosscheck_sports/views/root.dart';
import 'package:crosscheck_sports/views/roster/team_roster.dart';
import 'package:crosscheck_sports/views/season/create/sce_template.dart';
import 'package:provider/provider.dart';
import '../../client/root.dart';
import '../../data/root.dart';
import '../../extras/root.dart';
import '../../custom_views/root.dart' as cv;
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import '../components/root.dart' as comp;
import 'dart:math' as math;

class TeamPage extends StatefulWidget {
  const TeamPage({
    Key? key,
    required this.team,
    required this.teamUser,
  }) : super(key: key);
  final Team team;
  final SeasonUserTeamFields teamUser;

  @override
  _TeamPageState createState() => _TeamPageState();
}

class _TeamPageState extends State<TeamPage> with TickerProviderStateMixin {
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
    return cv.AppBar(
      title: "",
      backgroundColor: CustomColors.backgroundColor(context),
      childPadding: const EdgeInsets.fromLTRB(0, 16, 0, 48),
      color: dmodel.color,
      trailing: [
        if (dmodel.currentSeasonUser?.isTeamAdmin() ??
            dmodel.tus!.user.isTeamAdmin())
          cv.BasicButton(
            onTap: () {
              cv.cupertinoSheet(
                context: context,
                builder: (context) => SCERoot(
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
      ],
      // onRefresh: () => _refreshAction(dmodel),
      children: [_body(context, dmodel)],
    );
  }

  Widget _body(BuildContext context, DataModel dmodel) {
    return Column(
      children: [
        _logo(context, dmodel),
        const SizedBox(height: 16),
        if (dmodel.currentSeasonUser?.isTeamAdmin() ??
            dmodel.tus!.user.isTeamAdmin())
          _edit(context, dmodel),
        _rosters(context, dmodel),
        if (dmodel.currentSeason != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                _basic(context, dmodel),
                if (dmodel.currentSeason!.positions.isActive)
                  Column(
                    children: [
                      const SizedBox(height: 16),
                      _teamPositions(context, dmodel),
                    ],
                  ),
                if (dmodel.currentSeason!.customFields.isNotEmpty)
                  Column(
                    children: [
                      const SizedBox(height: 16),
                      _customFields(context, dmodel),
                    ],
                  ),
                if (dmodel.currentSeason!.customUserFields.isNotEmpty)
                  Column(
                    children: [
                      const SizedBox(height: 16),
                      _customUserFields(context, dmodel),
                    ],
                  ),
                if (dmodel.currentSeason!.stats.isActive)
                  Column(
                    children: [
                      const SizedBox(height: 16),
                      _stats(context, dmodel),
                    ],
                  ),
              ],
            ),
          ),
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
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        // season selector
        cv.BasicButton(
          onTap: () {
            if (dmodel.currentSeason != null) {
              cv.showFloatingSheet(
                context: context,
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

  Widget _basic(BuildContext context, DataModel dmodel) {
    return cv.Section(
      "Season Info",
      child: Column(
        children: [
          cv.ListView<Widget>(
            horizontalPadding: 0,
            minHeight: 50,
            childPadding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              cv.LabeledCell(
                label: "Status",
                value: dmodel.currentSeason!.status(),
              ),
              cv.LabeledCell(
                label: "Timezone",
                value: dmodel.currentSeason!.timezone,
              ),
              if (dmodel.currentSeason!.website != "")
                cv.LabeledCell(
                  label: "Website",
                  value: dmodel.currentSeason!.website,
                  clickable: true,
                ),
              if (dmodel.currentSeason!.calendarUrl != "")
                cv.LabeledCell(
                  label: "Calendar",
                  value: dmodel.currentSeason!.calendarUrl,
                  clickable: true,
                ),
            ],
          )
        ],
      ),
    );
  }

  Widget _teamPositions(BuildContext context, DataModel dmodel) {
    return cv.Section(
      "Positions",
      child: cv.ListView<String>(
        minHeight: 50,
        children: dmodel.currentSeason!.positions.available,
        childPadding: const EdgeInsets.symmetric(horizontal: 16),
        horizontalPadding: 0,
        childBuilder: (context, position) {
          return cv.LabeledCell(
            label: position == dmodel.currentSeason!.positions.defaultPosition
                ? position == dmodel.currentSeason!.positions.mvp
                    ? "Mvp Default"
                    : "Default"
                : position == dmodel.currentSeason!.positions.mvp
                    ? "Mvp"
                    : "",
            value: position.capitalize(),
          );
        },
      ),
    );
  }

  Widget _customFields(BuildContext context, DataModel dmodel) {
    return cv.Section(
      "Custom Fields",
      child: cv.ListView<CustomField>(
        minHeight: 50,
        children: dmodel.currentSeason!.customFields,
        childPadding: const EdgeInsets.symmetric(horizontal: 16),
        horizontalPadding: 0,
        childBuilder: (context, i) {
          return cv.LabeledCell(
            height: cellHeight,
            label: i.getTitle(),
            value: i.getValue(),
          );
        },
      ),
    );
  }

  Widget _customUserFields(BuildContext context, DataModel dmodel) {
    return cv.Section(
      "Custom User Fields",
      child: cv.ListView<CustomField>(
        minHeight: 50,
        children: dmodel.currentSeason!.customUserFields,
        childPadding: const EdgeInsets.symmetric(horizontal: 16),
        horizontalPadding: 0,
        childBuilder: (context, i) {
          return cv.LabeledCell(
            height: cellHeight,
            label: i.getTitle(),
            value: "Default: ${i.getValue()}",
          );
        },
      ),
    );
  }

  Widget _stats(BuildContext context, DataModel dmodel) {
    return cv.Section(
      "Stats",
      child: cv.ListView<StatItem>(
        minHeight: 50,
        children: dmodel.currentSeason!.stats.stats,
        childPadding: const EdgeInsets.symmetric(horizontal: 16),
        horizontalPadding: 0,
        childBuilder: (context, i) {
          return cv.LabeledCell(
            height: cellHeight,
            label: "",
            value: i.getTitle(),
          );
        },
      ),
    );
  }

  Widget _edit(BuildContext context, DataModel dmodel) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: cv.Section(
        "",
        child: cv.ListView<_ActionItem>(
          horizontalPadding: 0,
          childPadding: const EdgeInsets.symmetric(horizontal: 16),
          onChildTap: ((context, item) {
            cv.cupertinoSheet(
              context: context,
              builder: (context) {
                return item.view;
              },
            );
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
              title: "Create New Season",
              icon: Icons.add_rounded,
              color: Colors.blue[400]!,
              view: SCERoot(
                team: widget.team,
                isCreate: true,
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

  Widget _rosters(BuildContext context, DataModel dmodel) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: cv.ListView<_ActionItem>(
        horizontalPadding: 0,
        childPadding: const EdgeInsets.symmetric(horizontal: 16),
        onChildTap: ((context, item) {
          cv.Navigate(context, item.view);
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
                Icon(
                  Icons.chevron_right_rounded,
                  color: CustomColors.textColor(context).withOpacity(0.5),
                ),
              ],
            ),
          );
        },
        children: [
          _ActionItem(
            title: "Team Roster",
            icon: Icons.people,
            color: Colors.green[400]!,
            view: TeamRoster(team: dmodel.tus!.team),
            wrapInNavigator: true,
          ),
          _ActionItem(
            title: "Season Roster",
            icon: Icons.people,
            color: Colors.red[300]!,
            view: const SeasonRoster(),
            wrapInNavigator: true,
          ),
        ],
      ),
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: cv.BasicButton(
        onTap: () {
          cv.Navigate(
            context,
            TeamRoster(team: dmodel.tus!.team),
          );
        },
        child: Container(
          constraints: const BoxConstraints(minHeight: 50),
          decoration: BoxDecoration(
            color: CustomColors.cellColor(context),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(Icons.people, color: dmodel.color),
                const SizedBox(width: 10),
                Expanded(
                    child: Text(
                  "Team Roster",
                  style: TextStyle(
                    fontSize: 18,
                    color: CustomColors.textColor(context),
                  ),
                )),
                const Icon(Icons.chevron_right_rounded),
              ],
            ),
          ),
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

  _ActionItem({
    required this.title,
    required this.icon,
    required this.color,
    required this.view,
    required this.wrapInNavigator,
  });
}

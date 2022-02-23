import 'package:flutter/material.dart';
import 'package:pnflutter/views/root.dart';
import 'package:pnflutter/views/roster/team_roster.dart';
import 'package:provider/provider.dart';
import '../../client/root.dart';
import '../../data/root.dart';
import '../../extras/root.dart';
import '../menu/root.dart';
import '../../custom_views/root.dart' as cv;
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class TeamPage extends StatefulWidget {
  const TeamPage({
    Key? key,
    required this.team,
    required this.seasons,
    required this.teamUser,
  }) : super(key: key);
  final Team team;
  final List<Season> seasons;
  final SeasonUserTeamFields teamUser;

  @override
  _TeamPageState createState() => _TeamPageState();
}

class _TeamPageState extends State<TeamPage> {
  @override
  Widget build(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    return cv.AppBar(
      title: "",
      isLarge: false,
      backgroundColor: CustomColors.backgroundColor(context),
      childPadding: const EdgeInsets.fromLTRB(0, 16, 0, 48),
      // refreshable: true,
      color: dmodel.color,
      leading: const [MenuButton()],
      trailing: [_edit(context, dmodel)],
      // onRefresh: () => _refreshAction(dmodel),
      children: [_body(context, dmodel)],
    );
  }

  Widget _body(BuildContext context, DataModel dmodel) {
    return Column(
      children: [
        _logo(context, dmodel),
        const SizedBox(height: 16),
        _basicInfo(context, dmodel),
        const SizedBox(height: 16),
        _rosterStats(context, dmodel),
        if (widget.teamUser.isTeamAdmin())
          Column(
            children: [
              const SizedBox(height: 16),
              _seasons(context, dmodel),
            ],
          ),
        if (widget.team.positions.isActive)
          Column(
            children: [
              const SizedBox(height: 16),
              _teamPositions(context, dmodel),
            ],
          ),
        if (widget.team.customFields.isNotEmpty)
          Column(
            children: [
              const SizedBox(height: 16),
              _customFields(context),
            ],
          ),
        if (widget.team.customUserFields.isNotEmpty)
          Column(
            children: [
              const SizedBox(height: 16),
              _customUserFields(context),
            ],
          ),
        Column(
          children: [
            const SizedBox(height: 16),
            _stats(context),
          ],
        ),
      ],
    );
  }

  Widget _logo(BuildContext context, DataModel dmodel) {
    return Column(
      children: [
        TeamLogo(
          url: widget.team.image,
          size: MediaQuery.of(context).size.width / 2,
        ),
        const SizedBox(height: 8),
        Text(
          widget.team.title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _basicInfo(BuildContext context, DataModel dmodel) {
    return cv.Section(
      "Basic Info",
      headerPadding: const EdgeInsets.fromLTRB(32, 8, 16, 4),
      allowsCollapse: true,
      initOpen: true,
      child: cv.ListView<Widget>(
        children: <Widget>[
          cv.LabeledCell(
            padding: EdgeInsets.zero,
            label: "Team Code",
            value: widget.team.teamCode,
          ),
          cv.LabeledCell(
            padding: EdgeInsets.zero,
            label: "Team Id",
            value: widget.team.teamId,
          ),
          if (widget.team.color != "")
            cv.LabeledCell(
              padding: EdgeInsets.zero,
              label: "Color",
              value: "#" + widget.team.color,
            ),
          if (!widget.team.teamNote.isEmpty())
            cv.LabeledCell(
              padding: EdgeInsets.zero,
              label: "Team Note",
              value: widget.team.teamNote!,
            ),
          cv.LabeledCell(
            padding: EdgeInsets.zero,
            label: "Is Light",
            value: widget.team.isLight ? "True" : "False",
          ),
          cv.LabeledCell(
            padding: EdgeInsets.zero,
            label: "Show Player Nicknames",
            value: widget.team.showNicknames ? "True" : "False",
          ),
        ],
      ),
    );
  }

  Widget _rosterStats(BuildContext context, DataModel dmodel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          cv.RoundedLabel(
            "Team Roster",
            color: CustomColors.cellColor(context),
            textColor: CustomColors.textColor(context),
            isNavigator: true,
            onTap: () {
              cv.Navigate(
                context,
                TeamRoster(team: dmodel.tus!.team, teamUser: dmodel.tus!.user),
              );
            },
          ),
          const SizedBox(height: 16),
          cv.RoundedLabel(
            "Team Stats",
            color: CustomColors.cellColor(context),
            textColor: CustomColors.textColor(context),
            isNavigator: true,
            onTap: () {
              cv.Navigate(
                context,
                StatsTeam(team: dmodel.tus!.team, teamUser: dmodel.tus!.user),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _seasons(BuildContext context, DataModel dmodel) {
    return cv.Section(
      "Seasons",
      headerPadding: const EdgeInsets.fromLTRB(32, 8, 16, 4),
      allowsCollapse: true,
      initOpen: true,
      child: Column(
        children: [
          if (widget.seasons.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: cv.RoundedLabel("No Seasons Here",
                  color: CustomColors.cellColor(context)),
            )
          else
            cv.ListView<Season>(
              childPadding: const EdgeInsets.fromLTRB(16, 4, 8, 4),
              onChildTap: (season) {
                showMaterialModalBottomSheet(
                  enableDrag: false,
                  context: context,
                  builder: (context) {
                    return SCERoot(
                        team: widget.team, isCreate: false, season: season);
                  },
                );
              },
              childBuilder: (context, season) {
                return SizedBox(
                  height: 45,
                  child: Row(
                    children: [
                      Text(
                        season.title,
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: CustomColors.textColor(context)),
                      ),
                      const Spacer(),
                      Text(
                        season.status(),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color:
                              CustomColors.textColor(context).withOpacity(0.5),
                        ),
                      ),
                      Icon(
                        Icons.more_vert,
                        color: CustomColors.textColor(context).withOpacity(0.5),
                      ),
                    ],
                  ),
                );
              },
              children: widget.seasons,
            ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: cv.RoundedLabel(
              "Create New Season",
              color: dmodel.color,
              textColor: Colors.white,
              onTap: () {
                showMaterialModalBottomSheet(
                  enableDrag: false,
                  context: context,
                  builder: (context) {
                    return SCERoot(isCreate: true, team: widget.team);
                  },
                );
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _teamPositions(BuildContext context, DataModel dmodel) {
    return cv.Section(
      "Positions",
      headerPadding: const EdgeInsets.fromLTRB(32, 8, 16, 4),
      allowsCollapse: true,
      initOpen: false,
      child: cv.ListView(
        children: widget.team.positions.available,
        childBuilder: (context, String pos) {
          return cv.LabeledCell(
            padding: EdgeInsets.zero,
            label:
                pos == widget.team.positions.defaultPosition ? "Default" : "",
            value: pos,
          );
        },
      ),
      // child: cv.NativeList(
      //   children: [
      //     for (var position in widget.team.positions.available)
      //       SizedBox(
      //         height: cellHeight,
      //         child: cv.LabeledCell(
      //           label: position == widget.team.positions.defaultPosition
      //               ? "Default"
      //               : "",
      //           value: position,
      //         ),
      //       ),
      //   ],
      // ),
    );
  }

  Widget _customFields(BuildContext context) {
    return cv.Section(
      "Custom Fields",
      allowsCollapse: true,
      headerPadding: const EdgeInsets.fromLTRB(32, 8, 16, 4),
      initOpen: false,
      child: cv.ListView(
        children: widget.team.customFields,
        childBuilder: (context, CustomField i) {
          return cv.LabeledCell(
            padding: EdgeInsets.zero,
            label: i.title,
            value: i.getValue(),
          );
        },
      ),
    );
  }

  Widget _customUserFields(BuildContext context) {
    return cv.Section(
      "Custom User Fields",
      allowsCollapse: true,
      headerPadding: const EdgeInsets.fromLTRB(32, 8, 16, 4),
      initOpen: false,
      child: cv.ListView(
          children: widget.team.customUserFields,
          childBuilder: (context, CustomField i) {
            return cv.LabeledCell(
              padding: EdgeInsets.zero,
              label: i.title,
              value: "Default: ${i.value}",
            );
          }),
    );
  }

  Widget _stats(BuildContext context) {
    return cv.Section(
      "Stats",
      headerPadding: const EdgeInsets.fromLTRB(32, 8, 16, 4),
      allowsCollapse: true,
      initOpen: false,
      child: cv.ListView(
          children: widget.team.stats.stats,
          childBuilder: (context, StatItem stat) {
            return cv.LabeledCell(
              padding: EdgeInsets.zero,
              height: cellHeight,
              label: "Title",
              value: stat.title,
            );
          }),
    );
  }

  Widget _edit(BuildContext context, DataModel dmodel) {
    if (widget.teamUser.isTeamAdmin()) {
      return cv.BasicButton(
        onTap: () {
          showMaterialModalBottomSheet(
            context: context,
            builder: (context) {
              return TCERoot(user: dmodel.user!, team: widget.team);
            },
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
      );
    } else {
      return Container();
    }
  }
}

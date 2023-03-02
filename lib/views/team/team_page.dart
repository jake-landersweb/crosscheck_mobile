import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:crosscheck_sports/views/root.dart';
import 'package:crosscheck_sports/views/roster/team_roster.dart';
import 'package:crosscheck_sports/views/season/create/sce_template.dart';
import 'package:provider/provider.dart';
import '../../client/root.dart';
import '../../data/root.dart';
import '../../extras/root.dart';
import '../menu/root.dart';
import '../../custom_views/root.dart' as cv;
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import '../components/root.dart' as comp;

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
    return Navigator(
      onGenerateRoute: (_) => MaterialPageRoute(
        builder: (context2) => Builder(
          builder: (context) => CupertinoPageScaffold(
            child: cv.AppBar.sheet(
              title: "",
              backgroundColor: CustomColors.backgroundColor(context),
              childPadding: const EdgeInsets.fromLTRB(0, 16, 0, 48),
              // refreshable: true,
              leading: [
                cv.BackButton(
                  color: dmodel.color,
                  showText: true,
                  useRoot: true,
                  title: "Close",
                  showIcon: false,
                )
              ],
              color: dmodel.color,
              trailing: [_edit(context, dmodel)],
              // onRefresh: () => _refreshAction(dmodel),
              children: [_body(context, dmodel)],
            ),
          ),
        ),
      ),
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
        childPadding: const EdgeInsets.symmetric(horizontal: 16),
        children: <Widget>[
          cv.LabeledCell(
            label: "Team Code",
            value: widget.team.teamCode,
          ),
          cv.LabeledCell(
            label: "Team Id",
            value: widget.team.teamId,
          ),
          if (widget.team.color != "")
            cv.LabeledCell(
              label: "Color",
              value: "#" + widget.team.color,
            ),
          if (widget.team.teamNote.isNotEmpty)
            cv.LabeledCell(
              label: "Team Note",
              value: widget.team.teamNote,
            ),
          cv.LabeledCell(
            label: "Is Light",
            value: widget.team.isLight ? "True" : "False",
          ),
          cv.LabeledCell(
            label: "Show Player Nicknames",
            value: widget.team.showNicknames ? "True" : "False",
          ),
          cv.LabeledCell(
            label: "Timezone",
            value: widget.team.timezone,
          ),
        ],
      ),
    );
  }

  Widget _rosterStats(BuildContext context, DataModel dmodel) {
    return Column(
      children: [
        cv.ListView<Widget>(
          childPadding: const EdgeInsets.symmetric(horizontal: 16),
          onChildTap: (context, p1) {
            // cv.Navigate(
            //   context,
            //   TeamRoster(team: dmodel.tus!.team, teamUser: dmodel.tus!.user),
            // );
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => TeamRoster(
                  team: dmodel.tus!.team,
                  teamUser: dmodel.tus!.user,
                ),
              ),
            );
          },
          children: [
            Row(
              children: [
                Text(
                  "All Time Roster",
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 18,
                    color: CustomColors.textColor(context),
                  ),
                ),
                const SizedBox(height: 50),
                const Spacer(),
                const Icon(Icons.chevron_right_rounded),
              ],
            ),
          ],
        ),
        // const SizedBox(height: 16),
        // cv.ListView<Widget>(
        //   childPadding: const EdgeInsets.symmetric(horizontal: 16),
        //   onChildTap: (context, p1) {
        //     cv.Navigate(
        //       context,
        //       StatsTeam(team: dmodel.tus!.team, teamUser: dmodel.tus!.user),
        //     );
        //   },
        //   children: [
        //     Row(
        //       children: [
        //         Text(
        //           "Team Stats",
        //           style: TextStyle(
        //             fontWeight: FontWeight.w500,
        //             fontSize: 18,
        //             color: CustomColors.textColor(context),
        //           ),
        //         ),
        //         const SizedBox(height: 50),
        //         const Spacer(),
        //         const Icon(Icons.chevron_right_rounded),
        //       ],
        //     ),
        //   ],
        // ),
      ],
    );
  }

  Widget _seasons(BuildContext context, DataModel dmodel) {
    return cv.Section(
      "Seasons",
      headerPadding: const EdgeInsets.fromLTRB(32, 8, 16, 4),
      allowsCollapse: true,
      initOpen: true,
      animateOpen: true,
      child: Column(
        children: [
          if (dmodel.allSeasons == null)
            if (_isLoading)
              cv.LoadingIndicator(color: dmodel.color)
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: cv.RoundedLabel("No Seasons Here",
                    color: CustomColors.cellColor(context)),
              )
          else
            cv.ListView<Season>(
              childPadding: const EdgeInsets.fromLTRB(16, 4, 8, 4),
              onChildTap: (context, season) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SeasonHome(
                      team: widget.team,
                      season: season,
                      teamUser: widget.teamUser,
                      seasonUser: dmodel.currentSeasonUser,
                    ),
                  ),
                );
              },
              childBuilder: (context, season) {
                return SizedBox(
                  height: 45,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          season.title,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: CustomColors.textColor(context),
                          ),
                        ),
                      ),
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
                        Icons.chevron_right_rounded,
                        color: CustomColors.textColor(context).withOpacity(0.5),
                      ),
                    ],
                  ),
                );
              },
              children: dmodel.allSeasons!,
            ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: comp.ActionButton(
              color: dmodel.color,
              title: "Create New Season",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        SCERoot(isCreate: true, team: widget.team),
                  ),
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
        childPadding: const EdgeInsets.symmetric(horizontal: 16),
        children: widget.team.positions.available,
        childBuilder: (context, String pos) {
          return cv.LabeledCell(
            label: pos == widget.team.positions.defaultPosition
                ? pos == widget.team.positions.mvp
                    ? "Mvp Default"
                    : "Default"
                : pos == widget.team.positions.mvp
                    ? "Mvp"
                    : "",
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
        childPadding: const EdgeInsets.symmetric(horizontal: 16),
        children: widget.team.customFields,
        childBuilder: (context, CustomField i) {
          return cv.LabeledCell(
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
          childPadding: const EdgeInsets.symmetric(horizontal: 16),
          children: widget.team.customUserFields,
          childBuilder: (context, CustomField i) {
            return cv.LabeledCell(
              label: i.title,
              value: "Default: ${i.value}",
            );
          }),
    );
  }

  // Widget _stats(BuildContext context) {
  //   return cv.Section(
  //     "Stats",
  //     headerPadding: const EdgeInsets.fromLTRB(32, 8, 16, 4),
  //     allowsCollapse: true,
  //     initOpen: false,
  //     child: cv.ListView(
  //         children: widget.team.stats.stats,
  //         childBuilder: (context, StatItem stat) {
  //           return cv.LabeledCell(
  //             padding: EdgeInsets.zero,
  //             height: cellHeight,
  //             label: "Title",
  //             value: stat.title,
  //           );
  //         }),
  //   );
  // }

  Widget _edit(BuildContext context, DataModel dmodel) {
    if (widget.teamUser.isTeamAdmin()) {
      return cv.BasicButton(
        onTap: () {
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) => TCERoot(
          //       user: dmodel.user!,
          //       team: widget.team,
          //       isCreate: false,
          //     ),
          //   ),
          // );
          cv.cupertinoSheet(
              context: context,
              builder: (context) {
                return TCERoot(
                  user: dmodel.user!,
                  team: widget.team,
                  isCreate: false,
                );
              });
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

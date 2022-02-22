import 'package:flutter/material.dart';
import 'package:pnflutter/client/root.dart';
import 'package:pnflutter/data/root.dart';
import 'package:pnflutter/extras/root.dart';
import 'package:pnflutter/views/root.dart';
import 'package:provider/provider.dart';
import '../../../custom_views/root.dart' as cv;

class StatsTeam extends StatefulWidget {
  const StatsTeam({
    Key? key,
    required this.team,
    required this.teamUser,
  }) : super(key: key);
  final Team team;
  final SeasonUserTeamFields teamUser;

  @override
  _StatsTeamState createState() => _StatsTeamState();
}

class _StatsTeamState extends State<StatsTeam> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<StatsTeamModel>(
      create: (_) => StatsTeamModel(widget.team),
      // we use `builder` to obtain a new `BuildContext` that has access to the provider
      builder: (context, child) {
        return _content(context);
      },
    );
  }

  Widget _content(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    StatsTeamModel smodel = Provider.of<StatsTeamModel>(context);
    return cv.AppBar(
      title: "Team Stats",
      isLarge: true,
      backgroundColor: CustomColors.backgroundColor(context),
      itemBarPadding: const EdgeInsets.fromLTRB(8, 0, 15, 8),
      color: dmodel.color,
      leading: [cv.BackButton(color: dmodel.color)],
      trailing: [
        if (widget.teamUser.isTeamAdmin() && !smodel.isLoading)
          _editButton(context, dmodel, smodel),
      ],
      onRefresh: () => smodel.userStatsGet(
          widget.team.teamId, (userStats) => smodel.setUserStats(userStats)),
      children: [
        _body(context, dmodel, smodel),
      ],
    );
  }

  Widget _body(BuildContext context, DataModel dmodel, StatsTeamModel smodel) {
    if (smodel.isLoading && smodel.userStats == null) {
      return const StatsUsersLoading();
    } else if (smodel.userStats == null) {
      return Text("There was a fatal issue fetching the stats");
    } else if (smodel.userStats!.isEmpty) {
      return Text("There were no users with stats found for this season");
    } else {
      return StatsUsersList(
        statList: smodel.userStats!,
        available: widget.team.stats.stats.map((e) => e.title).toList(),
      );
    }
  }

  Widget _editButton(
      BuildContext context, DataModel dmodel, StatsTeamModel smodel) {
    return cv.BasicButton(
      onTap: () {
        cv.showAlert(
            context: context,
            title: "WARNING: Editing Team Stats",
            body: const Text(
                "Are you sure you want to edit your base team stats? This can cause issues when calculating a user's stats for all seasons."),
            cancelText: "Cancel",
            cancelBolded: true,
            onCancel: () {},
            submitText: "I'm Sure",
            submitColor: Colors.red,
            onSubmit: () {
              cv.Navigate(
                context,
                StatsUsersEdit(
                  userStats: smodel.userStats!,
                  completion: (newList) async {
                    await _updateUsers(context, dmodel, smodel, newList);
                  },
                ),
              );
            });
      },
      child: Text(
        "Edit",
        style: TextStyle(
          color: dmodel.color,
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Future<void> _updateUsers(BuildContext context, DataModel dmodel,
      StatsTeamModel smodel, List<UserStat> newList) async {
    int status = 400;
    await smodel.updateUserList(
      widget.team.teamId,
      smodel.userStats!,
      newList,
      () async {
        status = 200;
      },
    );
    if (status == 200) {
      await smodel.userStatsGet(smodel.team.teamId, (userStats) {
        smodel.setUserStats(userStats);
      });
      Navigator.of(context).pop();
      dmodel.addIndicator(
          IndicatorItem.success("Successfully updated user stats"));
    } else {
      dmodel.addIndicator(
          IndicatorItem.error("There was an issue updating the user stats"));
    }
  }
}

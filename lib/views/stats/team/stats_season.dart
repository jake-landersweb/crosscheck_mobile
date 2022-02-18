import 'package:flutter/material.dart';
import 'package:pnflutter/client/root.dart';
import 'package:pnflutter/data/root.dart';
import 'package:pnflutter/extras/root.dart';
import 'package:pnflutter/views/root.dart';
import 'package:pnflutter/views/stats/team/root.dart';
import 'package:provider/provider.dart';
import '../../../custom_views/root.dart' as cv;

class StatsSeason extends StatefulWidget {
  const StatsSeason({
    Key? key,
    required this.team,
    required this.teamUser,
    required this.season,
    this.seasonUser,
  }) : super(key: key);
  final Team team;
  final SeasonUserTeamFields teamUser;
  final Season season;
  final SeasonUser? seasonUser;

  @override
  _StatsSeasonState createState() => _StatsSeasonState();
}

class _StatsSeasonState extends State<StatsSeason> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<StatsSeasonModel>(
      create: (_) => StatsSeasonModel(widget.team, widget.season),
      // we use `builder` to obtain a new `BuildContext` that has access to the provider
      builder: (context, child) {
        return _content(context);
      },
    );
  }

  Widget _content(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    StatsSeasonModel smodel = Provider.of<StatsSeasonModel>(context);
    return cv.AppBar(
      title: "${widget.season.title} Stats",
      isLarge: true,
      backgroundColor: CustomColors.backgroundColor(context),
      // refreshable: true,
      color: dmodel.color,
      leading: const [MenuButton()],
      trailing: [
        if ((widget.seasonUser?.isSeasonAdmin() ?? false) && !smodel.isLoading)
          _editButton(context, dmodel, smodel),
      ],
      onRefresh: () => smodel.userStatsGet(
          widget.team.teamId,
          widget.season.seasonId,
          (userStats) => smodel.setUserStats(userStats)),
      children: [
        _body(context, dmodel, smodel),
      ],
    );
  }

  Widget _body(
      BuildContext context, DataModel dmodel, StatsSeasonModel smodel) {
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
      BuildContext context, DataModel dmodel, StatsSeasonModel smodel) {
    return cv.BasicButton(
      onTap: () {
        cv.Navigate(
          context,
          StatsUsersEdit(
            userStats: smodel.userStats!,
            completion: (newList) async {
              await _updateUsers(context, dmodel, smodel, newList);
            },
          ),
        );
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
      StatsSeasonModel smodel, List<UserStat> newList) async {
    int status = 400;
    await smodel.updateUserList(
      widget.team.teamId,
      widget.season.seasonId,
      smodel.userStats!,
      newList,
      () async {
        status = 200;
      },
    );
    if (status == 200) {
      await smodel.userStatsGet(smodel.team.teamId, widget.season.seasonId,
          (userStats) {
        smodel.setUserStats(userStats);
      });
      Navigator.of(context).pop();
      dmodel.setSuccess("Successfully updated user stats", true);
    } else {
      dmodel.setError("There was an issue updating the user stats", true);
    }
  }
}

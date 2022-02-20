import 'package:flutter/material.dart';
import 'package:pnflutter/client/root.dart';
import 'package:pnflutter/data/root.dart';
import 'package:pnflutter/extras/root.dart';
import 'package:pnflutter/views/root.dart';
import 'package:pnflutter/views/stats/team/root.dart';
import 'package:provider/provider.dart';
import '../../../custom_views/root.dart' as cv;

class StatsEvent extends StatefulWidget {
  const StatsEvent({
    Key? key,
    required this.team,
    required this.teamUser,
    required this.season,
    required this.seasonUser,
    required this.event,
  }) : super(key: key);
  final Team team;
  final SeasonUserTeamFields teamUser;
  final Season season;
  final SeasonUser seasonUser;
  final Event event;

  @override
  _StatsEventState createState() => _StatsEventState();
}

class _StatsEventState extends State<StatsEvent> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<StatsEventModel>(
      create: (_) => StatsEventModel(widget.team, widget.season, widget.event),
      // we use `builder` to obtain a new `BuildContext` that has access to the provider
      builder: (context, child) {
        return _content(context);
      },
    );
  }

  Widget _content(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    StatsEventModel smodel = Provider.of<StatsEventModel>(context);
    return cv.AppBar(
      title: "",
      isLarge: false,
      backgroundColor: CustomColors.backgroundColor(context),
      // refreshable: true,
      color: dmodel.color,
      itemBarPadding: const EdgeInsets.fromLTRB(8, 0, 15, 8),
      leading: [cv.BackButton(color: dmodel.color)],
      trailing: [
        if (widget.seasonUser.isSeasonAdmin() && !smodel.isLoading)
          _editButton(context, dmodel, smodel),
      ],
      onRefresh: () => smodel.userStatsGet(
        widget.team.teamId,
        widget.season.seasonId,
        widget.event.eventId,
        (userStats) => smodel.setUserStats(userStats),
      ),
      children: [
        _title(context, dmodel),
        const SizedBox(height: 16),
        _body(context, dmodel, smodel),
      ],
    );
  }

  Widget _title(BuildContext context, DataModel dmodel) {
    return Row(
      children: [
        Expanded(
          child: Text(
            widget.event.getTitle(),
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: CustomColors.textColor(context),
            ),
          ),
        ),
      ],
    );
  }

  Widget _body(BuildContext context, DataModel dmodel, StatsEventModel smodel) {
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
      BuildContext context, DataModel dmodel, StatsEventModel smodel) {
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
      StatsEventModel smodel, List<UserStat> newList) async {
    int status = 400;
    await smodel.updateUserList(widget.team.teamId, widget.season.seasonId,
        widget.event.eventId, smodel.userStats!, newList, () async {
      status = 200;
    });
    if (status == 200) {
      await smodel.userStatsGet(
          smodel.team.teamId, widget.season.seasonId, widget.event.eventId,
          (userStats) {
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

import 'package:flutter/material.dart';
import 'package:pnflutter/client/root.dart';
import 'package:pnflutter/data/root.dart';
import 'package:pnflutter/extras/root.dart';
import 'package:pnflutter/views/root.dart';
import 'package:provider/provider.dart';
import '../../custom_views/root.dart' as cv;
import 'root.dart';

class TeamStats extends StatefulWidget {
  const TeamStats({
    Key? key,
    required this.team,
  }) : super(key: key);
  final Team team;

  @override
  _TeamStatsState createState() => _TeamStatsState();
}

class _TeamStatsState extends State<TeamStats> {
  List<UserStat> stats = [];

  @override
  void initState() {
    super.initState();
    _fetchStats(context.read<DataModel>());
  }

  @override
  Widget build(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    return cv.AppBar(
      title: "Team Stats",
      isLarge: true,
      backgroundColor: CustomColors.backgroundColor(context),
      // refreshable: true,
      color: dmodel.color,
      leading: const [MenuButton()],
      trailing: [],
      // onRefresh: () => _refreshAction(dmodel),
      children: [
        _body(context, dmodel),
      ],
    );
  }

  Widget _body(BuildContext context, DataModel dmodel) {
    if (stats.isEmpty) {
      return const cv.LoadingIndicator();
    } else {
      return StatsUserList(statList: stats, team: widget.team);
    }
  }

  Future<void> _fetchStats(DataModel dmodel) async {
    await dmodel.teamStatsGet(widget.team.teamId, (userList) {
      setState(() {
        stats = userList;
        print("successfully fetched");
      });
    });
  }
}

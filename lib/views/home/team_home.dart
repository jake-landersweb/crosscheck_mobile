import 'package:flutter/material.dart';
import 'package:pnflutter/client/root.dart';
import 'package:pnflutter/data/root.dart';
import 'package:pnflutter/views/chat/season_chat.dart';
import 'package:pnflutter/views/roster/team_roster.dart';
import 'package:pnflutter/views/stats/team/root.dart';
import 'package:provider/provider.dart';
import '../root.dart';
import '../../custom_views/root.dart' as cv;

class TeamHome extends StatefulWidget {
  const TeamHome({Key? key}) : super(key: key);

  @override
  _TeamHomeState createState() => _TeamHomeState();
}

class _TeamHomeState extends State<TeamHome> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          _currentPage(context, dmodel),
          Column(
            children: [
              const Spacer(),
              cv.TabBar(
                index: index,
                icons: const [Icons.bar_chart, Icons.people],
                color: dmodel.color,
                onViewChange: (idx) {
                  setState(() {
                    index = idx;
                  });
                },
              ),
              // _tabBar(context, dmodel),
            ],
          ),
        ],
      ),
    );
  }

  Widget _currentPage(BuildContext context, DataModel dmodel) {
    switch (index) {
      case 0:
        if (dmodel.tus != null) {
          return StatsTeam(team: dmodel.tus!.team, teamUser: dmodel.tus!.user);
        } else {
          return Container();
        }
      case 1:
        if (dmodel.tus != null) {
          return TeamRoster(team: dmodel.tus!.team, teamUser: dmodel.tus!.user);
        } else {
          return Container();
        }

      default:
        return Container();
    }
  }
}

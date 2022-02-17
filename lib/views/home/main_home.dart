import 'package:flutter/material.dart';
import 'package:pnflutter/client/root.dart';
import 'package:pnflutter/views/chat/season_chat.dart';
import 'package:pnflutter/views/stats/team/root.dart';
import 'package:provider/provider.dart';
import '../root.dart';
import '../../custom_views/root.dart' as cv;

class MainHome extends StatefulWidget {
  const MainHome({Key? key}) : super(key: key);

  @override
  _MainHomeState createState() => _MainHomeState();
}

class _MainHomeState extends State<MainHome> {
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
                icons: const [
                  Icons.home,
                  Icons.chat,
                  Icons.bar_chart,
                  Icons.people
                ],
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
        return const Schedule();
      case 1:
        if (dmodel.currentSeason != null && dmodel.currentSeasonUser != null) {
          return SizedBox(
            height: MediaQuery.of(context).size.height -
                (MediaQuery.of(context).viewPadding.bottom + 40),
            child: ChatHome(
              team: dmodel.tus!.team,
              season: dmodel.currentSeason!,
              user: dmodel.user!,
              seasonUser: dmodel.currentSeasonUser!,
            ),
          );
        } else {
          return Padding(
            padding: const EdgeInsets.only(top: 50),
            child:
                cv.NoneFound("Cannot find the chat room.", color: dmodel.color),
          );
        }
      case 2:
        if (dmodel.currentSeason != null) {
          return StatsSeason(
            team: dmodel.tus!.team,
            teamUser: dmodel.tus!.user,
            season: dmodel.currentSeason!,
            seasonUser: dmodel.currentSeasonUser,
          );
        } else {
          return Container();
        }
      case 3:
        return const SeasonRoster();
      default:
        return Container();
    }
  }
}

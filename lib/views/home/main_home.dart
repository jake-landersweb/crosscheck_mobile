import 'package:flutter/material.dart';
import 'package:pnflutter/client/root.dart';
import 'package:pnflutter/extras/root.dart';
import 'package:pnflutter/views/chat/season_chat.dart';
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
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        _currentPage(context, dmodel),
        _tabBar(context, dmodel),
      ],
    );
  }

  Widget _currentPage(BuildContext context, DataModel dmodel) {
    switch (index) {
      case 0:
        return const Schedule();
      case 1:
        if (dmodel.currentSeason != null && dmodel.currentSeasonUser != null) {
          return ChatHome(
            team: dmodel.tus!.team,
            season: dmodel.currentSeason!,
            user: dmodel.user!,
            seasonUser: dmodel.currentSeasonUser!,
          );
          // return SeasonRoster(
          //   team: dmodel.tus!.team,
          //   season: dmodel.currentSeason!,
          //   seasonUsers: dmodel.seasonUsers!,
          //   teamUser: dmodel.tus!.user,
          //   isOnTeam: true,
          // );
        } else {
          return Container();
        }
      case 2:
        if (dmodel.tus != null) {
          return TeamStats(team: dmodel.tus!.team);
        } else {
          return Container();
        }
      default:
        return Container();
    }
  }

  Widget _tabBar(BuildContext context, DataModel dmodel) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Divider(
          height: 0.5,
          indent: 0,
          endIndent: 0,
          color: CustomColors.textColor(context).withOpacity(0.3),
        ),
        cv.GlassContainer(
          width: double.infinity,
          borderRadius: BorderRadius.circular(0),
          backgroundColor: CustomColors.backgroundColor(context),
          opacity: 0.9,
          blur: 15,
          height: MediaQuery.of(context).padding.bottom + 40,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _tabBarItem(context, dmodel, 0, Icons.home),
              _tabBarItem(context, dmodel, 1, Icons.person),
              _tabBarItem(context, dmodel, 2, Icons.bar_chart),
            ],
          ),
        ),
      ],
    );
  }

  Widget _tabBarItem(
      BuildContext context, DataModel dmodel, int idx, IconData icon) {
    return Padding(
      padding:
          EdgeInsets.fromLTRB(32, 0, 32, MediaQuery.of(context).padding.bottom),
      child: cv.BasicButton(
        onTap: () {
          setState(() {
            index = idx;
          });
        },
        child: Icon(
          icon,
          color: index == idx
              ? dmodel.color
              : CustomColors.textColor(context).withOpacity(0.5),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:crosscheck_sports/client/root.dart';
import 'package:provider/provider.dart';
import '../root.dart';
import '../../custom_views/root.dart' as cv;

class MainHome extends StatefulWidget {
  const MainHome({super.key});

  @override
  _MainHomeState createState() => _MainHomeState();
}

class _MainHomeState extends State<MainHome> {
  @override
  Widget build(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 50.0),
            child: _currentPage(context, dmodel),
          ),
          Column(
            children: [
              const Spacer(),
              if (dmodel.currentSeason?.seasonStatus == 2 &&
                  ((dmodel.currentSeasonUser?.isSeasonAdmin() ?? false) ||
                      (dmodel.tus?.user.isTeamAdmin() ?? false)))
                Container(
                  width: double.infinity,
                  color: Colors.red.withOpacity(0.3),
                  child: const Padding(
                    padding: EdgeInsets.all(4.0),
                    child: Center(
                      child:
                          Text("Future seasons are not visible to your users."),
                    ),
                  ),
                ),
              cv.TabBar(
                index: dmodel.scheduleIndex,
                icons: const [
                  Icons.home_rounded,
                  Icons.calendar_month_rounded,
                  Icons.forum_rounded,
                  Icons.account_circle_rounded,
                ],
                titles: const [
                  "Season",
                  "Schedule",
                  "Chat",
                  "Account",
                ],
                color: dmodel.color,
                onViewChange: (idx) {
                  dmodel.setScheduleIndex(idx);
                },
                extraTapArgs: ((context, icon, isSelected) {
                  if (icon.codePoint == Icons.forum_rounded.codePoint &&
                      dmodel.showUnreadBadge == true) {
                    dmodel.setChatBadge(false);
                  } else if (icon.codePoint == Icons.ballot_rounded.codePoint &&
                      dmodel.showPollBadge) {
                    dmodel.setPollBadge(false);
                  }
                }),
                hasBadge: (p0) {
                  if (dmodel.noSeason) {
                    return false;
                  } else {
                    if (dmodel.showUnreadBadge && p0 == 2) {
                      return true;
                    } else if (dmodel.showPollBadge && p0 == 0) {
                      return true;
                    } else {
                      return false;
                    }
                  }
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
    switch (dmodel.scheduleIndex) {
      case 0:
        if (dmodel.tus != null) {
          return SeasonPage(
            team: dmodel.tus!.team,
            teamUser: dmodel.tus!.user,
          );
        } else {
          return Container();
        }
      case 1:
        return const Schedule();
      case 2:
        if (dmodel.currentSeason == null) {
          return Container();
        } else {
          return SizedBox(
            height: MediaQuery.of(context).size.height -
                (MediaQuery.of(context).viewPadding.bottom + 40),
            child: ChatHome(
              team: dmodel.tus!.team,
              user: dmodel.user!,
            ),
          );
        }
      case 3:
        return Settings(user: dmodel.user!);
      default:
        return Container();
    }
  }
}

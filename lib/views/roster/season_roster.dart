import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../root.dart';
import '../../client/root.dart';
import '../../data/root.dart';
import '../../custom_views/root.dart' as cv;

class SeasonRoster extends StatefulWidget {
  const SeasonRoster({Key? key}) : super(key: key);

  @override
  _SeasonRosterState createState() => _SeasonRosterState();
}

class _SeasonRosterState extends State<SeasonRoster> {
  @override
  void initState() {
    super.initState();
    _checkRoster(context.read<DataModel>());
  }

  @override
  Widget build(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    return cv.AppBar(
      title: "Roster",
      isLarge: true,
      refreshable: true,
      leading: const MenuButton(),
      actions: [
        if (dmodel.currentSeasonUser?.isSeasonAdmin() ?? false)
          cv.BasicButton(
            onTap: () {
              cv.Navigate(
                context,
                SeasonUserEdit(
                  team: dmodel.tus!.team,
                  user: SeasonUser.empty(),
                  teamId: dmodel.tus!.team.teamId,
                  seasonId: dmodel.currentSeason!.seasonId,
                  completion: () {},
                  isAdd: true,
                ),
              );
            },
            child: Icon(Icons.add, color: dmodel.color),
          ),
      ],
      onRefresh: () => _refreshAction(dmodel),
      children: [
        _body(context, dmodel),
      ],
    );
  }

  Widget _body(BuildContext context, DataModel dmodel) {
    if (dmodel.seasonUsers == null) {
      // show loading
      return cv.NativeList(
        children: [
          for (int i = 0; i < 15; i++) const UserCellLoading(),
        ],
      );
    } else {
      if (dmodel.seasonUsers!.isEmpty) {
        return const Padding(
          padding: EdgeInsets.only(top: 20),
          child: Text(
            "There are no users a part of this season",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
        );
      } else {
        Iterable<SeasonUser> active = dmodel.seasonUsers!
            .where((element) => element.seasonFields!.seasonUserStatus == 1);
        Iterable<SeasonUser> subs = dmodel.seasonUsers!
            .where((element) => element.seasonFields!.seasonUserStatus == 2);
        Iterable<SeasonUser> recruits = dmodel.seasonUsers!.where((element) =>
            element.seasonFields!.seasonUserStatus == 3 ||
            element.seasonFields!.seasonUserStatus == 5);
        Iterable<SeasonUser> invited = dmodel.seasonUsers!.where((element) =>
            element.seasonFields!.seasonUserStatus == 4 ||
            element.seasonFields!.seasonUserStatus == 6);
        Iterable<SeasonUser> inactive = dmodel.seasonUsers!
            .where((element) => element.seasonFields!.seasonUserStatus == -1);
        Iterable<SeasonUser> unknown = dmodel.seasonUsers!
            .where((element) => element.seasonFields!.seasonUserStatus == null);
        return Column(children: [
          if (active.isNotEmpty)
            cv.Section(
              "Active",
              child: cv.NativeList(
                children: [
                  for (SeasonUser i in active) _rosterCell(context, i, dmodel),
                ],
              ),
            ),
          if (subs.isNotEmpty)
            cv.Section(
              "Subs",
              child: cv.NativeList(
                children: [
                  for (SeasonUser i in subs) _rosterCell(context, i, dmodel),
                ],
              ),
            ),
          if (recruits.isNotEmpty)
            cv.Section(
              "Recruits",
              child: cv.NativeList(
                children: [
                  for (SeasonUser i in recruits)
                    _rosterCell(context, i, dmodel),
                ],
              ),
            ),
          if (invited.isNotEmpty)
            cv.Section(
              "Invited",
              child: cv.NativeList(
                children: [
                  for (SeasonUser i in invited) _rosterCell(context, i, dmodel),
                ],
              ),
            ),
          if (inactive.isNotEmpty)
            cv.Section(
              "Inactive",
              child: cv.NativeList(
                children: [
                  for (SeasonUser i in inactive)
                    _rosterCell(context, i, dmodel),
                ],
              ),
            ),
          if (unknown.isNotEmpty)
            cv.Section(
              "Unknown",
              child: cv.NativeList(
                children: [
                  for (SeasonUser i in unknown) _rosterCell(context, i, dmodel),
                ],
              ),
            ),
          const SizedBox(height: 48),
        ]);
      }
    }
  }

  Widget _rosterCell(BuildContext context, SeasonUser user, DataModel dmodel) {
    return cv.BasicButton(
      onTap: () {
        cv.Navigate(
          context,
          SeasonUserDetail(
            user: user,
            teamId: dmodel.tus!.team.teamId,
            seasonId: dmodel.currentSeason!.seasonId,
          ),
        );
      },
      child: UserCell(
        user: user,
        isClickable: true,
      ),
    );
  }

  void _checkRoster(DataModel dmodel) async {
    if (dmodel.seasonUsers == null) {
      await dmodel.getSeasonRoster(
          dmodel.tus!.team.teamId, dmodel.currentSeason!.seasonId, (users) {
        dmodel.setSeasonUsers(users);
      });
    } else {
      print('already have roster');
    }
  }

  Future<void> _refreshAction(DataModel dmodel) async {
    if (dmodel.currentSeason != null) {
      await dmodel.getSeasonRoster(
          dmodel.tus!.team.teamId, dmodel.currentSeason!.seasonId, (users) {
        dmodel.setSeasonUsers(users);
      });
    }
  }
}

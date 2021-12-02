import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../extras/root.dart';

import '../../client/root.dart';
import '../../data/root.dart';
import '../../custom_views/root.dart' as cv;
import '../menu/root.dart';
import 'root.dart';
import '../shared/root.dart';

class SeasonRoster extends StatefulWidget {
  const SeasonRoster({
    Key? key,
    required this.team,
    required this.season,
    required this.seasonUsers,
    this.currentSeasonUser,
    required this.teamUser,
    required this.isOnTeam,
  }) : super(key: key);
  final Team team;
  final Season season;
  final List<SeasonUser>? seasonUsers;
  final SeasonUser? currentSeasonUser;
  final SeasonUserTeamFields teamUser;
  final bool isOnTeam;

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
      backgroundColor: CustomColors.backgroundColor(context),
      refreshable: true,
      color: dmodel.color,
      leading: const [MenuButton()],
      trailing: [
        if (widget.currentSeasonUser?.isSeasonAdmin() ??
            false || widget.teamUser.isTeamAdmin())
          cv.BasicButton(
            onTap: () {
              cv.Navigate(
                context,
                SeasonUserEdit(
                  team: widget.team,
                  user: SeasonUser.empty(),
                  teamId: widget.team.teamId,
                  season: widget.season,
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
    if (widget.seasonUsers == null) {
      // show loading
      return cv.NativeList(
        children: [
          for (int i = 0; i < 15; i++) const UserCellLoading(),
        ],
      );
    } else {
      if (widget.seasonUsers!.isEmpty) {
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
        Iterable<SeasonUser> active = widget.seasonUsers!
            .where((element) => element.seasonFields!.seasonUserStatus == 1);
        Iterable<SeasonUser> subs =
            widget.seasonUsers!.where((element) => element.seasonFields!.isSub);
        Iterable<SeasonUser> recruits = widget.seasonUsers!.where((element) =>
            element.seasonFields!.seasonUserStatus == 3 &&
            !element.seasonFields!.isSub);
        Iterable<SeasonUser> invited = widget.seasonUsers!.where((element) =>
            element.seasonFields!.seasonUserStatus == 4 &&
            !element.seasonFields!.isSub);
        Iterable<SeasonUser> inactive = widget.seasonUsers!.where((element) =>
            element.seasonFields!.seasonUserStatus == -1 &&
            !element.seasonFields!.isSub);
        Iterable<SeasonUser> unknown = widget.seasonUsers!
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
            season: widget.season,
            user: user,
            teamId: dmodel.tus!.team.teamId,
            seasonId: dmodel.currentSeason!.seasonId,
          ),
        );
      },
      child: UserCell(
        user: user,
        isClickable: true,
        season: widget.season,
      ),
    );
  }

  void _checkRoster(DataModel dmodel) async {
    if (widget.seasonUsers == null) {
      await dmodel.getSeasonRoster(
          dmodel.tus!.team.teamId, widget.season.seasonId, (users) {
        if (widget.isOnTeam) {
          dmodel.setSeasonUsers(users);
        }
      });
    } else {
      print('already have roster');
    }
  }

  Future<void> _refreshAction(DataModel dmodel) async {
    await dmodel.getSeasonRoster(
        dmodel.tus!.team.teamId, widget.season.seasonId, (users) {
      if (widget.isOnTeam) {
        dmodel.setSeasonUsers(users);
      }
    });
  }
}

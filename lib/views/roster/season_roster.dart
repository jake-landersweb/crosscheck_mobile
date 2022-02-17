import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:pnflutter/client/root.dart';
import 'package:pnflutter/data/root.dart';
import 'package:pnflutter/views/root.dart';
import 'package:provider/provider.dart';
import 'package:pnflutter/extras/root.dart';
import '../../custom_views/root.dart' as cv;

class SeasonRoster extends StatefulWidget {
  const SeasonRoster({Key? key}) : super(key: key);

  @override
  _SeasonRosterState createState() => _SeasonRosterState();
}

class _SeasonRosterState extends State<SeasonRoster> {
  @override
  Widget build(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    return cv.AppBar(
      title: "Roster",
      isLarge: true,
      refreshable: false,
      backgroundColor: CustomColors.backgroundColor(context),
      color: dmodel.color,
      trailing: [_createUser(context, dmodel)],
      leading: const [MenuButton()],
      children: [
        // season selector
        if (dmodel.seasonUsers != null)
          RosterList(
            users: dmodel.seasonUsers!,
            team: dmodel.tus!.team,
            type: RosterListType.navigator,
            onNavigate: (user) {
              cv.Navigate(
                context,
                RosterUserDetail(
                  team: dmodel.tus!.team,
                  season: dmodel.currentSeason!,
                  seasonUser: user,
                  teamUser: dmodel.tus!.user,
                  appSeasonUser: dmodel.currentSeasonUser,
                  onUserEdit: (body) async {
                    await dmodel.seasonUserUpdate(
                      dmodel.tus!.team.teamId,
                      dmodel.currentSeason!.seasonId,
                      user.email,
                      body,
                      (seasonUser) async {
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                        // get latest season roster data
                        setState(() {
                          dmodel.seasonUsers = null;
                        });
                        await dmodel.getSeasonRoster(
                          dmodel.tus!.team.teamId,
                          dmodel.currentSeason!.seasonId,
                          (p0) => dmodel.setSeasonUsers(p0),
                        );
                      },
                    );
                  },
                ),
              );
            },
          )
        else
          const RosterLoading(),
      ],
    );
  }

  Widget _createUser(BuildContext context, DataModel dmodel) {
    if (dmodel.currentSeason != null) {
      if (dmodel.currentSeasonUser?.isSeasonAdmin() ??
          dmodel.tus!.user.isTeamAdmin()) {
        return cv.BasicButton(
          onTap: () {
            showMaterialModalBottomSheet(
              context: context,
              builder: (context) {
                return SeasonUserAdd(
                  team: dmodel.tus!.team,
                  teamUser: dmodel.tus!.user,
                  season: dmodel.currentSeason!,
                  seasonUser: dmodel.currentSeasonUser!,
                );
              },
            );
          },
          child: Icon(Icons.add, color: dmodel.color),
        );
      } else {
        return Container();
      }
    } else {
      return Container();
    }
  }
}

class SeasonUserAdd extends StatefulWidget {
  const SeasonUserAdd({
    Key? key,
    required this.team,
    required this.teamUser,
    required this.season,
    required this.seasonUser,
  }) : super(key: key);
  final Team team;
  final SeasonUserTeamFields teamUser;
  final Season season;
  final SeasonUser seasonUser;

  @override
  _SeasonUserAddState createState() => _SeasonUserAddState();
}

class _SeasonUserAddState extends State<SeasonUserAdd> {
  @override
  Widget build(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    return cv.AppBar(
      title: "Add User",
      isLarge: true,
      refreshable: false,
      backgroundColor: CustomColors.backgroundColor(context),
      color: dmodel.color,
      leading: [
        cv.BackButton(
          color: dmodel.color,
          showIcon: false,
          showText: true,
          title: "Cancel",
        ),
      ],
      children: [
        cv.Section(
          "Existing Users",
          child: cv.RoundedLabel(
            "Team Roster List (not implemented)",
            color: CustomColors.cellColor(context),
            textColor: CustomColors.textColor(context),
            isNavigator: true,
          ),
        ),
        const SizedBox(height: 16),
        cv.Section(
          "New User",
          child: cv.RoundedLabel(
            "Create User",
            color: CustomColors.cellColor(context),
            textColor: CustomColors.textColor(context),
            isNavigator: true,
            onTap: () => cv.Navigate(
              context,
              _newUser(context, dmodel),
            ),
          ),
        ),
      ],
    );
  }

  Widget _newUser(BuildContext context, DataModel dmodel) {
    return RUCERoot(
      team: widget.team,
      season: widget.season,
      isCreate: true,
      hasBackButton: true,
      onFunction: (body) async {
        // create the season user
        await dmodel.seasonUserAdd(
            widget.team.teamId, widget.season.seasonId, body, (seasonUser) {
          // add the user to this list
          Navigator.of(context).pop();
          Navigator.of(context).pop();
          setState(() {
            dmodel.seasonUsers!.add(seasonUser);
          });
        });
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:pnflutter/client/root.dart';
import 'package:pnflutter/data/root.dart';
import 'package:pnflutter/views/root.dart';
import 'package:provider/provider.dart';
import 'package:pnflutter/extras/root.dart';
import '../../custom_views/root.dart' as cv;

class TeamRoster extends StatefulWidget {
  const TeamRoster({
    Key? key,
    required this.team,
    this.teamUser,
  }) : super(key: key);
  final Team team;
  final SeasonUserTeamFields? teamUser;

  @override
  _TeamRosterState createState() => _TeamRosterState();
}

class _TeamRosterState extends State<TeamRoster> {
  List<SeasonUser>? _users;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchUsers(context, context.read<DataModel>());
  }

  @override
  void dispose() {
    _users = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    return cv.AppBar(
      title: "Roster",
      isLarge: true,
      refreshable: false,
      backgroundColor: CustomColors.backgroundColor(context),
      color: dmodel.color,
      itemBarPadding: const EdgeInsets.fromLTRB(8, 0, 15, 8),
      trailing: [_createUser(context, dmodel)],
      leading: [cv.BackButton(color: dmodel.color)],
      children: [
        // season selector
        if (_isLoading)
          const RosterLoading()
        else if (_users != null)
          Column(
            children: [
              _rosterBase(context, dmodel, _active(context, dmodel)),
              if (_users!
                  .any((element) => element.teamFields!.validationStatus == 0))
                cv.Section(
                  "Non Validated",
                  child: _rosterBase(
                    context,
                    dmodel,
                    _notValidated(context, dmodel),
                  ),
                ),
              if (_users!
                  .any((element) => element.teamFields!.validationStatus == 2))
                cv.Section(
                  "Invited",
                  child: _rosterBase(
                    context,
                    dmodel,
                    _invited(context, dmodel),
                  ),
                ),
            ],
          )
        else
          Container(
            child: Text("There was an issue getting the team roster"),
          ),
      ],
    );
  }

  Widget _rosterBase(
      BuildContext context, DataModel dmodel, List<SeasonUser> users) {
    return RosterList(
      users: users,
      team: dmodel.tus!.team,
      type: RosterListType.navigator,
      onNavigate: (user) {
        cv.Navigate(
          context,
          RosterUserDetail(
            team: dmodel.tus!.team,
            seasonUser: user,
            teamUser: dmodel.tus!.user,
            onDelete: () async {
              setState(() {
                _isLoading = true;
                _users = null;
              });
              if (dmodel.seasonUsers != null) {
                dmodel.seasonUsers = null;
                dmodel.getSeasonRoster(
                  widget.team.teamId,
                  dmodel.currentSeason!.seasonId,
                  (p0) => dmodel.setSeasonUsers(p0),
                );
              }
              await _fetchUsers(context, dmodel);
            },
            onUserEdit: (body) async {
              // print(body);
              await dmodel.seasonUserUpdate(
                dmodel.tus!.team.teamId,
                dmodel.currentSeason!.seasonId,
                user.email,
                body,
                () async {
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
    );
  }

  List<SeasonUser> _active(BuildContext context, DataModel dmodel) {
    if (_users != null) {
      return _users!
          .where((element) => element.teamFields!.validationStatus == 1)
          .toList();
    } else {
      return [];
    }
  }

  List<SeasonUser> _notValidated(BuildContext context, DataModel dmodel) {
    if (_users != null) {
      return _users!
          .where((element) => element.teamFields!.validationStatus == 0)
          .toList();
    } else {
      return [];
    }
  }

  List<SeasonUser> _invited(BuildContext context, DataModel dmodel) {
    if (_users != null) {
      return _users!
          .where((element) => element.teamFields!.validationStatus == 2)
          .toList();
    } else {
      return [];
    }
  }

  Widget _createUser(BuildContext context, DataModel dmodel) {
    if (widget.teamUser?.isTeamAdmin() ?? false) {
      return cv.BasicButton(
        onTap: () {
          showMaterialModalBottomSheet(
            context: context,
            builder: (context) {
              return RUCERoot(
                team: dmodel.tus!.team,
                isCreate: true,
                onFunction: (body) async {
                  // create the season user
                  // await dmodel.seasonUserAdd(dmodel.tus!.team.teamId,
                  //     dmodel.currentSeason!.seasonId, body, (seasonUser) {
                  //   // add the user to this list
                  //   Navigator.of(context).pop();
                  //   setState(() {
                  //     dmodel.seasonUsers!.add(seasonUser);
                  //   });
                  // });
                  await dmodel.createTeamUser(widget.team.teamId, body,
                      (user) async {
                    Navigator.of(context).pop();
                    await _fetchUsers(context, dmodel);
                  });
                },
              );
            },
          );
        },
        child: Icon(Icons.add, color: dmodel.color),
      );
    } else {
      return Container();
    }
  }

  Future<void> _fetchUsers(BuildContext context, DataModel dmodel) async {
    setState(() {
      _isLoading = true;
    });

    await dmodel.getTeamRoster(widget.team.teamId, (users) {
      setState(() {
        _users = users;
      });
    });

    setState(() {
      _isLoading = false;
    });
  }
}

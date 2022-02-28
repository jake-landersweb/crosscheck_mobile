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
  bool _isLoading = false;

  @override
  void initState() {
    _checkSeasonRoster(context, context.read<DataModel>());
    super.initState();
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
      trailing: [_createUser(context, dmodel)],
      leading: const [MenuButton()],
      children: [
        // season selector
        if (dmodel.seasonUsers != null)
          Column(
            children: [
              _rosterList(
                context,
                dmodel,
                _active(context, dmodel),
              ),
              if (dmodel.seasonUsers!
                  .any((element) => element.teamFields!.validationStatus == 0))
                cv.Section(
                  "Non Validated",
                  child: _rosterList(
                    context,
                    dmodel,
                    _notValidated(context, dmodel),
                  ),
                ),
              if (dmodel.seasonUsers!
                  .any((element) => element.teamFields!.validationStatus == 2))
                cv.Section(
                  "Invited",
                  child: _rosterList(
                    context,
                    dmodel,
                    _invited(context, dmodel),
                  ),
                )
            ],
          )
        else
          const RosterLoading(),
      ],
    );
  }

  Widget _rosterList(
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
            season: dmodel.currentSeason!,
            seasonUser: user,
            teamUser: dmodel.tus!.user,
            appSeasonUser: dmodel.currentSeasonUser,
            onDelete: () async {
              setState(() {
                dmodel.seasonUsers = null;
                print("Hey");
              });
              _checkSeasonRoster(context, dmodel);
            },
            onUserEdit: (body) async {
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
    return dmodel.seasonUsers!
        .where((element) => element.teamFields!.validationStatus == 1)
        .toList();
  }

  List<SeasonUser> _notValidated(BuildContext context, DataModel dmodel) {
    return dmodel.seasonUsers!
        .where((element) => element.teamFields!.validationStatus == 0)
        .toList();
  }

  List<SeasonUser> _invited(BuildContext context, DataModel dmodel) {
    return dmodel.seasonUsers!
        .where((element) => element.teamFields!.validationStatus == 2)
        .toList();
  }

  Widget _createUser(BuildContext context, DataModel dmodel) {
    if (dmodel.currentSeason != null) {
      if (dmodel.currentSeasonUser?.isSeasonAdmin() ??
          dmodel.tus!.user.isTeamAdmin()) {
        return cv.BasicButton(
          onTap: () {
            showMaterialModalBottomSheet(
              context: context,
              isDismissible: true,
              enableDrag: false,
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

  Future<void> _checkSeasonRoster(
      BuildContext context, DataModel dmodel) async {
    if (dmodel.seasonUsers == null) {
      await dmodel.getSeasonRoster(
        dmodel.tus!.team.teamId,
        dmodel.currentSeason!.seasonId,
        (p0) => dmodel.setSeasonUsers(p0),
      );
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
  List<SeasonUser> _selectedTeamUsers = [];

  bool _isLoading = false;

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
        const SizedBox(height: 16),
        cv.Section(
          "Existing Users",
          child: cv.RoundedLabel(
            "Team Roster List",
            color: CustomColors.cellColor(context),
            textColor: CustomColors.textColor(context),
            isNavigator: true,
            onTap: () => cv.Navigate(context, _existingList(context, dmodel)),
          ),
        ),
        const SizedBox(height: 16),
        if (_selectedTeamUsers.isNotEmpty)
          cv.Section(
            "Selected Users",
            child: Column(
              children: [
                cv.ListView<SeasonUser>(
                  children: _selectedTeamUsers,
                  horizontalPadding: 0,
                  childPadding: const EdgeInsets.all(8),
                  isAnimated: true,
                  allowsDelete: true,
                  onDelete: (user) {
                    setState(() {
                      _selectedTeamUsers.removeWhere(
                          (element) => element.email == user.email);
                    });
                  },
                  childBuilder: (context, user) {
                    return RosterCell(
                      name: user.name(widget.team.showNicknames),
                      type: RosterListType.none,
                      color: dmodel.color,
                      isSelected: false,
                      padding: EdgeInsets.zero,
                      seed: user.email,
                    );
                  },
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: cv.RoundedLabel(
                    "Add Users",
                    color: dmodel.color,
                    textColor: Colors.white,
                    onTap: () {
                      if (!_isLoading && _selectedTeamUsers.isNotEmpty) {
                        _addUserList(context, dmodel);
                      }
                    },
                    isLoading: _isLoading,
                  ),
                )
              ],
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

  Widget _existingList(BuildContext context, DataModel dmodel) {
    return _AddTeamUsers(
      selected: _selectedTeamUsers,
      onSelect: (user) {
        if (_selectedTeamUsers.any((element) => element.email == user.email)) {
          setState(() {
            _selectedTeamUsers
                .removeWhere((element) => element.email == user.email);
          });
        } else {
          setState(() {
            _selectedTeamUsers.add(user);
          });
        }
      },
      team: widget.team,
      season: widget.season,
    );
  }

  Future<void> _addUserList(BuildContext context, DataModel dmodel) async {
    setState(() {
      _isLoading = true;
    });
    Map<String, dynamic> body = {
      "emailList": _selectedTeamUsers.map((e) => e.email).toList(),
      "date": dateToString(DateTime.now()),
    };
    await dmodel.addTeamUserEmailList(
        widget.team.teamId, widget.season.seasonId, body, () async {
      // fetch new season roster
      setState(() {
        dmodel.seasonUsers = null;
      });
      await dmodel.getSeasonRoster(widget.team.teamId, widget.season.seasonId,
          (p0) {
        setState(() {
          dmodel.setSeasonUsers(p0);
        });
        Navigator.of(context).pop();
      });
    });
    setState(() {
      _isLoading = false;
    });
  }
}

class _AddTeamUsers extends StatefulWidget {
  const _AddTeamUsers({
    Key? key,
    required this.selected,
    required this.onSelect,
    required this.team,
    required this.season,
  }) : super(key: key);
  final List<SeasonUser> selected;
  final Function(SeasonUser) onSelect;
  final Team team;
  final Season season;

  @override
  __AddTeamUsersState createState() => __AddTeamUsersState();
}

class __AddTeamUsersState extends State<_AddTeamUsers> {
  bool _isLoading = false;
  List<SeasonUser>? _users;

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
      title: "Team Roster",
      isLarge: true,
      refreshable: false,
      backgroundColor: CustomColors.backgroundColor(context),
      color: dmodel.color,
      itemBarPadding: const EdgeInsets.fromLTRB(8, 0, 15, 8),
      leading: [cv.BackButton(color: dmodel.color)],
      children: [
        if (_isLoading)
          const RosterLoading()
        else if (_users != null)
          RosterList(
            users: _users!
                .where((e1) =>
                    !dmodel.seasonUsers!.any((e2) => e1.email == e2.email))
                .toList(),
            team: dmodel.tus!.team,
            type: RosterListType.selector,
            color: dmodel.color,
            selected: widget.selected,
            onSelect: (user) {
              setState(() {
                widget.onSelect(user);
              });
            },
          ),
      ],
    );
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

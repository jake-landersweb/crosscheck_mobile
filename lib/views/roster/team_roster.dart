import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:crosscheck_sports/client/root.dart';
import 'package:crosscheck_sports/data/root.dart';
import 'package:crosscheck_sports/views/root.dart';
import 'package:provider/provider.dart';
import 'package:crosscheck_sports/extras/root.dart';
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

class _TeamRosterState extends State<TeamRoster> with TickerProviderStateMixin {
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
      title: "Team Roster",
      refreshable: true,
      isLarge: true,
      onRefresh: () => _fetchUsers(context, dmodel),
      backgroundColor: CustomColors.backgroundColor(context),
      color: dmodel.color,
      itemBarPadding: const EdgeInsets.fromLTRB(8, 0, 16, 8),
      trailing: [_createUser(context, dmodel)],
      leading: [cv.BackButton(color: dmodel.color)],
      children: [
        if (_users != null && !_isLoading)
          ChangeNotifierProvider<RosterSorting>(
            create: (_) => RosterSorting(
              team: dmodel.tus!.team,
            ),
            // we use `builder` to obtain a new `BuildContext` that has access to the provider
            builder: (context, child) {
              // No longer throws
              return _body(context, dmodel);
            },
          )
        else
          const RosterLoading()
      ],
    );
  }

  Widget _body(BuildContext context, DataModel dmodel) {
    RosterSorting smodel = Provider.of<RosterSorting>(context);
    return Column(
      children: [
        smodel.header(context, dmodel),
        const SizedBox(height: 8),
        _rosterBase(context, dmodel, _active(context, dmodel, smodel), smodel),
        if (_invited(context, dmodel, smodel).isNotEmpty)
          cv.Section(
            "Invited",
            child: _rosterBase(
                context, dmodel, _invited(context, dmodel, smodel), smodel),
          ),
        if (_notValidated(context, dmodel, smodel).isNotEmpty)
          cv.Section(
            "Non Validated",
            child: _rosterBase(context, dmodel,
                _notValidated(context, dmodel, smodel), smodel),
          ),
      ],
    );
  }

  Widget _rosterBase(BuildContext context, DataModel dmodel,
      List<SeasonUser> users, RosterSorting smodel) {
    return RosterList(
      users: users,
      team: dmodel.tus!.team,
      type: RosterListType.navigator,
      isMVP: (seasonUser) {
        return dmodel.tus!.team.positions.mvp == seasonUser.teamFields!.pos;
      },
      cellBuilder: (context, i, isSelected) {
        return RosterCell(
          name: i.name(dmodel.tus!.team.showNicknames),
          seed: i.email,
          padding: EdgeInsets.zero,
          type: RosterListType.none,
          color: dmodel.color,
          isSelected: isSelected,
          trailingWidget: _trailingWidget(context, i, smodel),
        );
      },
      onNavigate: (user) {
        cv.Navigate(
          context,
          RosterUserDetail(
            team: dmodel.tus!.team,
            seasonUser: user,
            teamUser: dmodel.tus!.user,
            isTeam: true,
            isSheet: false,
            onDelete: () async {
              setState(() {
                _isLoading = true;
                _users = null;
              });
              await _fetchUsers(context, dmodel);
            },
            onUserEdit: (body) async {
              // print(body);
              await dmodel.teamUserUpdate(
                  dmodel.tus!.team.teamId, user.email, body, () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                // get latest team roster
                setState(() {
                  _users = null;
                });
                _fetchUsers(context, dmodel);
              });
            },
          ),
        );
      },
    );
  }

  Widget _trailingWidget(
      BuildContext context, SeasonUser user, RosterSorting smodel) {
    if (smodel.sortCF != null) {
      String val = user.teamFields!.customFields
          .firstWhere(
              (element) => element.getTitle() == smodel.sortCF!.getTitle())
          .getValue();
      return Text(val);
    } else {
      return const Icon(Icons.chevron_right_rounded);
    }
  }

  List<SeasonUser> _active(
      BuildContext context, DataModel dmodel, RosterSorting smodel) {
    return smodel
        .users(_users!, showNicknames: dmodel.tus!.team.showNicknames)
        .where((element) => element.teamFields!.validationStatus == 1)
        .toList();
  }

  List<SeasonUser> _notValidated(
      BuildContext context, DataModel dmodel, RosterSorting smodel) {
    return smodel
        .users(_users!, showNicknames: dmodel.tus!.team.showNicknames)
        .where((element) => element.teamFields!.validationStatus == 0)
        .toList();
  }

  List<SeasonUser> _invited(
      BuildContext context, DataModel dmodel, RosterSorting smodel) {
    return smodel
        .users(_users!, showNicknames: dmodel.tus!.team.showNicknames)
        .where((element) => element.teamFields!.validationStatus == 2)
        .toList();
  }

  Widget _createUser(BuildContext context, DataModel dmodel) {
    if (widget.teamUser?.isTeamAdmin() ?? false) {
      return cv.BasicButton(
        onTap: () {
          cv.cupertinoSheet(
            context: context,
            builder: (context) {
              return RUCERoot(
                team: dmodel.tus!.team,
                isSheet: true,
                isCreate: true,
                onFunction: (body) async {
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
    await FirebaseAnalytics.instance
        .setCurrentScreen(screenName: "team_roster");
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

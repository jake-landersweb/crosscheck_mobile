import 'package:flutter/material.dart';
import 'package:pnflutter/client/api_helpers.dart';
import 'package:pnflutter/views/root.dart';
import 'package:pnflutter/views/roster/team_roster.dart';
import 'package:pnflutter/views/season/create/sce_model.dart';
import 'package:pnflutter/views/season/create/sce_customf.dart';
import 'package:pnflutter/views/shared/positions_create.dart';
import 'package:provider/provider.dart';
import '../../../client/root.dart';
import '../../../data/root.dart';
import '../../../extras/root.dart';
import '../../menu/root.dart';
import '../../../custom_views/root.dart' as cv;
import 'package:flutter_switch/flutter_switch.dart';
import '../../shared/root.dart';

class SCEUsers extends StatefulWidget {
  const SCEUsers({
    Key? key,
    required this.team,
  }) : super(key: key);
  final Team team;

  @override
  _SCEUsersState createState() => _SCEUsersState();
}

class _SCEUsersState extends State<SCEUsers> {
  @override
  Widget build(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    SCEModel scemodel = Provider.of<SCEModel>(context);
    return ListView(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      children: [
        const SizedBox(height: 16),
        _selectTeamUser(context, dmodel, scemodel),
        const SizedBox(height: 16),
        _teamUsers(context, dmodel, scemodel),
        const SizedBox(height: 48),
      ],
    );
  }

  Widget _selectTeamUser(
      BuildContext context, DataModel dmodel, SCEModel scemodel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: cv.RoundedLabel(
        "Full Team Roster",
        color: CustomColors.cellColor(context),
        textColor: CustomColors.textColor(context).withOpacity(0.7),
        isNavigator: true,
        onTap: () {
          cv.Navigate(
            context,
            _TeamUserSelect(
              team: widget.team,
              selected: scemodel.teamUsers,
              onSelect: (user) {
                if (scemodel.teamUsers
                    .any((element) => element.email == user.email)) {
                  // remove
                  setState(() {
                    scemodel.teamUsers
                        .removeWhere((element) => element.email == user.email);
                  });
                } else {
                  setState(() {
                    scemodel.teamUsers.add(user);
                  });
                }
              },
            ),
          );
        },
      ),
    );
  }

  Widget _teamUsers(BuildContext context, DataModel dmodel, SCEModel scemodel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: scemodel.teamUsers.isEmpty
          ? Container()
          : cv.Section(
              "Team Users",
              child: cv.ListView<SeasonUser>(
                children: scemodel.teamUsers,
                childPadding: const EdgeInsets.all(8),
                horizontalPadding: 0,
                onChildTap: (context, item) {
                  setState(() {
                    scemodel.teamUsers
                        .removeWhere((element) => element.email == item.email);
                  });
                },
                childBuilder: (context, item) {
                  return RosterCell(
                    padding: EdgeInsets.zero,
                    name: item.name(widget.team.showNicknames),
                    seed: item.email,
                    color: dmodel.color,
                    type: RosterListType.selector,
                    isSelected: scemodel.teamUsers
                        .any((element) => element.email == item.email),
                  );
                },
              ),
            ),
    );
  }
}

class _TeamUserSelect extends StatefulWidget {
  const _TeamUserSelect({
    Key? key,
    required this.team,
    required this.selected,
    required this.onSelect,
  }) : super(key: key);
  final Team team;
  final List<SeasonUser> selected;
  final Function(SeasonUser) onSelect;

  @override
  __TeamUserSelectState createState() => __TeamUserSelectState();
}

class __TeamUserSelectState extends State<_TeamUserSelect> {
  List<SeasonUser>? _users;

  @override
  void initState() {
    super.initState();
    _getTeamUsers(context, context.read<DataModel>());
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
      title: "Select Users",
      isLarge: false,
      itemBarPadding: const EdgeInsets.fromLTRB(8, 0, 15, 8),
      leading: [
        cv.BackButton(color: dmodel.color),
      ],
      children: [
        if (_users != null)
          RosterList(
            users: _users!,
            color: dmodel.color,
            team: widget.team,
            type: RosterListType.selector,
            selected: widget.selected,
            onSelect: (user) => widget.onSelect(user),
          )
        else
          const RosterLoading(),
      ],
    );
  }

  Future<void> _getTeamUsers(BuildContext context, DataModel dmodel) async {
    if (_users == null) {
      await dmodel.getTeamRoster(widget.team.teamId, (p0) {
        setState(() {
          _users = p0;
        });
      });
    }
  }
}

import 'package:flutter/material.dart';
import 'package:pnflutter/views/root.dart';
import 'package:provider/provider.dart';
import '../../client/root.dart';
import '../../data/root.dart';
import '../../extras/root.dart';
import '../menu/root.dart';
import '../../custom_views/root.dart' as cv;
import 'package:flutter_switch/flutter_switch.dart';
import '../shared/root.dart';

class FullTeamRoster extends StatefulWidget {
  const FullTeamRoster({
    Key? key,
    required this.team,
    required this.childBuilder,
    required this.teamUser,
    this.allowSelect = false,
    this.onSelection,
  }) : super(key: key);
  final Team team;
  final bool allowSelect;
  final SeasonUserTeamFields teamUser;
  final Function(SeasonUser)? onSelection;
  final Widget Function(SeasonUser) childBuilder;

  @override
  _FullTeamRosterState createState() => _FullTeamRosterState();
}

class _FullTeamRosterState extends State<FullTeamRoster> {
  late List<SeasonUser>? _roster = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getRoster(context.read<DataModel>());
  }

  @override
  void dispose() {
    _roster = null;
    super.dispose();
  }

  Future<void> _getRoster(DataModel dmodel) async {
    await dmodel.getTeamRoster(widget.team.teamId, (p0) {
      setState(() {
        _roster = p0;
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    return cv.AppBar(
      title: "Team Roster",
      isLarge: true,
      itemBarPadding: const EdgeInsets.fromLTRB(8, 0, 15, 8),
      refreshable: true,
      onRefresh: () => _getRoster(dmodel),
      backgroundColor: CustomColors.backgroundColor(context),
      childPadding: const EdgeInsets.fromLTRB(0, 15, 0, 45),
      color: dmodel.color,
      leading: [cv.BackButton(color: dmodel.color)],
      trailing: [
        if (widget.teamUser.isTeamAdmin())
          cv.BasicButton(
            onTap: () {
              cv.Navigate(
                context,
                SeasonUserEdit(
                  team: widget.team,
                  user: SeasonUser.empty(),
                  teamId: widget.team.teamId,
                  teamUser: dmodel.tus!.user,
                  completion: () {},
                  isAdd: true,
                  onTeamUserCreate: (seasonUser) {
                    setState(() {
                      _roster?.add(seasonUser);
                    });
                  },
                ),
              );
            },
            child: Icon(Icons.add, color: dmodel.color),
          ),
      ],
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: _body(context, dmodel),
        )
      ],
    );
  }

  Widget _body(BuildContext context, DataModel dmodel) {
    if (_isLoading) {
      return cv.NativeList(
        children: [
          for (int i = 0; i < 15; i++) const UserCellLoading(),
        ],
      );
    } else if (_roster == null) {
      return const Text("There was an issue");
    } else if (_roster!.isEmpty) {
      return const Text(
          "There are no users on your team. How did this happen? Contact support.");
    } else {
      List<SeasonUser> active = [];
      List<SeasonUser> invited = [];
      List<SeasonUser> recruit = [];
      // faster to loop once then to filter 3 times
      for (SeasonUser user in _roster!) {
        switch (user.teamFields!.validationStatus) {
          case 1:
            active.add(user);
            break;
          case 2:
            invited.add(user);
            break;
          case 0:
            recruit.add(user);
            break;
          default:
            break;
        }
      }
      return Column(children: [
        if (active.isNotEmpty)
          cv.Section(
            "Active",
            child: cv.AnimatedList<SeasonUser>(
              enabled: false,
              childPadding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
              padding: EdgeInsets.zero,
              children: active,
              cellBuilder: (context, user) {
                return _rosterCell(context, user, dmodel);
              },
            ),
          ),
        if (invited.isNotEmpty)
          cv.Section(
            "Invited",
            child: cv.AnimatedList<SeasonUser>(
              enabled: false,
              childPadding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
              padding: EdgeInsets.zero,
              children: invited,
              cellBuilder: (context, user) {
                return _rosterCell(context, user, dmodel);
              },
            ),
          ),
        if (recruit.isNotEmpty)
          cv.Section(
            "Recruit",
            child: cv.AnimatedList<SeasonUser>(
              enabled: false,
              childPadding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
              padding: EdgeInsets.zero,
              children: recruit,
              cellBuilder: (context, user) {
                return _rosterCell(context, user, dmodel);
              },
            ),
          ),
      ]);
    }
  }

  Widget _rosterCell(BuildContext context, SeasonUser user, DataModel dmodel) {
    return cv.BasicButton(
      onTap: () {
        if (widget.allowSelect) {
          if (widget.onSelection != null) {
            setState(() {
              widget.onSelection!(user);
            });
          }
        } else {
          cv.Navigate(
            context,
            SeasonUserDetail(
              user: user,
              team: dmodel.tus!.team,
              teamUser: widget.teamUser,
            ),
          );
        }
      },
      child: widget.childBuilder(user),
    );
  }
}

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
  }) : super(key: key);
  final Team team;

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
      childPadding: EdgeInsets.fromLTRB(0, 15, 0, 45),
      color: dmodel.color,
      leading: [cv.BackButton()],
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
      return Text("There was an issue");
    } else if (_roster!.isEmpty) {
      return const Text(
          "There are no users on your team. How did this happen? Contact support.");
    } else {
      return cv.NativeList(
        children: [
          for (SeasonUser i in _roster!) _rosterCell(context, i, dmodel),
        ],
      );
    }
  }

  Widget _rosterCell(BuildContext context, SeasonUser user, DataModel dmodel) {
    return cv.BasicButton(
      onTap: () {
        cv.Navigate(
          context,
          SeasonUserDetail(
            season: Season.empty(),
            user: user,
            teamId: dmodel.tus!.team.teamId,
            seasonId: "",
          ),
        );
      },
      child: UserCell(
        user: user,
        isClickable: true,
        season: Season.empty(),
      ),
    );
  }
}

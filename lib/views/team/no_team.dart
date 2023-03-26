import 'package:crosscheck_sports/data/root.dart';
import 'package:crosscheck_sports/views/tsce/tsce_root.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:crosscheck_sports/client/root.dart';
import 'package:crosscheck_sports/extras/root.dart';
import 'package:crosscheck_sports/views/team/create_team.dart';
import 'package:provider/provider.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import '../components/root.dart' as comp;
import '../../custom_views/root.dart' as cv;
import 'root.dart';

class NoTeam extends StatefulWidget {
  const NoTeam({Key? key}) : super(key: key);

  @override
  _NoTeamState createState() => _NoTeamState();
}

class _NoTeamState extends State<NoTeam> {
  @override
  Widget build(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    return Column(
      children: [
        cv.NoneFound(
          "You are not on any teams",
          color: dmodel.color,
          asset: "assets/svg/road.svg",
        ),
        const SizedBox(height: 32),
        comp.ActionButton(
          color: dmodel.color,
          title: "Join Team",
          onTap: () {
            // join team
            cv.showFloatingSheet(
              context: context,
              builder: (context) {
                return JoinTeam(email: dmodel.user!.email);
              },
            );
          },
        ),
        const SizedBox(height: 16),
        comp.SubActionButton(
          title: "Create My Team",
          onTap: () {
            cv.cupertinoSheet(
              context: context,
              builder: (context) {
                return TSCERoot(user: dmodel.user!);
              },
            );
          },
        ),
      ],
    );
  }
}

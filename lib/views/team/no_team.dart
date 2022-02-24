import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pnflutter/client/root.dart';
import 'package:pnflutter/extras/root.dart';
import 'package:pnflutter/views/team/create_team.dart';
import 'package:provider/provider.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

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
        cv.NoneFound("You are not on any teams", color: dmodel.color),
        const SizedBox(height: 32),
        _buttonCell(
          "Join Team",
          () {
            // join team
            cv.showFloatingSheet(
              context: context,
              builder: (context) {
                return JoinTeam(email: dmodel.user!.email);
              },
            );
          },
          dmodel.color,
          Colors.white,
          dmodel,
        ),
        const SizedBox(height: 16),
        _buttonCell(
          "Create Team",
          () {
            // create team
            cv.showFloatingSheet(
              context: context,
              builder: (context) {
                return TCETemplates(
                  user: dmodel.user!,
                  color: dmodel.color,
                );
              },
            );
          },
          CustomColors.cellColor(context),
          CustomColors.textColor(context),
          dmodel,
        ),
      ],
    );
  }

  Widget _buttonCell(String title, VoidCallback onTap, Color color,
      Color textColor, DataModel dmodel) {
    return cv.RoundedLabel(
      title,
      onTap: onTap,
      color: color,
      textColor: textColor,
    );
  }
}

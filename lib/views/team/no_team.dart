import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pnflutter/client/root.dart';
import 'package:pnflutter/extras/root.dart';
import 'package:pnflutter/views/team/create_team.dart';
import 'package:provider/provider.dart';

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
        const Text(
          "It looks like you are not a member of any teams. To start using the app, pick from the following:",
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        _buttonCell(
          "Join Team",
          () {
            // join team
            cv.Navigate(context, const JoinTeam());
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
            cv.Navigate(context, const CreateTeam());
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
    return cv.BasicButton(
      onTap: onTap,
      child: Material(
        color: color,
        shape: ContinuousRectangleBorder(
          borderRadius: BorderRadius.circular(35),
        ),
        child: SizedBox(
          height: 50,
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                  color: textColor, fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}

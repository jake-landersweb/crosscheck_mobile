import 'package:crosscheck_sports/crosscheck_engine.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:crosscheck_sports/client/root.dart';
import 'package:crosscheck_sports/data/root.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../extras/root.dart';

import 'package:crosscheck_sports/components/layer/header_bar.dart';
import 'package:crosscheck_sports/components/layer/action_button.dart';
import 'package:crosscheck_sports/components/layer/field.dart';
import 'package:crosscheck_sports/components/core/cell_list.dart';
import 'package:crosscheck_sports/components/layer/wide_button.dart';

class JoinTeam extends StatefulWidget {
  const JoinTeam({
    super.key,
    required this.email,
  });
  final String email;

  @override
  _JoinTeamState createState() => _JoinTeamState();
}

class _JoinTeamState extends State<JoinTeam> {
  String _code = "";

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    return HeaderBar.sheet(
      title: "Join Team",
      trailing: XCActionButton.cancel(
        onTap: () => Navigator.of(context).pop(),
      ),
      child: Column(
        children: [
          const SizedBox(height: 16),
          XCCellList<Widget>(
            horizontalPadding: 0,
            childPadding: const EdgeInsets.symmetric(horizontal: 16),
            backgroundColor: CustomColors.sheetCell(context),
            children: [
              XCField(
              labelText: "Team Code",
              showCharacters: true,
              isLabeled: true,
              value: _code,
              charLimit: 6,
              onChanged: (value) {
                  setState(() {
                    _code = value;
                  });
                },
            ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: MediaQuery.of(context).size.width / 1.5,
            child: XCWideButton.primary(
              title: "Join Team",
              isLoading: _isLoading,
              onTap: () {
                if (_code == "") {
                  dmodel.addIndicator(
                      IndicatorItem.error("Code cannot be empty"));
                } else {
                  _function(context, dmodel);
                }
              },
              color: dmodel.color,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _function(BuildContext context, DataModel dmodel) async {
    setState(() {
      _isLoading = true;
    });
    Map<String, dynamic> body = {
      "date": dateToString(DateTime.now()),
      "code": _code,
    };

    await dmodel.validateUser(widget.email, body, (teamId) async {
      // set this team as teamId
      var prefs = await SharedPreferences.getInstance();
      prefs.setString("teamId", teamId);
      // send google analytics tag
      await FirebaseAnalytics.instance.logJoinGroup(groupId: teamId);
      RestartWidget.restartApp(context);
      dmodel.addIndicator(IndicatorItem.success("Successfully joined team"));
    });
    setState(() {
      _isLoading = false;
    });
  }
}

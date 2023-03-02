import 'package:crosscheck_sports/crosscheck_engine.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:crosscheck_sports/client/root.dart';
import 'package:crosscheck_sports/data/root.dart';
import 'package:crosscheck_sports/main.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../extras/root.dart';
import '../menu/root.dart';

import '../../custom_views/root.dart' as cv;

class JoinTeam extends StatefulWidget {
  const JoinTeam({
    Key? key,
    required this.email,
  }) : super(key: key);
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
    return cv.Sheet(
      title: "Join Team",
      color: dmodel.color,
      child: Column(
        children: [
          const SizedBox(height: 16),
          cv.ListView<Widget>(
            horizontalPadding: 0,
            childPadding: const EdgeInsets.symmetric(horizontal: 16),
            backgroundColor: CustomColors.sheetCell(context),
            children: [
              cv.TextField2(
                labelText: "Team Code",
                fieldPadding: const EdgeInsets.all(0),
                showCharacters: true,
                isLabeled: true,
                showBackground: false,
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
            child: cv.RoundedLabel(
              "Join Team",
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
              textColor: Colors.white,
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

import 'package:flutter/material.dart';
import 'package:crosscheck_sports/client/root.dart';
import 'package:crosscheck_sports/data/root.dart';
import 'package:provider/provider.dart';
import '../../extras/root.dart';

import 'package:crosscheck_sports/components/layer/header_bar.dart';
import 'package:crosscheck_sports/components/layer/action_button.dart';
import 'package:crosscheck_sports/components/layer/field.dart';
import 'package:crosscheck_sports/components/layer/section.dart';
import 'package:crosscheck_sports/components/core/cell_list.dart';
import 'package:crosscheck_sports/components/layer/wide_button.dart';

class CreateTeam extends StatefulWidget {
  const CreateTeam({super.key});

  @override
  _CreateTeamState createState() => _CreateTeamState();
}

class _CreateTeamState extends State<CreateTeam> {
  String _title = "";

  String _color = "";
  String _website = "";

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    return HeaderBar(
      title: "Create Team",
      isLarge: true,
      backgroundColor: CustomColors.backgroundColor(context),
      leading: XCActionButton.back(),
      child: _body(context, dmodel),
    );
  }

  Widget _body(BuildContext context, DataModel dmodel) {
    return Column(
      children: [
        XCSection(
          "Required",
          child: XCCellList<Widget>(horizontalPadding: 0, children: [
            XCField(
              labelText: "Title",
              onChanged: (value) {
                setState(() {
                  _title = value;
                });
              },
            )
          ]),
        ),
        XCSection(
          "Optional",
          child: XCCellList<Widget>(horizontalPadding: 0, children: [
            XCField(
              labelText: "Color (hex string)",
              textCapitalization: TextCapitalization.none,
              onChanged: (value) {
                setState(() {
                  _color = value;
                });
              },
            ),
            XCField(
              labelText: "Website (url)",
              textCapitalization: TextCapitalization.none,
              onChanged: (value) {
                setState(() {
                  _website = value;
                });
              },
            )
          ]),
        ),
        const SizedBox(height: 16),
        XCWideButton.primary(
          title: "Create Team",
          isLoading: _isLoading,
          color: dmodel.color,
          onTap: () {
            if (_title.isEmpty) {
              dmodel.addIndicator(IndicatorItem.error("Title cannot be empty"));
            } else {
              _createTeam(context, dmodel);
            }
          },
        ),
      ],
    );
  }

  Future<void> _createTeam(BuildContext context, DataModel dmodel) async {
    setState(() {
      _isLoading = true;
    });
    // create the body
    Map<String, dynamic> body = {
      "title": _title,
      "color": _color,
      "website": _website.toLowerCase(),
      "email": dmodel.user!.email,
    };

    // set the request
    await dmodel.createTeam(body, (team) {
      // get the team with the teamid
      dmodel.teamUserSeasonsGet(team.teamId, dmodel.user!.email, (tus) {
        dmodel.setTUS(tus);
        Navigator.of(context).pop();
      });
    });

    setState(() {
      _isLoading = false;
    });
  }
}

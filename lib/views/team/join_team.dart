import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pnflutter/client/root.dart';
import 'package:provider/provider.dart';
import '../../extras/root.dart';
import '../menu/root.dart';

import '../../custom_views/root.dart' as cv;

class JoinTeam extends StatefulWidget {
  const JoinTeam({Key? key}) : super(key: key);

  @override
  _JoinTeamState createState() => _JoinTeamState();
}

class _JoinTeamState extends State<JoinTeam> {
  String _code = "";

  @override
  Widget build(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    return cv.AppBar(
      title: "Join Team",
      isLarge: true,
      itemBarPadding: const EdgeInsets.fromLTRB(8, 0, 15, 8),
      backgroundColor: CustomColors.backgroundColor(context),
      // refreshable: true,
      color: dmodel.color,
      leading: [cv.BackButton()],
      children: [_body(context, dmodel)],
    );
  }

  Widget _body(BuildContext context, DataModel dmodel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          cv.Section(
            "Team or Season Code",
            child: cv.NativeList(
              children: [
                cv.DynamicTextField(
                  labelText: "Code",
                  fieldPadding: const EdgeInsets.all(0),
                  showCharacters: true,
                  value: _code,
                  charLimit: 6,
                  onChanged: (value) {
                    setState(() {
                      _code = value;
                    });
                  },
                )
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: MediaQuery.of(context).size.width / 1.5,
            child: _buttonCell(
              "Join Team",
              () {
                // join team
                if (_code == "") {
                  dmodel.setError("Code cannot be empty", true);
                }
              },
              dmodel,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buttonCell(String title, VoidCallback onTap, DataModel dmodel) {
    return cv.BasicButton(
      onTap: onTap,
      child: Material(
        color: dmodel.color,
        shape: ContinuousRectangleBorder(
          borderRadius: BorderRadius.circular(35),
        ),
        child: SizedBox(
          height: 50,
          child: Center(
            child: Text(
              title,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}

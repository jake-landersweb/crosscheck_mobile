import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pnflutter/client/root.dart';
import 'package:provider/provider.dart';
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
    return cv.AppBar(
      title: "Join Team",
      isLarge: true,
      backgroundColor: CustomColors.backgroundColor(context),
      // refreshable: true,
      color: dmodel.color,
      leading: [
        cv.BackButton(
          color: dmodel.color,
          title: "Cancel",
          showText: true,
          showIcon: false,
        )
      ],
      children: [_body(context, dmodel)],
    );
  }

  Widget _body(BuildContext context, DataModel dmodel) {
    return Column(
      children: [
        cv.Section(
          "Team Code",
          child: cv.RoundedLabel(
            "",
            color: CustomColors.cellColor(context),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: cv.DynamicTextField(
                labelText: "Code",
                fieldPadding: const EdgeInsets.all(0),
                showCharacters: true,
                showBackground: false,
                value: _code,
                charLimit: 6,
                onChanged: (value) {
                  setState(() {
                    _code = value;
                  });
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: MediaQuery.of(context).size.width / 1.5,
          child: cv.RoundedLabel(
            "Join Team",
            isLoading: _isLoading,
            onTap: () {
              if (_code == "") {
                dmodel.setError("Code cannot be empty", true);
              } else {
                _function(context, dmodel);
              }
            },
            color: dmodel.color,
            textColor: Colors.white,
          ),
        ),
      ],
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

    await dmodel.validateUser(widget.email, body, () {
      Navigator.of(context).pop();
      // TODO -- get user tus with this teamId
      dmodel.init();
    });
    setState(() {
      _isLoading = false;
    });
  }
}

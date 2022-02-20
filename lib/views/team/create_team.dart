import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pnflutter/client/root.dart';
import 'package:pnflutter/data/root.dart';
import 'package:provider/provider.dart';
import '../../extras/root.dart';
import '../menu/root.dart';

import '../../custom_views/root.dart' as cv;

class CreateTeam extends StatefulWidget {
  const CreateTeam({Key? key}) : super(key: key);

  @override
  _CreateTeamState createState() => _CreateTeamState();
}

class _CreateTeamState extends State<CreateTeam> {
  String _title = "";

  String _color = "";
  String _image = "";
  String _website = "";

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    return cv.AppBar(
      title: "Create Team",
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
          "Required",
          child: cv.NativeList(children: [
            cv.TextField(
              labelText: "Title",
              fieldPadding: const EdgeInsets.all(0),
              validator: (value) {},
              onChanged: (value) {
                setState(() {
                  _title = value;
                });
              },
            )
          ]),
        ),
        cv.Section(
          "Optional",
          child: cv.NativeList(children: [
            cv.TextField(
              labelText: "Color (hex string)",
              textCapitalization: TextCapitalization.none,
              fieldPadding: const EdgeInsets.all(0),
              validator: (value) {},
              onChanged: (value) {
                setState(() {
                  _color = value;
                });
              },
            ),
            cv.TextField(
              labelText: "Image (url)",
              textCapitalization: TextCapitalization.none,
              fieldPadding: const EdgeInsets.all(0),
              validator: (value) {},
              onChanged: (value) {
                setState(() {
                  _image = value;
                });
              },
            ),
            cv.TextField(
              labelText: "Website (url)",
              textCapitalization: TextCapitalization.none,
              fieldPadding: const EdgeInsets.all(0),
              validator: (value) {},
              onChanged: (value) {
                setState(() {
                  _website = value;
                });
              },
            )
          ]),
        ),
        const SizedBox(height: 16),
        cv.RoundedLabel(
          "Create Team",
          isLoading: _isLoading,
          color: dmodel.color,
          textColor: Colors.white,
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
      "image": _image,
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

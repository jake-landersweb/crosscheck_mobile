import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pnflutter/client/root.dart';
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
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
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
          cv.BasicButton(
            onTap: () {
              //
              _createTeam(context, dmodel);
            },
            child: Material(
              color: dmodel.color,
              shape: ContinuousRectangleBorder(
                borderRadius: BorderRadius.circular(35),
              ),
              child: SizedBox(
                height: 50,
                child: Center(
                  child: _isLoading
                      ? const cv.LoadingIndicator(color: Colors.white)
                      : const Text(
                          "Create Team",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
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

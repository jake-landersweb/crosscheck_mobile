import 'package:flutter/material.dart';
import 'package:pnflutter/client/api_helpers.dart';
import 'package:provider/provider.dart';
import '../../client/root.dart';
import '../../data/root.dart';
import '../../extras/root.dart';
import '../menu/root.dart';
import '../../custom_views/root.dart' as cv;

class TeamAdmin extends StatefulWidget {
  const TeamAdmin({
    Key? key,
    required this.team,
    required this.seasons,
  }) : super(key: key);
  final Team team;
  final List<Season> seasons;

  @override
  _TeamAdminState createState() => _TeamAdminState();
}

class _TeamAdminState extends State<TeamAdmin> {
  @override
  Widget build(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    return cv.AppBar(
      title: "Team Admin",
      isLarge: true,
      backgroundColor: CustomColors.backgroundColor(context),
      // refreshable: true,
      color: dmodel.color,
      leading: const [MenuButton()],
      // trailing: [

      // ],
      // onRefresh: () => _refreshAction(dmodel),
      children: [
        cv.Section(
          "Basic Information",
          child: _body(context, dmodel),
        ),
        _seasons(context, dmodel),
        if (widget.team.positions != null)
          cv.Section("Available Positions", child: _teamPositions(context)),
      ],
    );
  }

  Widget _body(BuildContext context, DataModel dmodel) {
    return Column(children: [
      cv.NativeList(
        children: [
          cv.LabeledCell(
            label: "Title",
            value: widget.team.title,
          ),
          cv.LabeledCell(
            label: "Team Code",
            value: widget.team.teamCode,
          ),
          cv.LabeledCell(
            label: "Team Id",
            value: widget.team.teamId,
          ),
          if (!widget.team.teamStyle.color.isEmpty())
            cv.LabeledCell(
              label: "Color",
              value: widget.team.teamStyle.color!,
            ),
          if (!widget.team.teamStyle.image.isEmpty())
            cv.LabeledCell(
              label: "Image",
              value: widget.team.teamStyle.image!,
            ),
          if (widget.team.teamStyle.isLight != null)
            cv.LabeledCell(
              label: "Is Light",
              value: widget.team.teamStyle.isLight! ? "True" : "False",
            ),
        ],
      ),
    ]);
  }

  Widget _seasons(BuildContext context, DataModel dmodel) {
    return cv.Section(
      "Seasons",
      child: Column(
        children: [
          cv.NativeList(
            children: [
              for (var i in widget.seasons)
                cv.LabeledCell(
                  label: i.status(),
                  value: i.title,
                ),
            ],
          ),
          const SizedBox(height: 16),
          cv.BasicButton(
            onTap: () {},
            child: cv.NativeList(
              itemPadding: const EdgeInsets.all(0),
              children: [
                SizedBox(
                    height: 50,
                    child: Center(
                      child: Text(
                        "Create Season",
                        style: TextStyle(
                            color: dmodel.color,
                            fontWeight: FontWeight.w600,
                            fontSize: 18),
                      ),
                    ))
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _teamPositions(BuildContext context) {
    return Column(
      children: [
        cv.NativeList(
          children: [
            cv.LabeledCell(
              label: "Default",
              value: getPostion(widget.team.positions!.defaultPosition),
            ),
          ],
        ),
        const SizedBox(height: 16),
        cv.NativeList(
          children: [
            for (var position in widget.team.positions!.available)
              cv.LabeledCell(
                label: "",
                value: getPostion(position),
              ),
          ],
        ),
      ],
    );
  }
}

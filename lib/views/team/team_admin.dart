import 'package:flutter/material.dart';
import 'package:pnflutter/views/root.dart';
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
      trailing: [_edit(context, dmodel)],
      // onRefresh: () => _refreshAction(dmodel),
      children: [_body(context, dmodel)],
    );
  }

  Widget _body(BuildContext context, DataModel dmodel) {
    return Column(
      children: [
        cv.Section(
          "Basic Info",
          child: cv.NativeList(
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
              if (widget.team.color != "")
                cv.LabeledCell(
                  label: "Color",
                  value: widget.team.color,
                ),
              if (widget.team.image != "")
                cv.LabeledCell(
                  label: "Image",
                  value: widget.team.image,
                ),
              cv.LabeledCell(
                label: "Is Light",
                value: widget.team.isLight ? "True" : "False",
              ),
            ],
          ),
        ),
        _seasons(context, dmodel),
        if (widget.team.positions.isActive) _teamPositions(context, dmodel),
        if (widget.team.customFields.isNotEmpty) _customFields(context),
        if (widget.team.customUserFields.isNotEmpty) _customUserFields(context),
      ],
    );
  }

  Widget _seasons(BuildContext context, DataModel dmodel) {
    return cv.Section(
      "Seasons",
      child: Column(
        children: [
          cv.NativeList(
            children: [
              if (widget.seasons.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Center(
                    child: Text("There are no seasons"),
                  ),
                )
              else
                for (var i in widget.seasons)
                  cv.LabeledCell(
                    label: i.status(),
                    value: i.title,
                  ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _teamPositions(BuildContext context, DataModel dmodel) {
    return Column(
      children: [
        cv.NativeList(
          children: [
            cv.LabeledCell(
              label: "Default",
              value: widget.team.positions.defaultPosition,
            ),
          ],
        ),
        const SizedBox(height: 16),
        cv.NativeList(
          children: [
            for (var position in widget.team.positions.available)
              cv.LabeledCell(
                label: "",
                value: position,
              ),
          ],
        ),
      ],
    );
  }

  Widget _customFields(BuildContext context) {
    return cv.Section(
      "Custom Fields",
      child: cv.NativeList(
        children: [
          for (var i in widget.team.customFields)
            cv.LabeledCell(
              label: i.title,
              value: i.getValue(),
            )
        ],
      ),
    );
  }

  Widget _customUserFields(BuildContext context) {
    return cv.Section(
      "Custom User Fields",
      child: cv.NativeList(
        children: [
          for (var i in widget.team.customUserFields)
            cv.LabeledCell(
              label: i.title,
              value: "Default: ${i.defaultValue}",
            )
        ],
      ),
    );
  }

  Widget _edit(BuildContext context, DataModel dmodel) {
    return cv.BasicButton(
      onTap: () {
        cv.Navigate(context, EditTeam(team: widget.team));
      },
      child: Text(
        "Edit",
        style: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 18,
          color: dmodel.color,
        ),
      ),
    );
  }
}

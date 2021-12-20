import 'package:flutter/material.dart';
import 'package:pnflutter/client/api_helpers.dart';
import 'package:pnflutter/views/root.dart';
import 'package:provider/provider.dart';
import '../../client/root.dart';
import '../../data/root.dart';
import '../../extras/root.dart';
import '../menu/root.dart';
import '../../custom_views/root.dart' as cv;
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class SeasonAdmin extends StatefulWidget {
  const SeasonAdmin({
    Key? key,
    required this.season,
    required this.team,
  }) : super(key: key);
  final Season season;
  final Team team;

  @override
  _SeasonAdminState createState() => _SeasonAdminState();
}

class _SeasonAdminState extends State<SeasonAdmin> {
  @override
  Widget build(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    return cv.AppBar(
      title: "Season Admin",
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
        _basic(context, dmodel),
        const SizedBox(height: 16),
        _teamPositions(context, dmodel),
        const SizedBox(height: 16),
        _customFields(context),
        const SizedBox(height: 16),
        _customUserFields(context),
      ],
    );
  }

  Widget _basic(BuildContext context, DataModel dmodel) {
    return cv.Section(
      "Basic Info",
      child: Column(
        children: [
          cv.NativeList(
            children: [
              cv.LabeledCell(
                height: cellHeight,
                label: "Title",
                value: widget.season.title,
              ),
              cv.LabeledCell(
                height: cellHeight,
                label: "Status",
                value: widget.season.status(),
              ),
              cv.LabeledCell(
                label: "Season Id",
                value: widget.season.seasonId,
              ),
              cv.LabeledCell(
                height: cellHeight,
                label: "Season Code",
                value: widget.season.seasonCode,
              ),
              if (widget.season.website != "")
                cv.LabeledCell(
                  height: cellHeight,
                  label: "Website",
                  value: widget.season.website,
                ),
              cv.LabeledCell(
                height: cellHeight,
                label: "Show Nicknames",
                value: widget.season.showNicknames ? "True" : "False",
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _teamPositions(BuildContext context, DataModel dmodel) {
    return cv.Section(
      "Positions",
      allowsCollapse: true,
      initOpen: false,
      child: cv.NativeList(
        children: [
          for (var position in widget.season.positions.available)
            SizedBox(
              height: cellHeight,
              child: cv.LabeledCell(
                label: position == widget.season.positions.defaultPosition
                    ? "Default"
                    : "",
                value: position,
              ),
            ),
        ],
      ),
    );
  }

  Widget _customFields(BuildContext context) {
    return cv.Section(
      "Custom Fields",
      allowsCollapse: true,
      initOpen: false,
      child: cv.NativeList(
        itemPadding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
        children: [
          for (var i in widget.season.customFields)
            cv.LabeledCell(
              height: cellHeight,
              label: i.getTitle(),
              value: i.getValue(),
            )
        ],
      ),
    );
  }

  Widget _customUserFields(BuildContext context) {
    return cv.Section(
      "Custom User Fields",
      allowsCollapse: true,
      initOpen: false,
      child: cv.NativeList(
        itemPadding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
        children: [
          for (var i in widget.season.customUserFields)
            cv.LabeledCell(
              height: cellHeight,
              label: i.getTitle(),
              value: "Default: ${i.getValue()}",
            )
        ],
      ),
    );
  }

  Widget _seasonStats(BuildContext context) {
    return cv.NativeList(
      children: [
        for (var stat in widget.season.stats.stats)
          Column(
            children: [
              cv.LabeledCell(
                label: "Stat Name",
                value: stat.title,
              ),
              cv.LabeledCell(
                  label: "Default Value", value: stat.defaultValue.toString()),
              cv.LabeledCell(
                label: "Active",
                value: stat.isActive ? "True" : "False",
              ),
            ],
          ),
      ],
    );
  }

  Widget _edit(BuildContext context, DataModel dmodel) {
    return cv.BasicButton(
      onTap: () {
        showMaterialModalBottomSheet(
          enableDrag: false,
          context: context,
          builder: (context) {
            return SCERoot(
                team: widget.team, isCreate: false, season: widget.season);
          },
        );
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

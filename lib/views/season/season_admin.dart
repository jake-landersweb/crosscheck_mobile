import 'package:flutter/material.dart';
import 'package:pnflutter/client/api_helpers.dart';
import 'package:provider/provider.dart';
import '../../client/root.dart';
import '../../data/root.dart';
import '../../extras/root.dart';
import '../menu/root.dart';
import '../../custom_views/root.dart' as cv;

class SeasonAdmin extends StatefulWidget {
  const SeasonAdmin({
    Key? key,
    required this.season,
  }) : super(key: key);
  final Season season;

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
      // trailing: [

      // ],
      // onRefresh: () => _refreshAction(dmodel),
      children: [
        cv.Section(
          "Basic Information",
          child: _body(context, dmodel),
        ),
        if (widget.season.stats.isNotEmpty)
          cv.Section("Stats", child: _seasonStats(context)),
      ],
    );
  }

  Widget _body(BuildContext context, DataModel dmodel) {
    return Column(
      children: [
        cv.NativeList(
          children: [
            cv.LabeledCell(
              label: "Title",
              value: widget.season.title,
            ),
            cv.LabeledCell(
              label: "Status",
              value: widget.season.status(),
            ),
            cv.LabeledCell(
              label: "Default Position",
              value: getPostion(widget.season.defaultPosition),
            ),
            if (!widget.season.seasonCode.isEmpty())
              cv.LabeledCell(
                label: "Season Code",
                value: widget.season.seasonCode!,
              ),
            cv.LabeledCell(
              label: "Season Id",
              value: widget.season.seasonId,
            ),
            cv.LabeledCell(
              label: "Show Nicknames",
              value: widget.season.showNicknames ? "True" : "False",
            ),
            if (!widget.season.seasonInfo.website.isEmpty())
              cv.LabeledCell(
                label: "Website",
                value: widget.season.seasonInfo.website!,
              ),
            if (!widget.season.seasonInfo.email.isEmpty())
              cv.LabeledCell(
                label: "Email",
                value: widget.season.seasonInfo.email!,
              ),
          ],
        )
      ],
    );
  }

  Widget _seasonStats(BuildContext context) {
    return cv.NativeList(
      children: [
        for (var stat in widget.season.stats)
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
}

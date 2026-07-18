import 'package:flutter/material.dart';
import 'package:crosscheck_sports/views/root.dart';
import 'package:provider/provider.dart';
import '../../client/root.dart';
import '../../data/root.dart';
import '../../extras/root.dart';
import 'package:crosscheck_sports/components/layer/header_bar.dart';
import 'package:crosscheck_sports/components/layer/snapping_sheet.dart';
import 'package:crosscheck_sports/components/layer/action_button.dart';
import 'package:crosscheck_sports/components/core/cell_list.dart';
import 'package:crosscheck_sports/components/layer/section.dart';
import 'package:crosscheck_sports/components/core/labeled_row.dart';

class SeasonHome extends StatefulWidget {
  const SeasonHome({
    super.key,
    required this.team,
    required this.season,
    required this.teamUser,
    required this.seasonUser,
  });
  final Team team;
  final Season season;
  final SeasonUserTeamFields teamUser;
  final SeasonUser? seasonUser;

  @override
  _SeasonHomeState createState() => _SeasonHomeState();
}

class _SeasonHomeState extends State<SeasonHome> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    return HeaderBar.sheet(
      title: widget.season.title,
      backgroundColor: CustomColors.backgroundColor(context),
      leading: XCActionButton.back(),
      trailing: _edit(context, dmodel),
      // onRefresh: () => _refreshAction(dmodel),
      child: _body(context, dmodel),
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
        if (widget.season.stats.stats.isNotEmpty)
          Column(
            children: [
              const SizedBox(height: 16),
              _stats(context),
            ],
          ),
      ],
    );
  }

  Widget _basic(BuildContext context, DataModel dmodel) {
    return XCSection(
      "Basic Info",
      child: Column(
        children: [
          XCCellList<Widget>(
            horizontalPadding: 0,
            childPadding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              XCLabeledCell(
                label: "Title",
                value: widget.season.title,
              ),
              XCLabeledCell(
                label: "Status",
                value: widget.season.status(),
              ),
              XCLabeledCell(
                label: "Timezone",
                value: widget.season.timezone,
              ),
              if (widget.season.website != "")
                XCLabeledCell(
                  label: "Website",
                  value: widget.season.website,
                ),
              if (widget.season.calendarUrl != "")
                XCLabeledCell(
                  label: "Calendar",
                  value: widget.season.calendarUrl,
                ),
            ],
          )
        ],
      ),
    );
  }

  Widget _teamPositions(BuildContext context, DataModel dmodel) {
    return XCSection(
      "Positions",
      allowsCollapse: true,
      initOpen: true,
      child: XCCellList<String>(
        children: widget.season.positions.available,
        childPadding: const EdgeInsets.symmetric(horizontal: 16),
        horizontalPadding: 0,
        childBuilder: (context, position) {
          return XCLabeledCell(
            label: position == widget.season.positions.defaultPosition
                ? position == widget.season.positions.mvp
                    ? "Mvp Default"
                    : "Default"
                : position == widget.season.positions.mvp
                    ? "Mvp"
                    : "",
            value: position.capitalize(),
          );
        },
      ),
    );
  }

  Widget _customFields(BuildContext context) {
    return XCSection(
      "Custom Fields",
      allowsCollapse: true,
      initOpen: true,
      child: XCCellList<CustomField>(
        children: widget.season.customFields,
        childPadding: const EdgeInsets.symmetric(horizontal: 16),
        horizontalPadding: 0,
        childBuilder: (context, i) {
          return XCLabeledCell(
            height: cellHeight,
            label: i.getTitle(),
            value: i.getValue(),
          );
        },
      ),
    );
  }

  Widget _customUserFields(BuildContext context) {
    return XCSection(
      "Custom User Fields",
      allowsCollapse: true,
      initOpen: true,
      child: XCCellList<CustomField>(
        children: widget.season.customUserFields,
        childPadding: const EdgeInsets.symmetric(horizontal: 16),
        horizontalPadding: 0,
        childBuilder: (context, i) {
          return XCLabeledCell(
            height: cellHeight,
            label: i.getTitle(),
            value: "Default: ${i.getValue()}",
          );
        },
      ),
    );
  }

  Widget _stats(BuildContext context) {
    return XCSection(
      "Stats",
      allowsCollapse: true,
      initOpen: true,
      child: XCCellList<StatItem>(
        children: widget.season.stats.stats,
        childPadding: const EdgeInsets.symmetric(horizontal: 16),
        horizontalPadding: 0,
        childBuilder: (context, i) {
          return XCLabeledCell(
            height: cellHeight,
            label: "",
            value: i.getTitle(),
          );
        },
      ),
    );
  }

  Widget _edit(BuildContext context, DataModel dmodel) {
    if ((widget.seasonUser?.isSeasonAdmin() ?? false) ||
        widget.teamUser.isTeamAdmin()) {
      return XCActionButton.edit(
        onTap: () {
          showSnappingSheet(
            context: context,
            child: SCERoot(
              team: widget.team,
              isCreate: false,
              season: widget.season,
            ),
          );
        },
      );
    } else {
      return Container();
    }
  }
}

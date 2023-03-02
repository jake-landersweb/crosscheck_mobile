import 'package:crosscheck_sports/views/polls/root.dart';
import 'package:flutter/material.dart';
import 'package:crosscheck_sports/views/root.dart';
import 'package:provider/provider.dart';
import '../../client/root.dart';
import '../../data/root.dart';
import '../../extras/root.dart';
import '../menu/root.dart';
import '../../custom_views/root.dart' as cv;
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class SeasonHome extends StatefulWidget {
  const SeasonHome({
    Key? key,
    required this.team,
    required this.season,
    required this.teamUser,
    required this.seasonUser,
    this.useRoot = false,
  }) : super(key: key);
  final Team team;
  final Season season;
  final SeasonUserTeamFields teamUser;
  final SeasonUser? seasonUser;
  final bool useRoot;

  @override
  _SeasonHomeState createState() => _SeasonHomeState();
}

class _SeasonHomeState extends State<SeasonHome> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    return cv.AppBar.sheet(
      title: widget.season.title,
      backgroundColor: CustomColors.backgroundColor(context),
      color: dmodel.color,
      leading: [
        cv.BackButton(
          color: dmodel.color,
          title: "Close",
          showIcon: !widget.useRoot,
          showText: widget.useRoot,
          useRoot: widget.useRoot,
        )
      ],
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
    return cv.Section(
      "Basic Info",
      child: Column(
        children: [
          cv.ListView<Widget>(
            horizontalPadding: 0,
            childPadding: const EdgeInsets.symmetric(horizontal: 16),
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
                label: "Timezone",
                value: widget.season.timezone,
              ),
              if (widget.season.website != "")
                cv.LabeledCell(
                  label: "Website",
                  value: widget.season.website,
                ),
              if (widget.season.calendarUrl != "")
                cv.LabeledCell(
                  label: "Calendar",
                  value: widget.season.calendarUrl,
                ),
            ],
          )
        ],
      ),
    );
  }

  Widget _polls(BuildContext context, DataModel dmodel) {
    return cv.ListView<Widget>(
      horizontalPadding: 0,
      childPadding: const EdgeInsets.symmetric(horizontal: 16),
      onChildTap: (context, i) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SeasonPolls(
              team: widget.team,
              season: widget.season,
              teamUser: dmodel.tus!.user,
              seasonUser: dmodel.currentSeasonUser,
            ),
          ),
        );
      },
      children: [
        Row(
          children: [
            Text(
              "Polls",
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 18,
                color: CustomColors.textColor(context),
              ),
            ),
            const SizedBox(height: 50),
            const Spacer(),
            const Icon(Icons.chevron_right_rounded),
          ],
        ),
      ],
    );
  }

  Widget _teamPositions(BuildContext context, DataModel dmodel) {
    return cv.Section(
      "Positions",
      allowsCollapse: true,
      initOpen: true,
      child: cv.ListView<String>(
        children: widget.season.positions.available,
        childPadding: const EdgeInsets.symmetric(horizontal: 16),
        horizontalPadding: 0,
        childBuilder: (context, position) {
          return cv.LabeledCell(
            label: position == widget.season.positions.defaultPosition
                ? position == widget.season.positions.mvp
                    ? "Mvp Default"
                    : "Default"
                : position == widget.season.positions.mvp
                    ? "Mvp"
                    : "",
            value: position,
          );
        },
      ),
    );
  }

  Widget _customFields(BuildContext context) {
    return cv.Section(
      "Custom Fields",
      allowsCollapse: true,
      initOpen: true,
      child: cv.ListView<CustomField>(
        children: widget.season.customFields,
        childPadding: const EdgeInsets.symmetric(horizontal: 16),
        horizontalPadding: 0,
        childBuilder: (context, i) {
          return cv.LabeledCell(
            height: cellHeight,
            label: i.getTitle(),
            value: i.getValue(),
          );
        },
      ),
    );
  }

  Widget _customUserFields(BuildContext context) {
    return cv.Section(
      "Custom User Fields",
      allowsCollapse: true,
      initOpen: true,
      child: cv.ListView<CustomField>(
        children: widget.season.customUserFields,
        childPadding: const EdgeInsets.symmetric(horizontal: 16),
        horizontalPadding: 0,
        childBuilder: (context, i) {
          return cv.LabeledCell(
            height: cellHeight,
            label: i.getTitle(),
            value: "Default: ${i.getValue()}",
          );
        },
      ),
    );
  }

  Widget _stats(BuildContext context) {
    return cv.Section(
      "Stats",
      allowsCollapse: true,
      initOpen: true,
      child: cv.ListView<StatItem>(
        children: widget.season.stats.stats,
        childPadding: const EdgeInsets.symmetric(horizontal: 16),
        horizontalPadding: 0,
        childBuilder: (context, i) {
          return cv.LabeledCell(
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
      return cv.BasicButton(
        onTap: () {
          cv.cupertinoSheet(
            context: context,
            wrapInNavigator: true,
            builder: (context) => SCERoot(
              team: widget.team,
              isCreate: false,
              useRoot: widget.useRoot,
              season: widget.season,
            ),
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
    } else {
      return Container();
    }
  }
}

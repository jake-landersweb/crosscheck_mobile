import 'dart:developer';

import 'package:crosscheck_sports/views/schedule/lineup_ce/lineup_item.dart';
import 'package:crosscheck_sports/views/schedule/lineup_ce/lineup_templates.dart';
import 'package:crosscheck_sports/views/schedule/lineup_ce/old_lineups.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:crosscheck_sports/views/stats/team/root.dart';
import 'package:provider/provider.dart';

import '../../../custom_views/root.dart' as cv;
import '../../../data/root.dart';
import '../../../client/root.dart';
import '../../../extras/root.dart';
import '../root.dart';
import 'package:flutter/services.dart';
import 'package:crosscheck_sports/views/components/root.dart' as comp;

class LineupRoot extends StatefulWidget {
  const LineupRoot({
    super.key,
    required this.team,
    required this.season,
    required this.event,
    required this.eventUsers,
    this.lineup,
    required this.onAction,
  });
  final Team team;
  final Season season;
  final Event event;
  final List<SeasonUser> eventUsers;
  final Lineup? lineup;
  final void Function(Lineup) onAction;

  @override
  State<LineupRoot> createState() => _LineupRootState();
}

class _LineupRootState extends State<LineupRoot> {
  bool _isLoading = false;
  @override
  Widget build(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    return ChangeNotifierProvider<LModel>(
      create: (_) => widget.lineup == null
          ? LModel.create(
              team: widget.team,
              season: widget.season,
              event: widget.event,
              eventUsers: widget.eventUsers,
            )
          : LModel.update(
              team: widget.team,
              season: widget.season,
              event: widget.event,
              lineup: widget.lineup!,
              eventUsers: widget.eventUsers,
            ),
      // we use `builder` to obtain a new `BuildContext` that has access to the provider
      builder: (context, child) {
        // No longer throws
        return _content(context, dmodel);
      },
    );
  }

  Widget _content(BuildContext context, DataModel dmodel) {
    LModel lmodel = Provider.of<LModel>(context);
    return cv.AppBar.sheet(
      title: "Lineup",
      childPadding: const EdgeInsets.fromLTRB(0, 16, 0, 48),
      leading: [
        cv.BackButton(
          color: dmodel.color,
          title: "Cancel",
          showIcon: false,
          showText: true,
          useRoot: true,
        ),
      ],
      trailing: [
        cv.BasicButton(
          onTap: () async {
            if (lmodel.lineupValid()) {
              setState(() {
                _isLoading = true;
              });
              if (lmodel.isCreate) {
                await dmodel.createLineup(
                  widget.team.teamId,
                  widget.season.seasonId,
                  widget.event.eventId,
                  lmodel.lineup.toMap(),
                  (lineup) {
                    widget.onAction(lineup);
                    dmodel.addIndicator(
                        IndicatorItem.success("Successfully created lineup"));
                    Navigator.of(context, rootNavigator: true).pop();
                  },
                  () {
                    dmodel.addIndicator(IndicatorItem.error(
                        "There was an issue creating the lineup"));
                  },
                );
              } else {
                await dmodel.updateLineup(
                  widget.team.teamId,
                  widget.season.seasonId,
                  widget.event.eventId,
                  lmodel.lineup.toMap(),
                  (lineup) {
                    widget.onAction(lineup);
                    dmodel.addIndicator(
                        IndicatorItem.success("Successfully updated lineup"));
                    Navigator.of(context, rootNavigator: true).pop();
                  },
                  () {
                    dmodel.addIndicator(IndicatorItem.error(
                        "There was an issue updating the lineup"));
                  },
                );
              }
              setState(() {
                _isLoading = false;
              });
            }
          },
          child: _isLoading
              ? SizedBox(
                  height: 25,
                  width: 25,
                  child: cv.LoadingIndicator(color: dmodel.color),
                )
              : Text(
                  lmodel.isCreate ? "Create" : "Save",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: lmodel.lineupValid()
                        ? FontWeight.w600
                        : FontWeight.w400,
                    color: lmodel.lineupValid()
                        ? dmodel.color
                        : CustomColors.textColor(context).withOpacity(0.5),
                  ),
                ),
        ),
      ],
      children: [_body(context, dmodel, lmodel)],
    );
  }

  Widget _body(BuildContext context, DataModel dmodel, LModel lmodel) {
    return Column(
      children: [
        if (lmodel.isCreate)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: cv.ListView<String>(
              children: const ["Old Lineups", "Lineup Templates"],
              onChildTap: ((context, item) {
                if (item == "Old Lineups") {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OldLineups(
                        team: widget.team,
                        season: widget.season,
                        event: widget.event,
                        onSelect: (lineup) => lmodel.updateLineup(lineup),
                      ),
                    ),
                  );
                } else if (item == "Lineup Templates") {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LineupTemplates(
                        onSelect: (lineup) => lmodel.updateLineup(lineup),
                      ),
                    ),
                  );
                }
              }),
              childBuilder: ((context, item) {
                return Row(
                  children: [
                    Expanded(
                      child: Text(
                        item,
                        style: TextStyle(
                          color: CustomColors.textColor(context),
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: CustomColors.textColor(context).withOpacity(0.5),
                    ),
                  ],
                );
              }),
            ),
          ),
        cv.ListView<LineupItem>(
          // showStyling: false,
          children: lmodel.lineup.lineupItems,
          allowsDelete: true,
          isAnimated: true,
          horizontalPadding: 0,
          borderRadius: 0,
          // childPadding: const EdgeInsets.symmetric(vertical: 16),
          childPadding: const EdgeInsets.all(16),
          onDelete: (item) async => lmodel.removeLineupItem(item),
          childBuilder: ((context, item) {
            return LineupItemView(item: item);
          }),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(32, 16, 32, 0),
          child: comp.SubActionButton(
            title: "Add Line",
            onTap: () => lmodel.addLineupItem(),
          ),
        ),
        const SizedBox(height: 50),
      ],
    );
  }
}

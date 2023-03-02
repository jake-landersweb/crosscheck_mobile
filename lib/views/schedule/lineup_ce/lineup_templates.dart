import 'dart:developer';

import 'package:crosscheck_sports/views/schedule/lineup_ce/lineup_item.dart';
import 'package:crosscheck_sports/views/schedule/lineup_ce/old_lineups.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:crosscheck_sports/views/stats/team/root.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../../../custom_views/root.dart' as cv;
import '../../../data/root.dart';
import '../../../client/root.dart';
import '../../../extras/root.dart';
import '../root.dart';
import 'package:flutter/services.dart';
import 'package:crosscheck_sports/views/components/root.dart' as comp;

class _LineupHolder {
  late String title;
  late String icon;
  late Lineup lineup;

  _LineupHolder({
    required this.title,
    required this.icon,
    required this.lineup,
  });
}

class LineupTemplates extends StatefulWidget {
  const LineupTemplates({
    super.key,
    required this.onSelect,
  });
  final void Function(Lineup) onSelect;

  @override
  State<LineupTemplates> createState() => _LineupTemplatesState();
}

class _LineupTemplatesState extends State<LineupTemplates> {
  final List<_LineupHolder> _templates = [
    _LineupHolder(
      title: "Ice Hockey",
      icon: "assets/svg/hockey.svg",
      lineup: Lineup(eventId: "", teamId: "", seasonId: "", lineupItems: [
        LineupItem(title: "Forward Line 1", ids: ["", "", ""]),
        LineupItem(title: "Forward Line 2", ids: ["", "", ""]),
        LineupItem(title: "Forward Line 3", ids: ["", "", ""]),
        LineupItem(title: "Forward Line 4", ids: ["", "", ""]),
        LineupItem(title: "Defense Line 1", ids: ["", ""]),
        LineupItem(title: "Defense Line 2", ids: ["", ""]),
        LineupItem(title: "Defense Line 3", ids: ["", ""]),
        LineupItem(title: "Starting Goalie", ids: [""]),
      ]),
    ),
    _LineupHolder(
      title: "Football",
      icon: "assets/svg/football.svg",
      lineup: Lineup(eventId: "", teamId: "", seasonId: "", lineupItems: [
        LineupItem(title: "Wide Receiver", ids: ["", ""]),
        LineupItem(title: "Guard", ids: ["", ""]),
        LineupItem(title: "Center", ids: [""]),
        LineupItem(title: "Tight End", ids: [""]),
        LineupItem(title: "Quarterback", ids: [""]),
        LineupItem(title: "Fullback", ids: [""]),
        LineupItem(title: "Halfback", ids: [""]),
        LineupItem(title: "Safety", ids: ["", ""]),
        LineupItem(title: "Cornerback", ids: ["", ""]),
        LineupItem(title: "Outside Linebacker", ids: ["", ""]),
        LineupItem(title: "Middle Linebacker", ids: [""]),
        LineupItem(title: "End", ids: ["", ""]),
        LineupItem(title: "Tackle", ids: ["", ""]),
      ]),
    ),
    _LineupHolder(
      title: "Soccer",
      icon: "assets/svg/soccer.svg",
      lineup: Lineup(eventId: "", teamId: "", seasonId: "", lineupItems: [
        LineupItem(title: "Strikers", ids: ["", ""]),
        LineupItem(title: "Mid-Fielders", ids: ["", "", "", ""]),
        LineupItem(title: "Defense", ids: ["", "", "", ""]),
        LineupItem(title: "GoalKeeper", ids: [""]),
      ]),
    ),
    _LineupHolder(
      title: "Basketball",
      icon: "assets/svg/basketball.svg",
      lineup: Lineup(eventId: "", teamId: "", seasonId: "", lineupItems: [
        LineupItem(title: "Point Guard", ids: [""]),
        LineupItem(title: "Shooting Guard", ids: [""]),
        LineupItem(title: "Center", ids: [""]),
        LineupItem(title: "Power Forward", ids: [""]),
        LineupItem(title: "Small Forward", ids: [""]),
        LineupItem(title: "Bench", ids: ["", "", "", "", ""]),
      ]),
    ),
    _LineupHolder(
      title: "Baseball",
      icon: "assets/svg/baseball.svg",
      lineup: Lineup(eventId: "", teamId: "", seasonId: "", lineupItems: [
        LineupItem(title: "Catcher", ids: [""]),
        LineupItem(title: "Pitcher", ids: [""]),
        LineupItem(title: "First Base", ids: [""]),
        LineupItem(title: "Second Base", ids: [""]),
        LineupItem(title: "Third Base", ids: [""]),
        LineupItem(title: "Shortstop", ids: [""]),
        LineupItem(title: "Right Fielder", ids: [""]),
        LineupItem(title: "Center Fielder", ids: [""]),
        LineupItem(title: "Left Fielder", ids: [""]),
      ]),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    return cv.AppBar.sheet(
      title: "Lineup Templates",
      backgroundColor: CustomColors.backgroundColor(context),
      itemBarPadding: const EdgeInsets.fromLTRB(8, 0, 16, 0),
      leading: [cv.BackButton(color: dmodel.color)],
      children: [_body(context, dmodel)],
    );
  }

  Widget _body(BuildContext context, DataModel dmodel) {
    return cv.ListView<_LineupHolder>(
      horizontalPadding: 0,
      children: _templates,
      onChildTap: ((context, item) {
        widget.onSelect(item.lineup);
        Navigator.of(context).pop();
      }),
      childBuilder: ((context, item) {
        String desc = "";
        for (var i = 0; i < item.lineup.lineupItems.length; i++) {
          if (i == 0) {
            desc = item.lineup.lineupItems[i].title;
          } else {
            desc += ", ${item.lineup.lineupItems[i].title}";
          }
        }
        return Row(
          children: [
            SvgPicture.asset(
              item.icon,
              height: 28,
              width: 28,
              color: dmodel.color,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: CustomColors.textColor(context),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    desc,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: CustomColors.textColor(context).withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}

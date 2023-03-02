import 'dart:developer';

import 'package:crosscheck_sports/views/schedule/lineup_ce/lineup_item.dart';
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

class OldLineups extends StatefulWidget {
  const OldLineups({
    super.key,
    required this.team,
    required this.season,
    required this.event,
    required this.onSelect,
  });
  final Team team;
  final Season season;
  final Event event;
  final void Function(Lineup) onSelect;

  @override
  State<OldLineups> createState() => _OldLineupsState();
}

class _OldLineupsState extends State<OldLineups> {
  List<Lineup>? _lineups;
  bool _isLoading = true;

  @override
  void initState() {
    _fetchLineups(context.read<DataModel>());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    return cv.AppBar.sheet(
      title: "Old Lineups",
      backgroundColor: CustomColors.backgroundColor(context),
      itemBarPadding: const EdgeInsets.fromLTRB(8, 0, 16, 0),
      leading: [cv.BackButton(color: dmodel.color)],
      children: [_body(context, dmodel)],
    );
  }

  Widget _body(BuildContext context, DataModel dmodel) {
    if (_isLoading) {
      return Center(child: cv.LoadingIndicator(color: dmodel.color));
    } else if (_lineups == null) {
      return cv.NoneFound(
        "There was an issue getting the lineups",
        asset: "assets/svg/not_found.svg",
        color: widget.event.getColor() ?? dmodel.color,
      );
    } else {
      return cv.ListView<Lineup>(
        children: _lineups!.where((element) => element.event != null).toList(),
        horizontalPadding: 0,
        onChildTap: ((context, item) {
          widget.onSelect(item);
          Navigator.of(context).pop();
        }),
        childBuilder: (context, item) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.event!.getTitle(dmodel.tus!.team.title),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: CustomColors.textColor(context),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item.event!.getDate(),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: CustomColors.textColor(context).withOpacity(0.5),
                ),
              ),
              const SizedBox(height: 4),
              EventScoreCell(
                event: item.event!,
                height: 30,
                useEventColor: false,
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> _fetchLineups(DataModel dmodel) async {
    setState(() {
      _isLoading = true;
    });
    await dmodel.getAllLineups(
      widget.team.teamId,
      widget.season.seasonId,
      (p0) {
        setState(() {
          _lineups = p0;
        });
      },
      () {
        dmodel.addIndicator(
            IndicatorItem.error("There was an error fetching the lineups"));
        Navigator.of(context).pop();
      },
      includeEvents: true,
    );
    setState(() {
      _isLoading = false;
    });
  }
}

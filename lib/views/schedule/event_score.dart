import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../custom_views/root.dart' as cv;
import '../../data/root.dart';
import '../../client/root.dart';
import '../../extras/root.dart';
import 'package:crosscheck_sports/components/layer/header_bar.dart';
import 'package:crosscheck_sports/components/layer/action_button.dart';
import 'package:crosscheck_sports/components/layer/field.dart';
import 'package:crosscheck_sports/components/core/cell_list.dart';
import 'package:crosscheck_sports/components/layer/section.dart';
import 'package:crosscheck_sports/components/layer/wide_button.dart';

class EventScore extends StatefulWidget {
  const EventScore({
    super.key,
    required this.team,
    required this.season,
    required this.event,
  });
  final Team team;
  final Season season;
  final Event event;

  @override
  _EventScoreState createState() => _EventScoreState();
}

class _EventScoreState extends State<EventScore> {
  late int _homeTeamScore;
  late int _awayTeamScore;

  @override
  void initState() {
    _homeTeamScore = widget.event.homeTeam!.score ?? 0;
    _awayTeamScore = widget.event.awayTeam!.score ?? 0;
    super.initState();
  }

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    return HeaderBar.sheet(
      title: "Edit Score",
      trailing: XCActionButton.cancel(
        onTap: () => Navigator.of(context).pop(),
      ),
      child: Column(
        children: [
          XCSection(
            widget.event.homeTeam?.title ?? "Home Team",
            headerPadding: const EdgeInsets.fromLTRB(24, 8, 0, 4),
            child: XCCellList<Widget>(
              backgroundColor: CustomColors.sheetCell(context),
              horizontalPadding: 8,
              childPadding: EdgeInsets.zero,
              children: [
                _EventScoreField(
                  initValue: _homeTeamScore,
                  color: dmodel.color,
                  onChange: (val) {
                    setState(
                      () {
                        _homeTeamScore = val;
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          XCSection(
            widget.event.awayTeam?.title ?? "Away Team",
            headerPadding: const EdgeInsets.fromLTRB(24, 8, 0, 4),
            child: XCCellList<Widget>(
              backgroundColor: CustomColors.sheetCell(context),
              horizontalPadding: 8,
              childPadding: EdgeInsets.zero,
              children: [
                _EventScoreField(
                  initValue: _awayTeamScore,
                  color: dmodel.color,
                  onChange: (val) {
                    setState(() {
                      _awayTeamScore = val;
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: XCWideButton.primary(
              title: "Update Score",
              color: dmodel.color,
              onTap: () {
                _updateScore(context, dmodel);
              },
              isLoading: _isLoading,
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Future<void> _updateScore(BuildContext context, DataModel dmodel) async {
    setState(() {
      _isLoading = true;
    });

    Map<String, dynamic> body = {
      "homeTeam": {
        "title": widget.event.homeTeam!.title,
        "teamId": widget.event.homeTeam!.teamId,
        "score": _homeTeamScore,
      },
      "awayTeam": {
        "title": widget.event.awayTeam!.title,
        "teamId": widget.event.awayTeam!.teamId,
        "score": _awayTeamScore,
      },
    };

    print(body);

    await dmodel.updateEvent(
      widget.team.teamId,
      widget.season.seasonId,
      widget.event.eventId,
      body,
      () {
        widget.event.homeTeam!.score = _homeTeamScore;
        widget.event.awayTeam!.score = _awayTeamScore;
        Navigator.of(context).pop();
      },
    );

    setState(() {
      _isLoading = false;
    });
  }
}

class _EventScoreField extends StatefulWidget {
  const _EventScoreField({
    required this.initValue,
    required this.onChange,
    this.color = Colors.blue,
  });
  final int initValue;
  final Function(int) onChange;
  final Color color;

  @override
  __EventScoreFieldState createState() => __EventScoreFieldState();
}

class __EventScoreFieldState extends State<_EventScoreField> {
  late TextEditingController _controller;

  @override
  void initState() {
    _controller = TextEditingController(text: widget.initValue.toString());
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: XCField(
              labelText: "Score",
              controller: _controller,
              isLabeled: false,
              onChanged: (val) {
                var v = int.tryParse(val) ?? 0;
                widget.onChange(v);
              },
            ),
          ),
        ),
        cv.NumberPicker(
          cornerRadius: 5,
          minValue: -1000,
          maxValue: 1000,
          plusBackgroundColor: widget.color,
          initialValue: int.tryParse(_controller.text) ?? 0,
          onPlusClick: (val) {
            var v = int.tryParse(_controller.text) ?? 0;
            v += 1;
            setState(() {
              _controller.text = v.toString();
            });
            widget.onChange(v);
          },
          onMinusClick: (val) {
            var v = int.tryParse(_controller.text) ?? 0;
            if (v > 0) {
              v -= 1;
            }
            setState(() {
              _controller.text = v.toString();
            });
            widget.onChange(v);
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}

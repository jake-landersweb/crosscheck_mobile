import 'dart:developer';

import 'package:crosscheck_sports/client/root.dart';
import 'package:crosscheck_sports/data/season/poll.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sprung/sprung.dart';
import '../../extras/root.dart';
import '../../data/root.dart';
import '../../../custom_views/root.dart' as cv;
import '../components/root.dart' as comp;

class PollSheet extends StatefulWidget {
  const PollSheet({
    Key? key,
    required this.poll,
    required this.team,
    required this.season,
    required this.email,
    required this.onCompletion,
  }) : super(key: key);
  final Poll poll;
  final Team team;
  final Season season;
  final String email;
  final VoidCallback onCompletion;

  @override
  State<PollSheet> createState() => _PollSheetState();
}

class _PollSheetState extends State<PollSheet> {
  List<String> _selections = [];
  bool _isLoading = false;

  @override
  void initState() {
    if (widget.poll.userSelections.isNotEmpty) {
      _selections = List.of(widget.poll.userSelections);
    }
    _getUser(context, context.read<DataModel>());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    return cv.Sheet(
      title: "Select Response",
      color: dmodel.color,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _singleSelection(context, dmodel),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 700),
              curve: Sprung.overDamped,
              opacity: _selections.isEmpty ? 0.5 : 1,
              child: comp.ActionButton(
                onTap: () => _action(context, dmodel),
                title: "Confirm",
                color: dmodel.color,
                isLoading: _isLoading,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _singleSelection(BuildContext context, DataModel dmodel) {
    return cv.DynamicSelector<String>(
      selections: widget.poll.choices,
      color: dmodel.color,
      selectorStyle: cv.DynamicSelectorStyle.list,
      onSelect: (context, val) {
        if (_selections.contains(val)) {
          setState(() {
            _selections = [];
          });
        } else {
          setState(() {
            _selections = [];
            _selections.add(val);
          });
        }
      },
      selectedLogic: (context, item) {
        return _selections.contains(item);
      },
    );
  }

  Future<void> _action(BuildContext context, DataModel dmodel) async {
    if (_selections.isNotEmpty) {
      if (!_isLoading) {
        setState(() {
          _isLoading = true;
        });
        await dmodel.updatePollStatus(
            widget.team.teamId,
            widget.season.seasonId,
            widget.poll.sortKey,
            widget.email,
            _selections, () {
          Navigator.of(context).pop();
          widget.onCompletion();
        });
        // check if the user response was the current user
        if (widget.email == dmodel.user!.email) {
          // change this events data to reflect this change
          for (var i in dmodel.polls!) {
            if (i.pollId == widget.poll.pollId) {
              i.userSelections = _selections;
            }
          }
        }
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _getUser(BuildContext context, DataModel dmodel) async {
    await dmodel.getPollUser(widget.team.teamId, widget.season.seasonId,
        widget.poll.sortKey, widget.email, (p0) {
      setState(() {
        _selections = p0.selections;
      });
    }, onError: () {
      Navigator.of(context).pop();
    });
  }
}

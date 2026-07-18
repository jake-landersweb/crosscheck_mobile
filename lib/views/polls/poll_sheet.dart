import 'package:crosscheck_sports/client/root.dart';
import 'package:crosscheck_sports/data/season/poll.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sprung/sprung.dart';
import '../../data/root.dart';
import '../../../custom_views/root.dart' as cv;
import 'package:crosscheck_sports/components/layer/header_bar.dart';
import 'package:crosscheck_sports/components/layer/action_button.dart';
import 'package:crosscheck_sports/components/layer/wide_button.dart';
import 'package:crosscheck_sports/components/layer/field.dart';

class PollSheet extends StatefulWidget {
  const PollSheet({
    super.key,
    required this.poll,
    required this.team,
    required this.season,
    required this.email,
    required this.onCompletion,
  });
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
    return HeaderBar.sheet(
      title: "Answer Poll",
      trailing: XCActionButton.cancel(
        onTap: () => Navigator.of(context).pop(),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _pollBody(context, dmodel),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 700),
              curve: Sprung.overDamped,
              opacity: _selections.isEmpty ? 0.5 : 1,
              child: XCWideButton.primary(
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

  Widget _pollBody(BuildContext context, DataModel dmodel) {
    switch (widget.poll.pollType) {
      case 3:
        return _response(context, dmodel);
      default:
        return _singleSelection(context, dmodel);
    }
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

  Widget _response(BuildContext context, DataModel dmodel) {
    return XCField(
              labelText: "Response",
              isLabeled: true,
              value: _selections.isEmpty ? "" : _selections[0],
              onChanged: (v) {
        if (v.isEmpty) {
          setState(() {
            _selections = [];
          });
          return;
        }
        if (_selections.isEmpty) {
          setState(() {
            _selections = [v];
          });
        } else {
          setState(() {
            _selections[0] = v;
          });
        }
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

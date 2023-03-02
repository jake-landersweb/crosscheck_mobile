import 'package:crosscheck_sports/client/root.dart';
import 'package:crosscheck_sports/data/season/poll.dart';
import 'package:crosscheck_sports/views/polls/polls_ce/root.dart';
import 'package:crosscheck_sports/views/polls/root.dart';
import 'package:crosscheck_sports/views/root.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:sprung/sprung.dart';
import '../../extras/root.dart';
import '../../data/root.dart';
import '../../../custom_views/root.dart' as cv;

class PollDetail extends StatefulWidget {
  const PollDetail({
    Key? key,
    required this.poll,
    required this.team,
    required this.season,
    required this.teamUser,
    this.seasonUser,
  }) : super(key: key);
  final Poll poll;
  final Team team;
  final Season season;
  final SeasonUserTeamFields teamUser;
  final SeasonUser? seasonUser;

  @override
  State<PollDetail> createState() => _PollDetailState();
}

class _PollDetailState extends State<PollDetail> {
  List<SeasonUser>? _users;
  Map<String, int>? _choices;
  int? _totalResponses;
  bool _isLoading = true;

  bool _notificationSending = false;

  @override
  void initState() {
    _getUsers(context, context.read<DataModel>());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    return Container(
      color: CustomColors.backgroundColor(context),
      child: cv.AppBar(
        title: widget.poll.title,
        itemBarPadding: const EdgeInsets.fromLTRB(8, 0, 15, 8),
        isLarge: true,
        leading: [cv.BackButton(color: _accentColor())],
        trailing: [_editButton(context, dmodel)],
        children: [
          _body(context, dmodel),
        ],
      ),
    );
  }

  Widget _body(BuildContext context, DataModel dmodel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // date
        PollTime(
          poll: widget.poll,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        // description
        if (widget.poll.description.isNotEmpty)
          cv.Section(
            "Description",
            child: cv.ListView<Widget>(
              horizontalPadding: 0,
              children: [
                Text(
                  widget.poll.description,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

        // choices
        if (widget.poll.showResults ||
            (widget.seasonUser?.isSeasonAdmin() ?? false) ||
            widget.teamUser.isTeamAdmin())
          cv.Section(
            "Responses${_totalResponses == null ? "" : " - ${_totalResponses!}"}",
            child: Column(
              children: [
                for (var i in widget.poll.choices)
                  Column(
                    children: [
                      _PollChoiceCell(
                        title: i,
                        val: _choices?[i] ?? 0,
                        totalVal: _totalResponses ?? 0,
                      ),
                      if (widget.poll.choices.isNotEmpty &&
                          widget.poll.choices.last != i)
                        const SizedBox(height: 8),
                    ],
                  ),
              ],
            ),
          ),
        if (widget.poll.userIsOn)
          Column(
            children: [
              const SizedBox(height: 16),
              PollButton(
                poll: widget.poll,
                team: widget.team,
                season: widget.season,
                teamUser: widget.teamUser,
                seasonUser: widget.seasonUser,
                didChange: () => _getUsers(context, dmodel),
              ),
            ],
          ),
        if ((widget.seasonUser?.isSeasonAdmin() ?? false) ||
            widget.teamUser.isTeamAdmin())
          Padding(
              padding: const EdgeInsets.only(top: 16),
              child: cv.BasicButton(
                onTap: () {
                  cv.showAlert(
                    context: context,
                    title: "Confirm",
                    body: const Text(
                        "Are you sure you want to send a notification to all people who have not repsonsed to this poll?"),
                    cancelText: "Cancel",
                    onCancel: () {},
                    submitText: "Send",
                    submitBolded: true,
                    onSubmit: () => _sendReminder(dmodel),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: CustomColors.sheetCell(context)),
                  height: 50,
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: _notificationSending
                              ? cv.LoadingIndicator(color: dmodel.color)
                              : Text(
                                  "Send Reminder",
                                  style: TextStyle(
                                    color: widget.poll.userSelections.isEmpty
                                        ? CustomColors.textColor(context)
                                        : dmodel.color,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 18,
                                  ),
                                ),
                        ),
                        Icon(
                          Icons.mail_outline_rounded,
                          color: dmodel.color,
                        ),
                      ],
                    ),
                  ),
                ),
              )),
        _usersList(context, dmodel),
      ],
    );
  }

  Widget _usersList(BuildContext context, DataModel dmodel) {
    return cv.Section(
      "Users",
      child: _isLoading
          ? _usersLoading(context, dmodel)
          : Column(
              children: [
                if (_users != null)
                  for (var i in _users!)
                    Column(
                      children: [
                        if (widget.teamUser.isTeamAdmin() ||
                            (widget.seasonUser?.isSeasonAdmin() ?? false))
                          cv.BasicButton(
                            onTap: () {
                              cv.showFloatingSheet(
                                context: context,
                                builder: (context) {
                                  return PollSheet(
                                    poll: widget.poll,
                                    team: widget.team,
                                    season: widget.season,
                                    email: i.email,
                                    onCompletion: () =>
                                        _getUsers(context, dmodel),
                                  );
                                },
                              );
                            },
                            child: _userCell(
                              context,
                              dmodel,
                              i.email,
                              i.name(widget.team.showNicknames),
                              i.pollFields!.selections.isEmpty
                                  ? ""
                                  : i.pollFields!.selections.first,
                            ),
                          )
                        else
                          _userCell(
                            context,
                            dmodel,
                            i.email,
                            i.name(widget.team.showNicknames),
                            i.pollFields!.selections.isEmpty
                                ? ""
                                : i.pollFields!.selections.first,
                          ),
                        if (_users!.isNotEmpty && i.email != _users!.last.email)
                          const SizedBox(height: 8),
                      ],
                    ),
              ],
            ),
    );
  }

  Widget _userCell(BuildContext context, DataModel dmodel, String email,
      String name, String choice) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: CustomColors.cellColor(context),
      ),
      height: 50,
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: RosterAvatar(name: name, seed: email, size: 48),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 18,
                color: CustomColors.textColor(context),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Text(
              (widget.poll.showResponses ||
                      widget.teamUser.isTeamAdmin() ||
                      (widget.seasonUser?.isSeasonAdmin() ?? false))
                  ? choice.length > 20
                      ? "${choice.substring(0, 19)}..."
                      : choice
                  : choice.isEmpty
                      ? ""
                      : "Responded",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: CustomColors.textColor(context).withOpacity(0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _usersLoading(BuildContext context, DataModel dmodel) {
    return cv.LoadingWrapper(
      child: Column(
        children: [
          for (var i = 0; i < 10; i++)
            Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: CustomColors.cellColor(context),
                  ),
                  height: 50,
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: CustomColors.textColor(context)
                                .withOpacity(0.1),
                          ),
                          width: 48,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Container(
                        height: 10,
                        width: MediaQuery.of(context).size.width / 1.5,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: CustomColors.sheetCell(context),
                        ),
                      ),
                    ],
                  ),
                ),
                if (i != 9) const SizedBox(height: 8),
              ],
            ),
        ],
      ),
    );
  }

  Future<void> _getUsers(BuildContext context, DataModel dmodel) async {
    await dmodel.getPollUsers(
        widget.team.teamId, widget.season.seasonId, widget.poll.sortKey, (p0) {
      setState(() {
        _users = p0;
      });
      Map<String, int> vals = {for (var v in widget.poll.choices) v: 0};
      int responses = 0;
      // compose the choices with their counts
      for (var i in _users!) {
        if (i.pollFields!.selections.isNotEmpty) {
          if (vals.containsKey(i.pollFields!.selections.first)) {
            vals[i.pollFields!.selections.first] =
                vals[i.pollFields!.selections.first]! + 1;
          } else {
            vals[i.pollFields!.selections.first] = 1;
          }
          responses += 1;
        }
      }
      setState(() {
        _choices = vals;
        _totalResponses = responses;
      });
    });
    setState(() {
      _isLoading = false;
    });
  }

  Widget _editButton(BuildContext context, DataModel dmodel) {
    if ((dmodel.currentSeasonUser?.isSeasonAdmin() ?? false) &&
        _users != null) {
      return cv.BasicButton(
        onTap: () {
          cv.cupertinoSheet(
              context: context,
              wrapInNavigator: true,
              builder: (context) {
                return PollsRoot(
                  team: widget.team,
                  season: widget.season,
                  poll: widget.poll,
                  pollUsers: _users!,
                  users: dmodel.seasonUsers!,
                  onAction: () async {
                    await dmodel.getAllPolls(widget.team.teamId,
                        widget.season.seasonId, dmodel.user!.email, (p0) {
                      dmodel.setPolls(p0);
                    });
                  },
                );
              });
        },
        child: Text(
          "Edit",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: _accentColor(),
          ),
        ),
      );
    } else {
      return Container(height: 0);
    }
  }

  Color _accentColor() {
    return widget.poll.color == null
        ? CustomColors.textColor(context).withOpacity(0.5)
        : Theme.of(context).brightness == Brightness.light
            ? widget.poll.getColor()!.darken(0.3).withOpacity(0.7)
            : widget.poll.getColor()!.lighten(0.1);
  }

  Future<void> _sendReminder(DataModel dmodel) async {
    setState(() {
      _notificationSending = true;
    });
    await dmodel.sendPollReminder(
      widget.team.teamId,
      widget.season.seasonId,
      widget.poll.sortKey,
      () {},
    );
    setState(() {
      _notificationSending = false;
    });
  }
}
//
//
//
//
//
//
//
//
//
//

class _PollChoiceCell extends StatefulWidget {
  const _PollChoiceCell({
    Key? key,
    required this.title,
    required this.val,
    required this.totalVal,
  }) : super(key: key);
  final String title;
  final int val;
  final int totalVal;

  @override
  State<_PollChoiceCell> createState() => __PollChoiceCellState();
}

class __PollChoiceCellState extends State<_PollChoiceCell> {
  @override
  Widget build(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    return Stack(
      alignment: AlignmentDirectional.centerStart,
      children: [
        Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: CustomColors.cellColor(context)),
          height: 40,
          width: double.infinity,
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          curve: Sprung(32),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: dmodel.color.withOpacity(0.3),
          ),
          height: 40,
          width: widget.totalVal == 0
              ? 0
              : (MediaQuery.of(context).size.width - 32) *
                  (widget.val / widget.totalVal),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: CustomColors.cellColor(context).withOpacity(0.2),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                  child: Text(
                    widget.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: CustomColors.cellColor(context).withOpacity(0.2),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                  child: Text(
                    widget.totalVal == 0
                        ? "0%"
                        : "${(100 * (widget.val / widget.totalVal)).toInt()}%",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: CustomColors.textColor(context).withOpacity(0.7),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

import 'package:crosscheck_sports/client/root.dart';
import 'package:crosscheck_sports/data/root.dart';
import 'package:crosscheck_sports/data/season/poll.dart';
import 'package:crosscheck_sports/extras/root.dart';
import 'package:crosscheck_sports/views/polls/polls_ce/root.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:crosscheck_sports/components/layer/action_button.dart';
import 'package:crosscheck_sports/components/core/container.dart';
import 'package:crosscheck_sports/style/root.dart';
import 'package:sprung/sprung.dart';
import 'package:table_calendar/table_calendar.dart';

class PollsRoot extends StatefulWidget {
  const PollsRoot({
    super.key,
    this.poll,
    required this.team,
    required this.season,
    required this.users,
    this.pollUsers,
    required this.onAction,
  });
  final Poll? poll;
  final Team team;
  final Season season;
  final List<SeasonUser> users;
  final List<SeasonUser>? pollUsers;
  final VoidCallback onAction;

  @override
  State<PollsRoot> createState() => _PollsRootState();
}

class _PollsRootState extends State<PollsRoot> {
  late PageController _controller;

  @override
  void initState() {
    _controller = PageController();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    return ChangeNotifierProvider<PollsModel>(
      create: (_) => widget.poll == null
          ? PollsModel.create(widget.team, widget.season, widget.users)
          : PollsModel.update(widget.poll!, widget.team, widget.season,
              widget.users, widget.pollUsers!),
      // we use `builder` to obtain a new `BuildContext` that has access to the provider
      builder: (context, child) {
        // No longer throws
        return Scaffold(
          backgroundColor: CustomColors.backgroundColor(context),
          body: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Column(
                children: [
                  Container(
                    color: CustomColors.textColor(context).withValues(alpha: 0.05),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      child: SizedBox(
                        height: XCThemeData.listItemHeight,
                        child: Stack(
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: XCActionButton.cancel(
                                onTap: () => Navigator.of(context, rootNavigator: true).pop(),
                              ),
                            ),
                            Center(
                              child: Text(
                                widget.poll == null ? "Create Poll" : "Edit Poll",
                                style: XCTheme.of(context).text.label,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(child: _body(context, dmodel)),
                ],
              ),
              _navigation(context, dmodel),
            ],
          ),
        );
      },
    );
  }

  Widget _body(BuildContext context, DataModel dmodel) {
    PollsModel pmodel = Provider.of<PollsModel>(context);
    return Column(
      children: [
        Container(
          color: CustomColors.textColor(context).withValues(alpha: 0.05),
          child: Column(children: [
            const SizedBox(height: 8),
            pmodel.status(context, dmodel, _controller),
            const SizedBox(height: 16),
          ]),
        ),
        Expanded(
          child: PageView(
            controller: _controller,
            children: [
              PollsBasic(onAction: widget.onAction),
              const PollsChoices(),
              const PollsUsers(),
            ],
            onPageChanged: (page) {
              pmodel.setIndex(page);
            },
          ),
        ),
      ],
    );
  }

  Widget _navigation(BuildContext context, DataModel dmodel) {
    PollsModel pmodel = Provider.of<PollsModel>(context);
    return SafeArea(
      top: false,
      left: false,
      right: false,
      bottom: true,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
            16, 0, 16, MediaQuery.of(context).padding.bottom == 0 ? 10 : 0),
        child: Row(
          children: [
            AnimatedOpacity(
              opacity: pmodel.index == 0 ? 0 : 1,
              duration: const Duration(milliseconds: 300),
              child: XCContainer.custom(
                customRadius: 25,
                height: 50,
                width: 50,
                color: XCTheme.of(context).cell,
                onTap: () {
                  if (pmodel.index != 0) {
                    _controller.previousPage(
                        duration: const Duration(milliseconds: 700),
                        curve: Sprung.overDamped);
                  }
                },
                child: Icon(
                  Icons.chevron_left,
                  color: XCTheme.of(context).foregroundMuted,
                ),
              ),
            ),
            const Spacer(),
            XCContainer.custom(
              customRadius: 25,
              height: 50,
              onTap: () {
                if (pmodel.isAtEnd()) {
                  if (pmodel.isValidated()) {
                    _action(context, dmodel, pmodel);
                  }
                } else {
                  _controller.nextPage(
                      duration: const Duration(milliseconds: 700),
                      curve: Sprung.overDamped);
                }
              },
              color: pmodel.isAtEnd() && !pmodel.isValidated()
                  ? Colors.red.withValues(alpha: 0.3)
                  : dmodel.color,
              child: AnimatedSize(
                duration: const Duration(milliseconds: 700),
                curve: Sprung.overDamped,
                child: SizedBox(
                  width: pmodel.isAtEnd()
                      ? MediaQuery.of(context).size.width / 1.5
                      : 50,
                  child: Center(
                    child: pmodel.isAtEnd()
                        ? _isLoading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                pmodel.buttonTitle(),
                                softWrap: false,
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                  color: pmodel.isValidated()
                                      ? Colors.white
                                      : Colors.red[900],
                                ),
                              )
                        : const Icon(
                            Icons.chevron_right,
                            color: Colors.white,
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _action(
      BuildContext context, DataModel dmodel, PollsModel pmodel) async {
    setState(() {
      _isLoading = true;
    });

    // compose body
    Map<String, dynamic> body = pmodel.poll.toJson();
    body['addUsers'] = pmodel.addUsers.map((e) => e.email).toList();

    if (pmodel.isCreate) {
      body['date'] = dateToString(pmodel.time);

      await dmodel.createPoll(widget.team.teamId, widget.season.seasonId, body,
          () async {
        widget.onAction();
        Navigator.of(context, rootNavigator: true).pop();
        // reload homepage
        await dmodel.getAllPolls(
            widget.team.teamId, widget.season.seasonId, dmodel.user!.email,
            (p0) {
          dmodel.setPolls(p0);
        });
      });
    } else {
      // update call
      DateTime oldDate = stringToDate(pmodel.poll.date);
      if (isSameDay(oldDate, pmodel.time) && oldDate.hour == pmodel.time.hour) {
        // date is the same
      } else {
        // date not the same, add to body
        body['date'] = dateToString(pmodel.time);
      }

      await dmodel.updatePoll(widget.team.teamId, widget.season.seasonId,
          widget.poll!.sortKey, body, () async {
        widget.onAction();
        Navigator.of(context, rootNavigator: true).pop();
        setState(() {
          dmodel.isScaled = false;
        });
        Navigator.of(context, rootNavigator: true).pop();

        // reload polls
        await dmodel.getAllPolls(
            widget.team.teamId, widget.season.seasonId, dmodel.user!.email,
            (p0) {
          dmodel.setPolls(p0);
        });
      });
    }

    setState(() {
      _isLoading = false;
    });
  }
}

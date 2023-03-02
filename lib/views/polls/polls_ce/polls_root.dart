import 'dart:ui';

import 'package:crosscheck_sports/client/root.dart';
import 'package:crosscheck_sports/data/root.dart';
import 'package:crosscheck_sports/data/season/poll.dart';
import 'package:crosscheck_sports/extras/root.dart';
import 'package:crosscheck_sports/views/polls/polls_ce/root.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:crosscheck_sports/custom_views/root.dart' as cv;
import 'package:sprung/sprung.dart';
import 'package:table_calendar/table_calendar.dart';

class PollsRoot extends StatefulWidget {
  const PollsRoot({
    Key? key,
    this.poll,
    required this.team,
    required this.season,
    required this.users,
    this.pollUsers,
    required this.onAction,
  }) : super(key: key);
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
        return Stack(
          alignment: Alignment.bottomCenter,
          children: [
            cv.AppBar.sheet(
              canScroll: false,
              title: widget.poll == null ? "Create Poll" : "Edit Poll",
              leading: [
                cv.BackButton(
                  title: "Cancel",
                  showIcon: false,
                  useRoot: true,
                  showText: true,
                  color: dmodel.color,
                ),
              ],
              children: [
                Expanded(
                  child: _body(context, dmodel),
                ),
              ],
            ),
            _navigation(context, dmodel),
          ],
        );
      },
    );
  }

  Widget _body(BuildContext context, DataModel dmodel) {
    PollsModel pmodel = Provider.of<PollsModel>(context);
    return Column(
      children: [
        Container(
          color: CustomColors.textColor(context).withOpacity(0.05),
          child: Column(children: [
            const SizedBox(height: 60),
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
      bottom: true,
      top: false,
      left: false,
      right: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
            16, 0, 16, MediaQuery.of(context).padding.bottom == 0 ? 10 : 0),
        child: Row(
          children: [
            AnimatedOpacity(
              opacity: pmodel.index == 0 ? 0 : 1,
              duration: const Duration(milliseconds: 300),
              child: cv.BasicButton(
                onTap: () {
                  if (pmodel.index != 0) {
                    _controller.previousPage(
                        duration: const Duration(milliseconds: 700),
                        curve: Sprung.overDamped);
                  }
                },
                child: cv.GlassContainer(
                  height: 50,
                  width: 50,
                  borderRadius: BorderRadius.circular(25),
                  backgroundColor:
                      CustomColors.textColor(context).withOpacity(0.1),
                  child: Icon(
                    Icons.chevron_left,
                    color: CustomColors.textColor(context).withOpacity(0.7),
                  ),
                ),
              ),
            ),
            const Spacer(),
            cv.BasicButton(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: 5,
                    sigmaY: 5,
                  ),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 700),
                    curve: Sprung.overDamped,
                    decoration: BoxDecoration(
                      color: pmodel.isAtEnd() && !pmodel.isValidated()
                          ? Colors.red.withOpacity(0.3)
                          : dmodel.color,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    width: pmodel.isAtEnd()
                        ? MediaQuery.of(context).size.width / 1.5
                        : 50,
                    height: 50,
                    child: pmodel.isAtEnd()
                        ? Center(
                            child: _isLoading
                                ? const cv.LoadingIndicator(color: Colors.white)
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
                                  ),
                          )
                        : const Icon(
                            Icons.chevron_right,
                            color: Colors.white,
                          ),
                  ),
                ),
              ),
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

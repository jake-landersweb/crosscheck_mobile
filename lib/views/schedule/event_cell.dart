// ignore_for_file: prefer_const_constructors

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:sprung/sprung.dart';
import 'package:provider/provider.dart';

import '../../custom_views/root.dart' as cv;
import '../../data/root.dart';
import '../../client/root.dart';
import '../../extras/root.dart';
import 'root.dart';

class EventCell extends StatefulWidget {
  const EventCell({
    Key? key,
    required this.event,
    required this.email,
    required this.team,
    required this.season,
    this.isExpaded = false,
    this.showStatus,
    required this.isUpcoming,
  }) : super(key: key);

  final Event event;
  final String email;
  final Team team;
  final Season season;
  final bool? isExpaded;
  final bool? showStatus;
  final bool isUpcoming;

  @override
  _EventCellState createState() => _EventCellState();
}

class _EventCellState extends State<EventCell> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late bool _isOpen;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 550),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Sprung.overDamped,
    );
    // open container if is expanded
    if (widget.isExpaded ?? false) {
      _controller.forward();
    }
    _isOpen = widget.isExpaded ?? false;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  _toggleContainer() {
    if (_animation.status != AnimationStatus.completed) {
      _controller.forward();
      setState(() {
        _isOpen = true;
      });
    } else {
      _controller.animateBack(0,
          duration: Duration(milliseconds: 550), curve: Sprung.overDamped);
      setState(() {
        _isOpen = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    return _body(context, dmodel);
  }

  Widget _body(BuildContext context, DataModel dmodel) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: widget.event.getColor() ?? CustomColors.cellColor(context),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _title(context, dmodel),
            const SizedBox(height: 4),
            if (widget.isUpcoming || widget.event.eventType != 1)
              _detailCell(Icons.schedule, widget.event.getTime())
            else
              // _detailCell(Icons.scoreboard_outlined, widget.event.getScore()),
              EventScoreCell(event: widget.event),
            SizeTransition(
              sizeFactor: _animation,
              axis: Axis.vertical,
              child: AnimatedOpacity(
                duration: Duration(milliseconds: 300),
                opacity: _isOpen ? 1 : 0,
                child: Column(
                  children: _detailChildren(context, dmodel),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                // if (_detailChildren(context, dmodel).isNotEmpty)
                cv.BasicButton(
                  onTap: () {
                    _toggleContainer();
                  },
                  child: AnimatedRotation(
                    duration: Duration(milliseconds: 550),
                    curve: Sprung.overDamped,
                    turns: _isOpen ? 0.25 : -0.25,
                    child: Icon(
                      Icons.chevron_left,
                      color: widget.event.eventColor.isEmpty
                          ? CustomColors.textColor(context).withOpacity(0.7)
                          : Colors.white,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                    "${widget.event.inCount} Going  ${widget.event.noResponse + widget.event.undecidedCount} Undecided",
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                      color: (widget.event.eventColor.isEmpty
                              ? CustomColors.textColor(context)
                              : Colors.white)
                          .withOpacity(0.3),
                    ))
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _title(BuildContext context, DataModel dmodel) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: cv.BasicButton(
            onTap: () {
              cv.Navigate(
                context,
                EventDetail2(
                  event: widget.event,
                  email: widget.email,
                  team: widget.team,
                  season: widget.season,
                  isUpcoming: widget.isUpcoming,
                ),
              );
            },
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                widget.event.getTitle(),
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 22,
                  color: widget.event.eventColor.isEmpty
                      ? CustomColors.textColor(context)
                      : Colors.white,
                ),
              ),
            ),
          ),
        ),
        if (widget.event.userStatus != null)
          Padding(
            padding: const EdgeInsets.only(left: 4.0),
            child: EventUserStatus(
              status: widget.event.userStatus!,
              email: widget.email,
              event: widget.event,
              onTap: () {
                if (dmodel.currentSeasonUser == null &&
                    dmodel.seasonUsers != null) {
                  dmodel.addIndicator(
                      IndicatorItem.error("You are not on this season"));
                } else {
                  if (stringToDate(widget.event.eDate)
                          .isAfter(DateTime.now()) ||
                      (dmodel.currentSeasonUser?.isSeasonAdmin() ?? false)) {
                    cv.showFloatingSheet(
                      context: context,
                      builder: (context) {
                        return StatusSelectSheet(
                          email: widget.email,
                          teamId: widget.team.teamId,
                          event: widget.event,
                          isUpcoming: widget.isUpcoming,
                          season: widget.season,
                        );
                      },
                    );
                  }
                }
              },
            ),
          ),
      ],
    );
  }

  List<Widget> _detailChildren(BuildContext context, DataModel dmodel) {
    return [
      if (!widget.event.eventLocation.name.isEmpty())
        _detailCell(
            Icons.location_on_outlined, widget.event.eventLocation.name!),
      if (widget.event.eDescription.isNotEmpty)
        _detailCell(
            Icons.description_outlined,
            widget.event.eDescription.trim().length > 100
                ? widget.event.eDescription.trim().substring(0, 100)
                : widget.event.eDescription.trim()),
      if (widget.event.customFields.isNotEmpty)
        for (var i in widget.event.customFields)
          if (i.value.isNotEmpty) _customCell(i.title, i.value),
      // const SizedBox(height: 4),
      // EventStatuses(
      //     team: widget.team, season: widget.season, event: widget.event),
      Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: EventStatuses(
          team: widget.team,
          season: widget.season,
          event: widget.event,
          isVertical: true,
        ),
      ),
    ];
  }

  Widget _detailCell(IconData icon, String value) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: 35,
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(children: [
              Icon(
                icon,
                color: (widget.event.eventColor.isEmpty
                        ? CustomColors.textColor(context)
                        : Colors.white)
                    .withOpacity(0.5),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  value,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 18,
                    color: (widget.event.eventColor.isEmpty
                            ? CustomColors.textColor(context)
                            : Colors.white)
                        .withOpacity(0.5),
                  ),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _customCell(String label, String value) {
    return cv.LabeledCell(
      label: label,
      value: value,
      height: 35,
      textColor: (widget.event.eventColor.isEmpty
              ? CustomColors.textColor(context)
              : Colors.white)
          .withOpacity(0.5),
    );
  }
}

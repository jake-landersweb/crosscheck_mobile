// ignore_for_file: prefer_const_constructors

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
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            widget.event.getColor() ?? CustomColors.cellColor(context),
            widget.event.eventColor.isEmpty
                ? CustomColors.cellColor(context)
                : widget.event.getColor()!.lighten(),
          ],
          end: Alignment.topLeft,
          begin: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: cv.BasicButton(
                        onTap: () {
                          if (dmodel.seasonUsers != null) {
                            cv.Navigate(
                              context,
                              EventDetail(
                                event: widget.event,
                                email: widget.email,
                                team: widget.team,
                                season: widget.season,
                                isUpcoming: widget.isUpcoming,
                              ),
                            );
                          } else {
                            dmodel.addIndicator(
                                IndicatorItem.error("Fetching user list ..."));
                          }
                        },
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            widget.event.getTitle(),
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 24,
                              color: widget.event.eventColor.isEmpty
                                  ? CustomColors.textColor(context)
                                  : Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // status button
                    if (widget.event.userStatus != null)
                      EventUserStatus(
                        status: widget.event.userStatus!,
                        email: widget.email,
                        event: widget.event,
                        onTap: () {
                          if (dmodel.currentSeasonUser == null &&
                              dmodel.seasonUsers != null) {
                            dmodel.addIndicator(IndicatorItem.error(
                                "You are not on this season"));
                          } else {
                            if (stringToDate(widget.event.eDate)
                                    .isAfter(DateTime.now()) ||
                                (dmodel.currentSeasonUser?.isSeasonAdmin() ??
                                    false)) {
                              cv.showFloatingSheet(
                                context: context,
                                builder: (context) {
                                  return StatusSelectSheet(
                                    email: widget.email,
                                    teamId: widget.team.teamId,
                                    seasonId: widget.season.seasonId,
                                    event: widget.event,
                                    isUpcoming: widget.isUpcoming,
                                  );
                                },
                              );
                            }
                          }
                        },
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                // date and time
                Text(
                  "${widget.event.getDate()} @ ${widget.event.getTime()}",
                  style: TextStyle(
                    color: widget.event.eventColor.isEmpty
                        ? CustomColors.textColor(context).withOpacity(0.5)
                        : Colors.white.withOpacity(0.75),
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                SizeTransition(
                  sizeFactor: _animation,
                  axis: Axis.vertical,
                  child: AnimatedOpacity(
                    duration: Duration(milliseconds: 300),
                    opacity: _isOpen ? 1 : 0,
                    child: Column(
                      children: _detailChildren(context),
                    ),
                  ),
                ),
                // detail toggle
                Row(
                  children: [
                    if (_detailChildren(context).isNotEmpty)
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
                                ? CustomColors.textColor(context)
                                    .withOpacity(0.7)
                                : Colors.white,
                          ),
                        ),
                      ),
                    const Spacer(),
                    if (widget.event.hasAttendance)
                      Row(
                        children: [
                          Text(
                            widget.event.inCount.toString(),
                            style: TextStyle(
                              color: widget.event.eventColor.isEmpty
                                  ? CustomColors.textColor(context)
                                      .withOpacity(0.7)
                                  : Colors.white,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(Icons.check,
                              size: 16,
                              color: widget.event.eventColor.isEmpty
                                  ? CustomColors.textColor(context)
                                      .withOpacity(0.7)
                                  : Colors.white),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _detailChildren(BuildContext context) {
    return [
      if (!widget.event.eventLocation.name.isEmpty())
        _detailCell(Icons.place, widget.event.eventLocation.name!),
      if (!widget.event.eventLocation.address.isEmpty())
        _detailCell(Icons.near_me, widget.event.eventLocation.address!),
      if (widget.event.eDescription.isNotEmpty)
        _detailCell(Icons.description, widget.event.eDescription),
    ];
  }

  Widget _detailCell(IconData icon, String value) {
    return Column(
      children: [
        Row(children: [
          SizedBox(
            width: 36,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Icon(
                icon,
                color: widget.event.eventColor.isEmpty
                    ? CustomColors.textColor(context)
                    : Colors.white,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: widget.event.eventColor.isEmpty
                    ? CustomColors.textColor(context)
                    : Colors.white,
              ),
            ),
          ),
        ]),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build2(BuildContext context) {
    return Material(
      color: CustomColors.cellColor(context),
      // color: Colors.red,
      shape: ContinuousRectangleBorder(
          borderRadius: BorderRadius.circular(cornerRadius)),
      child: Stack(
        alignment: AlignmentDirectional.topEnd,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // main header cell
                _header(context),
                SizeTransition(
                  sizeFactor: _animation,
                  axis: Axis.vertical,
                  child: AnimatedOpacity(
                    duration: Duration(milliseconds: 300),
                    opacity: _isOpen ? 1 : 0,
                    child: Column(
                      children: [
                        SizedBox(height: 8),
                        _details(context),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // indicator for status
          if (widget.event.hasAttendance)
            Padding(
              padding: EdgeInsets.all(8),
              child: cv.Circle(
                7,
                _getStatusColor(widget.event.userStatus ?? 0),
              ),
            )
        ],
      ),
    );
  }

  Widget _header(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 85,
          child: cv.BasicButton(
            onTap: () {
              if (dmodel.seasonUsers != null) {
                cv.Navigate(
                  context,
                  EventDetail(
                    event: widget.event,
                    email: widget.email,
                    team: widget.team,
                    season: widget.season,
                    isUpcoming: widget.isUpcoming,
                  ),
                );
              } else {
                dmodel.addIndicator(
                    IndicatorItem.error("Fetching user list ..."));
              }
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // time
                Text(
                  widget.event.getTime()[0] == "0"
                      ? widget.event.getTime().substring(1)
                      : widget.event.getTime(),
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    color: CustomColors.textColor(context).withOpacity(0.7),
                  ),
                ),
                // title
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.event.getTitle(),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: CustomColors.textColor(context),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        // expand button
        Expanded(
          flex: 15,
          child: cv.BasicButton(
            onTap: () {
              _toggleContainer();
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 0, 0),
              child: AnimatedRotation(
                duration: Duration(milliseconds: 550),
                curve: Sprung.overDamped,
                turns: _isOpen ? 0.25 : -0.25,
                child: Icon(Icons.chevron_left),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _details(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    return Column(
      children: [
        if (widget.event.hasAttendance) SizedBox(height: 8),
        if (widget.event.hasAttendance)
          if (widget.showStatus ?? true && widget.event.userStatus != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: cv.BasicLabel(label: "YOUR STATUS"),
                ),
                cv.BasicButton(
                  onTap: () {
                    // make sure this event has not passed
                    if (dmodel.currentSeasonUser == null &&
                        dmodel.seasonUsers != null) {
                      dmodel.addIndicator(
                          IndicatorItem.error("You are not on this season"));
                    } else {
                      if (stringToDate(widget.event.eDate)
                              .isAfter(DateTime.now()) ||
                          (dmodel.currentSeasonUser?.isSeasonAdmin() ??
                              false)) {
                        cv.showFloatingSheet(
                          context: context,
                          builder: (context) {
                            return StatusSelectSheet(
                              email: widget.email,
                              teamId: widget.team.teamId,
                              seasonId: widget.season.seasonId,
                              event: widget.event,
                              isUpcoming: widget.isUpcoming,
                            );
                          },
                        );
                      }
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: dmodel.color,
                      ),
                    ),
                    height: 40,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _statusCell(
                          dmodel,
                          Icons.cancel_outlined,
                          widget.event.outCount,
                          BorderRadius.only(
                            topLeft: Radius.circular(20),
                            bottomLeft: Radius.circular(20),
                          ),
                          -1,
                        ),
                        Container(height: 40, width: 1, color: dmodel.color),
                        _statusCell(dmodel, Icons.help_outline,
                            widget.event.undecidedCount, null, 2),
                        Container(height: 40, width: 1, color: dmodel.color),
                        _statusCell(
                          dmodel,
                          Icons.check_circle_outline,
                          widget.event.inCount,
                          BorderRadius.only(
                            topRight: Radius.circular(20),
                            bottomRight: Radius.circular(20),
                          ),
                          1,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
        // metadata
        cv.SpacedColumn(
          spacing: 16,
          hasTopSpacing: false,
          children: [
            if (!(widget.event.eventLocation.name).isEmpty())
              EventMetaDataCell(
                title: widget.event.eventLocation.name!,
                icon: Icons.home_outlined,
              ),
            if (!(widget.event.eventLocation.address).isEmpty())
              EventMetaDataCell(
                title: widget.event.eventLocation.address!,
                icon: Icons.near_me,
              ),
            if (widget.event.eLink != "")
              EventMetaDataCell(title: widget.event.eLink, icon: Icons.link),
          ],
        ),
      ],
    );
  }

  Widget _statusCell(DataModel dmodel, IconData icon, int count,
      BorderRadius? radius, int status) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: radius,
          color: widget.event.userStatus == status
              ? dmodel.color
              : Colors.transparent,
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "$count",
                style: TextStyle(
                  color: widget.event.userStatus == status
                      ? Colors.white
                      : dmodel.color,
                ),
              ),
              SizedBox(width: 5),
              Icon(
                icon,
                color: widget.event.userStatus == status
                    ? Colors.white
                    : dmodel.color,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _countCell(int num, Color color) {
    return Text(
      num.toString(),
      style: TextStyle(
        color: color.withOpacity(0.7),
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Color _getStatusColor(int status) {
    switch (status) {
      case -1:
        return Colors.red;
      case 0:
        return Colors.transparent;
      case 1:
        return Colors.green;
      case 2:
        return Colors.yellow;
      default:
        return Colors.transparent;
    }
  }
}

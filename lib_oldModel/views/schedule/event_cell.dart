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
    required this.teamId,
    required this.seasonId,
    this.isExpaded = false,
    this.showStatus,
  }) : super(key: key);

  final Event event;
  final String email;
  final String teamId;
  final String seasonId;
  final bool? isExpaded;
  final bool? showStatus;

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
    return Material(
      color: CustomColors.cellColor(context),
      shape: ContinuousRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                        Divider(
                          height: 0.5,
                          indent: 0,
                        ),
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
              child:
                  cv.Circle(7, _getStatusColor(widget.event.userStatus ?? 0)),
            )
        ],
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 90,
          child: cv.BasicButton(
            onTap: () {
              cv.Navigate(
                context,
                EventDetail(
                  event: widget.event,
                  email: widget.email,
                  teamId: widget.teamId,
                  seasonId: widget.seasonId,
                ),
              );
            },
            child: Row(
              children: [
                // date
                Expanded(
                  flex: MediaQuery.of(context).size.width > 400 ? 25 : 32,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.event.getDate(),
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: CustomColors.textColor(context)
                                .withOpacity(0.7)),
                      ),
                      SizedBox(height: 5),
                      Text(
                        widget.event.getTime(),
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: CustomColors.textColor(context)),
                      )
                    ],
                  ),
                ),
                // SizedBox(width: 8),
                // title
                Expanded(
                  flex: MediaQuery.of(context).size.width > 400 ? 75 : 68,
                  child: Text(
                    widget.event.getTitle(),
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: CustomColors.textColor(context)),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Spacer(),
        // expand button
        Expanded(
          flex: 10,
          child: cv.BasicButton(
            onTap: () {
              _toggleContainer();
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 0, 8),
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
          if (widget.showStatus ?? true)
            Row(
              children: [
                // status select
                EventUserStatus(
                  status: widget.event.userStatus ?? 0,
                  email: dmodel.user!.email,
                  onTap: () {
                    // make sure this event has not passed
                    if (stringToDate(widget.event.eDate)
                            .isAfter(DateTime.now()) ||
                        dmodel.currentSeasonUser!.isSeasonAdmin()) {
                      cv.showFloatingSheet(
                        context: context,
                        builder: (context) {
                          return StatusSelectSheet(
                            email: widget.email,
                            teamId: widget.teamId,
                            seasonId: widget.seasonId,
                            eventId: widget.event.eventId,
                          );
                        },
                      );
                    }
                  },
                ),
                Spacer(),
                // status indicators
                _countCell(widget.event.inCount, Colors.green),
                SizedBox(width: 16),
                _countCell(widget.event.outCount, Colors.red),
                SizedBox(width: 16),
                _countCell(widget.event.undecidedCount,
                    const Color.fromRGBO(235, 197, 9, 1)),
                SizedBox(width: 16),
                _countCell(widget.event.noResponse, Colors.grey),
              ],
            ),
        // metadata
        cv.SpacedColumn(
          spacing: 16,
          hasTopSpacing: true,
          children: [
            if (!widget.event.eLocation.isEmpty())
              EventMetaDataCell(
                  title: widget.event.eLocation!, icon: Icons.near_me),
            if (!widget.event.eLink.isEmpty())
              EventMetaDataCell(title: widget.event.eLink!, icon: Icons.link),
            if (!widget.event.eDescription.isEmpty())
              EventMetaDataCell(
                  title: widget.event.eDescription!, icon: Icons.description),
          ],
        ),
      ],
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

import 'package:flutter/material.dart';
import 'package:crosscheck_sports/data/root.dart';
import 'package:crosscheck_sports/extras/root.dart';

import '../../custom_views/root.dart' as cv;

class EventUserStatus extends StatefulWidget {
  const EventUserStatus({
    Key? key,
    required this.status,
    required this.email,
    required this.event,
    required this.onTap,
    this.showTitle = true,
    this.clickable = true,
  }) : super(key: key);

  final int status;
  final String email;
  final Event event;
  final VoidCallback onTap;
  final bool showTitle;
  final bool clickable;

  @override
  _EventUserStatusState createState() => _EventUserStatusState();
}

class _EventUserStatusState extends State<EventUserStatus> {
  @override
  Widget build(BuildContext context) {
    if (widget.clickable) {
      return cv.BasicButton(
        onTap: widget.onTap,
        child: _child(context),
      );
    } else {
      return _child(context);
    }
  }

  Widget _child(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.event.getStatusColor(widget.status) ??
            CustomColors.textColor(context).withOpacity(0.15),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Icon(
          widget.event.getStatusIcon(widget.status),
          color: Colors.white,
        ),
      ),
    );
  }
}

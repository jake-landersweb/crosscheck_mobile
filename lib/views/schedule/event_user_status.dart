import 'package:flutter/material.dart';
import 'package:pnflutter/data/root.dart';
import 'package:pnflutter/extras/root.dart';

import '../../custom_views/root.dart' as cv;

class EventUserStatus extends StatefulWidget {
  const EventUserStatus({
    Key? key,
    required this.status,
    required this.email,
    required this.event,
    required this.onTap,
    this.showTitle = true,
  }) : super(key: key);

  final int status;
  final String email;
  final Event event;
  final VoidCallback onTap;
  final bool showTitle;

  @override
  _EventUserStatusState createState() => _EventUserStatusState();
}

class _EventUserStatusState extends State<EventUserStatus> {
  @override
  Widget build(BuildContext context) {
    return cv.BasicButton(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: widget.event.getStatusColor(widget.status) ??
              CustomColors.textColor(context).withOpacity(0.15),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Icon(
            widget.event.getStatusIcon(),
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

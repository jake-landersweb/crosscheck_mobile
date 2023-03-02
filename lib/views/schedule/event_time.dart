import 'package:crosscheck_sports/data/root.dart';
import 'package:flutter/material.dart';
import '../../extras/root.dart';
import '../../../custom_views/root.dart' as cv;

class EventTime extends StatefulWidget {
  const EventTime({
    Key? key,
    required this.event,
    this.fontSize,
    this.fontWeight,
    this.color,
  }) : super(key: key);
  final Event event;
  final double? fontSize;
  final FontWeight? fontWeight;
  final Color? color;

  @override
  State<EventTime> createState() => _EventTimeState();
}

class _EventTimeState extends State<EventTime> {
  late bool _showHours;

  @override
  void initState() {
    _showHours =
        widget.event.hourOffset() < 49 && widget.event.hourOffset() > -1;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return cv.BasicButton(
      onTap: () {
        setState(() {
          _showHours = !_showHours;
        });
      },
      child: Row(
        children: [
          Icon(
            _showHours ? Icons.hourglass_top : Icons.insert_invitation,
            color: widget.event.eventColor.isEmpty
                ? CustomColors.textColor(context).withOpacity(0.3)
                : Colors.white.withOpacity(0.5),
          ),
          const SizedBox(width: 8),
          Text(
            _showHours
                ? "${widget.event.hourOffset()} Hours"
                : "${widget.event.getDate()} @ ${widget.event.getTime()}",
            style: TextStyle(
              color: widget.color ??
                  (widget.event.eventColor.isEmpty
                      ? CustomColors.textColor(context)
                      : Colors.white),
              fontWeight: widget.fontWeight ?? FontWeight.w600,
              fontSize: widget.fontSize ?? 18,
            ),
          ),
        ],
      ),
    );
  }
}

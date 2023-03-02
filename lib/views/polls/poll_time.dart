import 'package:crosscheck_sports/data/season/poll.dart';
import 'package:flutter/material.dart';
import '../../extras/root.dart';
import '../../../custom_views/root.dart' as cv;

class PollTime extends StatefulWidget {
  const PollTime({
    Key? key,
    required this.poll,
    this.fontSize,
    this.fontWeight,
  }) : super(key: key);
  final Poll poll;
  final double? fontSize;
  final FontWeight? fontWeight;

  @override
  State<PollTime> createState() => _PollTimeState();
}

class _PollTimeState extends State<PollTime> {
  late bool _showHours;

  @override
  void initState() {
    _showHours = widget.poll.hourOffset() < 49 && widget.poll.hourOffset() > -1;
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
          Icon(_showHours ? Icons.hourglass_top : Icons.insert_invitation),
          const SizedBox(width: 8),
          Text(
            _showHours
                ? "${widget.poll.hourOffset()} Hours"
                : "${widget.poll.getDate()} @ ${widget.poll.getTime()}",
            style: TextStyle(
              color: widget.poll.color == null
                  ? CustomColors.textColor(context).withOpacity(0.5)
                  : Colors.white.withOpacity(0.75),
              fontWeight: widget.fontWeight ?? FontWeight.w500,
              fontSize: widget.fontSize ?? 16,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../custom_views/root.dart' as cv;

class EventUserStatus extends StatefulWidget {
  const EventUserStatus({
    Key? key,
    required this.status,
    required this.email,
    required this.onTap,
    this.showTitle = true,
  }) : super(key: key);

  final int status;
  final String email;
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
      child: Material(
        color: _getColor().withOpacity(0.5),
        shape:
            ContinuousRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              Icon(_getIcon(), color: _getColor()),
              if (widget.showTitle)
                Row(
                  children: [
                    const SizedBox(width: 10),
                    Text(
                      _getTitle().toUpperCase(),
                      style: TextStyle(color: _getColor(), fontSize: 20),
                    ),
                  ],
                )
            ],
          ),
        ),
      ),
    );
  }

  Color _getColor() {
    switch (widget.status) {
      case 0:
        return Colors.grey;
      case -1:
        return Colors.red;
      case 1:
        return Colors.green;
      case 2:
        return const Color.fromRGBO(235, 197, 9, 1);
      default:
        return Colors.grey;
    }
  }

  String _getTitle() {
    switch (widget.status) {
      case 0:
        return "no response";
      case -1:
        return "out";
      case 1:
        return "in";
      case 2:
        return "undecided";
      default:
        return "no data";
    }
  }

  IconData _getIcon() {
    switch (widget.status) {
      case 0:
        return Icons.remove_circle_outline;
      case -1:
        return Icons.cancel;
      case 1:
        return Icons.check_circle;
      case 2:
        return Icons.help_outline;
      default:
        return Icons.remove_circle_outline;
    }
  }
}

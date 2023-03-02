import 'package:crosscheck_sports/data/root.dart';
import 'package:crosscheck_sports/extras/root.dart';
import 'package:flutter/material.dart';

class EventScoreCell extends StatelessWidget {
  const EventScoreCell({
    super.key,
    required this.event,
    this.height,
    this.iconSize,
    this.defaultIconColor,
    this.useEventColor = true,
  });
  final Event event;
  final double? height;
  final double? iconSize;
  final Color? defaultIconColor;
  final bool useEventColor;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: height ?? 35,
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(children: [
              Icon(
                _icon(context),
                color: _iconColor(context),
                size: iconSize,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      (event.homeTeam?.score ?? 0).toString(),
                      style: TextStyle(
                        fontWeight: event.isHomeTeam()
                            ? FontWeight.w500
                            : FontWeight.w400,
                        fontSize: 18,
                        color: (useEventColor
                                ? event.textColor(context)
                                : CustomColors.textColor(context))
                            .withOpacity(event.isHomeTeam() ? 1 : 0.5),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3.0),
                      child: Text(
                        "-",
                        style: TextStyle(
                          color: (useEventColor
                                  ? event.textColor(context)
                                  : CustomColors.textColor(context))
                              .withOpacity(0.5),
                        ),
                      ),
                    ),
                    Text(
                      (event.awayTeam?.score ?? 0).toString(),
                      style: TextStyle(
                        fontWeight: event.isHomeTeam()
                            ? FontWeight.w400
                            : FontWeight.w500,
                        fontSize: 18,
                        color: (useEventColor
                                ? event.textColor(context)
                                : CustomColors.textColor(context))
                            .withOpacity(event.isHomeTeam() ? 0.5 : 1),
                      ),
                    ),
                  ],
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Color _iconColor(BuildContext context) {
    switch (_scoreStatus()) {
      case 1:
        return Colors.amberAccent;
      case -1:
        return Colors.red[300]!;
      default:
        return defaultIconColor ??
            (useEventColor
                    ? event.textColor(context)
                    : CustomColors.textColor(context))
                .withOpacity(0.5);
    }
  }

  IconData _icon(BuildContext context) {
    switch (_scoreStatus()) {
      case 1:
        return Icons.wine_bar_outlined;
      case -1:
        return Icons.cancel_outlined;
      default:
        return Icons.scoreboard_outlined;
    }
  }

  int _scoreStatus() {
    if ((event.homeTeam?.score ?? 0) == (event.awayTeam?.score ?? 0)) {
      return 0;
    } else {
      return event.isHomeTeam()
          ? ((event.homeTeam?.score ?? 0) > (event.awayTeam?.score ?? 0)
              ? 1
              : -1)
          : ((event.awayTeam?.score ?? 0) > (event.homeTeam?.score ?? 0)
              ? 1
              : -1);
    }
  }
}

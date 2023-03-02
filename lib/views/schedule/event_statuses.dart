import 'dart:developer';

import 'package:crosscheck_sports/client/root.dart';
import 'package:crosscheck_sports/data/root.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';
import '../../extras/root.dart';
import '../../../custom_views/root.dart' as cv;
import '../../extras/root.dart';

class EventStatuses extends StatelessWidget {
  const EventStatuses({
    super.key,
    required this.team,
    required this.season,
    required this.event,
    this.height,
    this.borderRadius,
    this.backgroundColor,
    this.textColor,
    this.isVertical = false,
  });
  final Team team;
  final Season season;
  final Event event;
  final double? height;
  final double? borderRadius;
  final Color? backgroundColor;
  final Color? textColor;
  final bool isVertical;

  @override
  Widget build(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    if (isVertical) {
      return Column(
        children: [
          _countCell(
            context,
            dmodel,
            event.inCount,
            "Going",
            event.inCount > 0,
          ),
          const SizedBox(height: 4),
          // only show mvps for practices and games
          if (season.positions.mvp.isNotEmpty &&
              (event.eventType == 1 || event.eventType == 2))
            _countCell(
              context,
              dmodel,
              event.mvps,
              "${season.positions.mvp}${event.mvps == 1 ? '' : 's'}",
              event.mvps > 0,
              icon: season.mvpIcon(
                context,
                textColor ??
                    (event.eventColor.isEmpty
                        ? CustomColors.textColor(context)
                        : Colors.white),
                size: 18,
              ),
            )
          else
            _countCell(
              context,
              dmodel,
              event.undecidedCount + event.noResponse,
              "Undecided",
              event.undecidedCount + event.noResponse > 0,
            ),
        ],
      );
    } else {
      return Row(
        children: [
          Expanded(
            child: _countCell(
              context,
              dmodel,
              event.inCount,
              "Going",
              event.inCount > 0,
            ),
          ),
          const SizedBox(width: 4),
          // only show mvps for practices and games
          if (season.positions.mvp.isNotEmpty &&
              (event.eventType == 1 || event.eventType == 2))
            Expanded(
              child: _countCell(
                context,
                dmodel,
                event.mvps,
                "${season.positions.mvp}${event.mvps == 1 ? '' : 's'}",
                event.mvps > 0,
                icon: season.mvpIcon(
                  context,
                  textColor ??
                      (event.eventColor.isEmpty
                          ? CustomColors.textColor(context)
                          : Colors.white),
                  size: 18,
                ),
              ),
            )
          else
            Expanded(
              child: _countCell(
                context,
                dmodel,
                event.undecidedCount + event.noResponse,
                "Undecided",
                event.undecidedCount + event.noResponse > 0,
              ),
            ),
        ],
      );
    }
  }

  Widget _countCell(BuildContext context, DataModel dmodel, int val,
      String label, bool completed,
      {Widget? icon}) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius ?? 5),
        color: backgroundColor ??
            (event.eventColor.isEmpty
                ? CustomColors.textColor(context).withOpacity(0.1)
                : Colors.white.withOpacity(0.2)),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: icon,
                ),
              Text(
                "$val $label",
                style: TextStyle(
                  color: textColor ??
                      (event.eventColor.isEmpty
                          ? CustomColors.textColor(context)
                          : Colors.white),
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

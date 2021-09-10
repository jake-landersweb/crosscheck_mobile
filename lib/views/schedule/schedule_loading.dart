import 'package:flutter/material.dart';
import '../../extras/root.dart';
import 'dart:math' as math;

class ScheduleLoading extends StatefulWidget {
  const ScheduleLoading({Key? key}) : super(key: key);

  @override
  _ScheduleLoadingState createState() => _ScheduleLoadingState();
}

class _ScheduleLoadingState extends State<ScheduleLoading> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        Divider(),
        EventCellLoading(
          isExpanded: true,
        ),
        SizedBox(height: 16),
        EventCellLoading(
          isExpanded: false,
        ),
        SizedBox(height: 16),
        EventCellLoading(
          isExpanded: false,
        ),
        SizedBox(height: 16),
        EventCellLoading(
          isExpanded: false,
        ),
      ],
    );
  }
}

class EventCellLoading extends StatelessWidget {
  const EventCellLoading({
    Key? key,
    this.isExpanded = false,
  }) : super(key: key);
  final bool isExpanded;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: CustomColors.cellColor(context),
      shape: ContinuousRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _title(context),
            if (isExpanded)
              Column(
                children: [
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: Container(
                      height: 10,
                      color: Theme.of(context).brightness == Brightness.light
                          ? Colors.black.withOpacity(0.3)
                          : Colors.white.withOpacity(0.3),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: Container(
                      height: 10,
                      color: Theme.of(context).brightness == Brightness.light
                          ? Colors.black.withOpacity(0.3)
                          : Colors.white.withOpacity(0.3),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: Container(
                      height: 10,
                      color: Theme.of(context).brightness == Brightness.light
                          ? Colors.black.withOpacity(0.3)
                          : Colors.white.withOpacity(0.3),
                    ),
                  ),
                ],
              )
          ],
        ),
      ),
    );
  }

  Widget _title(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 20,
          child: Container(
            height: 20,
            color: Theme.of(context).brightness == Brightness.light
                ? Colors.black.withOpacity(0.3)
                : Colors.white.withOpacity(0.3),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 70,
          child: Container(
            height: 20,
            color: Theme.of(context).brightness == Brightness.light
                ? Colors.black.withOpacity(0.3)
                : Colors.white.withOpacity(0.3),
          ),
        ),
        const SizedBox(width: 8),
        Transform.rotate(
          angle: -math.pi / 2,
          child: Icon(
            Icons.chevron_left,
            color: Theme.of(context).brightness == Brightness.light
                ? Colors.black.withOpacity(0.3)
                : Colors.white.withOpacity(0.3),
          ),
        )
      ],
    );
  }
}

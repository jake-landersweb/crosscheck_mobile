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
      children: [
        const Divider(),
        const EventCellLoading(
          isExpanded: true,
        ),
        for (var i = 0; i < 10; i++)
          Column(
            children: const [
              SizedBox(height: 16),
              EventCellLoading(
                isExpanded: false,
              ),
            ],
          ),
        const SizedBox(height: 48),
      ],
    );
  }
}

class EventCellLoading extends StatefulWidget {
  const EventCellLoading({
    Key? key,
    this.isExpanded = false,
  }) : super(key: key);
  final bool isExpanded;

  @override
  State<EventCellLoading> createState() => _EventCellLoadingState();
}

class _EventCellLoadingState extends State<EventCellLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation _animation;

  @override
  void initState() {
    _animationController =
        AnimationController(vsync: this, duration: Duration(seconds: 1));
    _animationController.repeat(reverse: true);
    _animation = Tween(begin: 0.3, end: 1.0).animate(_animationController)
      ..addListener(() {
        setState(() {});
      });
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: CustomColors.cellColor(context),
      shape: ContinuousRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Opacity(
              opacity: _animation.value,
              child: _title(context),
            ),
            if (widget.isExpanded)
              Opacity(
                opacity: _animation.value,
                child: Column(
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
                ),
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
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  height: 20,
                  width: MediaQuery.of(context).size.width * 0.15,
                  color: Theme.of(context).brightness == Brightness.light
                      ? Colors.black.withOpacity(0.3)
                      : Colors.white.withOpacity(0.3),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 20,
                color: Theme.of(context).brightness == Brightness.light
                    ? Colors.black.withOpacity(0.3)
                    : Colors.white.withOpacity(0.3),
              ),
            ],
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

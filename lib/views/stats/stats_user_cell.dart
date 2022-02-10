import 'package:flutter/material.dart';
import 'package:pnflutter/data/root.dart';
import 'package:pnflutter/extras/root.dart';
import 'package:sprung/sprung.dart';
import '../../custom_views/root.dart' as cv;

class StatsUserCell extends StatefulWidget {
  const StatsUserCell({
    Key? key,
    required this.userStat,
    this.currentStat = "",
  }) : super(key: key);
  final UserStat userStat;
  final String currentStat;

  @override
  _StatsUserCellState createState() => _StatsUserCellState();
}

class _StatsUserCellState extends State<StatsUserCell>
    with TickerProviderStateMixin {
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
    _isOpen = false;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  _toggleContainer() {
    if (_animation.status != AnimationStatus.completed) {
      _controller.forward();
      setState(() {
        _isOpen = true;
      });
    } else {
      _controller.animateBack(0,
          duration: const Duration(milliseconds: 550),
          curve: Sprung.overDamped);
      setState(() {
        _isOpen = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return cv.BasicButton(
      onTap: () {
        _toggleContainer();
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: CustomColors.cellColor(context),
        ),
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // avatar
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      cv.Circle(50, CustomColors.random(widget.userStat.email)),
                      Text(
                        (widget.userStat.getName())[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 30,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      widget.userStat.getName(),
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                        color: CustomColors.textColor(context),
                      ),
                    ),
                  ),
                  // for showing current stat
                  if (widget.currentStat != "")
                    Text(
                        "${widget.userStat.stats.firstWhere((element) => element.title == widget.currentStat, orElse: () => StatObject(title: "", value: 0)).value}"),
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: AnimatedRotation(
                      duration: const Duration(milliseconds: 550),
                      curve: Sprung.overDamped,
                      turns: _isOpen ? 0.25 : -0.25,
                      child: Icon(Icons.chevron_left,
                          color:
                              CustomColors.textColor(context).withOpacity(0.7)),
                    ),
                  ),
                ],
              ),
              SizeTransition(
                sizeFactor: _animation,
                axis: Axis.vertical,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: _isOpen ? 1 : 0,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: _stats(context),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // list of all stats and values
  Widget _stats(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i in widget.userStat.stats)
          Text(
              "${i.title[0].toUpperCase()}${i.title.substring(1)}: ${i.value}"),
      ],
    );
  }
}

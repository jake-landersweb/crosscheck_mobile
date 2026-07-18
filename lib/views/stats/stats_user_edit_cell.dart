import 'package:flutter/material.dart';
import 'package:crosscheck_sports/data/root.dart';
import 'package:crosscheck_sports/extras/root.dart';
import '../../custom_views/root.dart' as cv;
import 'package:crosscheck_sports/components/core/cell_list.dart';

class StatUserEditCell extends StatefulWidget {
  const StatUserEditCell({
    super.key,
    required this.team,
    required this.userStat,
    required this.color,
  });
  final Team team;
  final UserStat userStat;
  final Color color;

  @override
  _StatUserEditCellState createState() => _StatUserEditCellState();
}

class _StatUserEditCellState extends State<StatUserEditCell> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                cv.Circle(50, CustomColors.random(widget.userStat.email)),
                Text(
                  (widget.userStat.getName(widget.team))[0].toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 30,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Text(
              widget.userStat.getName(widget.team),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        XCCellList<StatObject>(
          horizontalPadding: 0,
          childPadding: const EdgeInsets.symmetric(horizontal: 16),
          children: widget.userStat.stats,
          childBuilder: (context, i) {
            return cv.NumberTextField(
              label: i.title,
              initValue: i.value,
              color: widget.color,
              onChange: (val) {
                i.value = val;
              },
            );
          },
        ),
      ],
    );
  }
}

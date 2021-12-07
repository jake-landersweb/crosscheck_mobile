import 'package:flutter/material.dart';
import '../../../data/root.dart';
import '../../../custom_views/root.dart' as cv;
import 'package:flutter_switch/flutter_switch.dart';

class PositionCell extends StatefulWidget {
  const PositionCell({
    Key? key,
    required this.position,
    required this.onSelect,
    required this.positions,
  }) : super(key: key);
  final String position;
  final Function(String) onSelect;
  final TeamPositions positions;

  @override
  _PositionCellState createState() => _PositionCellState();
}

class _PositionCellState extends State<PositionCell> {
  @override
  Widget build(BuildContext context) {
    return cv.AnimatedList<String>(
      children: widget.positions.available,
      cellBuilder: (context, item) {
        return SizedBox(height: 40, child: Text(item));
      },
    );
  }
}

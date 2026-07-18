import 'package:flutter/material.dart';
import 'package:crosscheck_sports/data/root.dart';
import 'package:crosscheck_sports/components/layer/field.dart';

class StatCECell extends StatefulWidget {
  const StatCECell({
    super.key,
    required this.item,
    this.color = Colors.blue,
    required this.onTitleChange,
  });
  final StatItem item;
  final Color color;
  final Function(String) onTitleChange;

  @override
  _StatCECellState createState() => _StatCECellState();
}

class _StatCECellState extends State<StatCECell> {
  @override
  Widget build(BuildContext context) {
    return XCField(
              value: widget.item.getTitle(),
              labelText: "Title",
              onChanged: (value) {
        setState(() {
          widget.onTitleChange(value);
        });
      },
              isLabeled: true,
            );
  }
}

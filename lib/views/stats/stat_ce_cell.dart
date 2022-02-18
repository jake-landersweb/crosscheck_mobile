import 'package:flutter/material.dart';
import 'package:pnflutter/data/root.dart';
import '../../custom_views/root.dart' as cv;

class StatCECell extends StatefulWidget {
  const StatCECell({
    Key? key,
    required this.item,
    this.color = Colors.blue,
    required this.onTitleChange,
  }) : super(key: key);
  final StatItem item;
  final Color color;
  final Function(String) onTitleChange;

  @override
  _StatCECellState createState() => _StatCECellState();
}

class _StatCECellState extends State<StatCECell> {
  @override
  Widget build(BuildContext context) {
    return cv.TextField(
      fieldPadding: EdgeInsets.zero,
      value: widget.item.getTitle(),
      labelText: "Title",
      onChanged: (value) {
        setState(() {
          widget.onTitleChange(value);
        });
      },
      validator: (value) {},
      isLabeled: true,
    );
  }
}

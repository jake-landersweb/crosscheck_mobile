import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pnflutter/client/root.dart';
import 'package:pnflutter/data/root.dart';
import 'package:pnflutter/extras/root.dart';
import 'package:pnflutter/views/root.dart';
import 'package:provider/provider.dart';
import 'package:sprung/sprung.dart';
import '../../custom_views/root.dart' as cv;

class StatUserEditCell extends StatefulWidget {
  const StatUserEditCell({
    Key? key,
    required this.userStat,
  }) : super(key: key);
  final UserStat userStat;

  @override
  _StatUserEditCellState createState() => _StatUserEditCellState();
}

class _StatUserEditCellState extends State<StatUserEditCell> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: CustomColors.cellColor(context),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
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
                Text(
                  widget.userStat.getName(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            const Divider(),
            for (var i in widget.userStat.stats)
              TextEditCellField(
                label: i.title,
                initialValue: i.value.toString(),
                onChanged: (value) {
                  i.value = value;
                },
              ),
          ],
        ),
      ),
    );
  }
}

class TextEditCellField extends StatefulWidget {
  const TextEditCellField({
    Key? key,
    required this.label,
    required this.initialValue,
    required this.onChanged,
  }) : super(key: key);
  final String label;
  final String initialValue;
  final Function(int) onChanged;

  @override
  _TextEditCellFieldState createState() => _TextEditCellFieldState();
}

class _TextEditCellFieldState extends State<TextEditCellField> {
  late TextEditingController controller;
  late String oldVal;

  @override
  void initState() {
    controller = TextEditingController(text: widget.initialValue);
    oldVal = widget.initialValue;
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return cv.TextField(
      fieldPadding: EdgeInsets.zero,
      controller: controller,
      isLabeled: true,
      formatters: [FilteringTextInputFormatter.digitsOnly],
      showBackground: false,
      labelText: widget.label,
      validator: (value) {},
      onChanged: (value) {
        widget.onChanged(int.parse(value));
      },
    );
  }
}

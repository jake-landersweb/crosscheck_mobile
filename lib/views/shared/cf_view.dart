import 'package:flutter/material.dart';
import '../../data/root.dart';
import 'root.dart';
import 'package:crosscheck_sports/components/core/cell_list.dart';

class CustomFieldView extends StatefulWidget {
  const CustomFieldView({
    super.key,
    required this.customFields,
    this.color = Colors.blue,
    this.cellColor,
  });
  final List<CustomField> customFields;
  final Color color;
  final Color? cellColor;

  @override
  _CustomFieldViewState createState() => _CustomFieldViewState();
}

class _CustomFieldViewState extends State<CustomFieldView> {
  @override
  Widget build(BuildContext context) {
    return XCCellList<Widget>(
      backgroundColor: widget.cellColor,
      horizontalPadding: 0,
      childPadding: EdgeInsets.zero,
      children: [
        for (var i in widget.customFields)
          CustomFieldField(
            item: i,
            color: widget.color,
            isCreate: false,
          ),
      ],
    );
  }
}

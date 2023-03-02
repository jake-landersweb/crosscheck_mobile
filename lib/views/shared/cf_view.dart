import 'package:flutter/material.dart';
import 'package:crosscheck_sports/extras/root.dart';
import '../../data/root.dart';
import 'root.dart';
import '../../custom_views/root.dart' as cv;

class CustomFieldView extends StatefulWidget {
  const CustomFieldView({
    Key? key,
    required this.customFields,
    this.color = Colors.blue,
    this.cellColor,
  }) : super(key: key);
  final List<CustomField> customFields;
  final Color color;
  final Color? cellColor;

  @override
  _CustomFieldViewState createState() => _CustomFieldViewState();
}

class _CustomFieldViewState extends State<CustomFieldView> {
  @override
  Widget build(BuildContext context) {
    return cv.NativeList(
      color: widget.cellColor,
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

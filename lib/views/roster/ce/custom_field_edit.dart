import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:crosscheck_sports/data/root.dart';
import 'package:crosscheck_sports/extras/root.dart';
import '../../../custom_views/root.dart' as cv;

class CustomFieldEdit extends StatefulWidget {
  const CustomFieldEdit({
    Key? key,
    required this.field,
    this.color = Colors.blue,
  }) : super(key: key);
  final CustomField field;
  final Color color;

  @override
  _CustomFieldEditState createState() => _CustomFieldEditState();
}

class _CustomFieldEditState extends State<CustomFieldEdit> {
  @override
  Widget build(BuildContext context) {
    switch (widget.field.getType()) {
      case "S":
        return _stringCell(context);
      case "I":
        return _intCell(context);
      case "B":
        return _boolCell(context);
      default:
        return Container();
    }
  }

  Widget _stringCell(BuildContext context) {
    return cv.TextField2(
      labelText: widget.field.getTitle(),
      value: widget.field.getValue(),
      onChanged: (value) {
        setState(() {
          widget.field.setValue(value);
        });
      },
      isLabeled: true,
      fieldPadding: EdgeInsets.zero,
    );
  }

  Widget _intCell(BuildContext context) {
    return cv.NumberTextField(
      label: widget.field.getTitle(),
      onChange: (p0) {
        setState(() {
          widget.field.setValue(p0.toString());
        });
      },
      initValue: int.tryParse(widget.field.getValue()) ?? 0,
      color: widget.color,
    );
  }

  Widget _boolCell(BuildContext context) {
    return cv.LabeledWidget(
      widget.field.getTitle(),
      child: Row(
        children: [
          FlutterSwitch(
            value: widget.field.getValue() == "true" ? true : false,
            height: 25,
            width: 50,
            toggleSize: 18,
            activeColor: widget.color,
            onToggle: (value) {
              setState(() {
                widget.field.setValue(value.toString());
              });
            },
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

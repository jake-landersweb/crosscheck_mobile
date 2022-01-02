import 'package:flutter/material.dart';
import '../../data/root.dart';
import '../../custom_views/root.dart' as cv;
import '../../extras/root.dart';
import 'package:flutter_switch/flutter_switch.dart';

class CustomFieldCell extends StatefulWidget {
  const CustomFieldCell({
    Key? key,
    required this.field,
    this.color = Colors.blue,
  }) : super(key: key);
  final DynamicField field;
  final Color color;

  @override
  _CustomFieldCellState createState() => _CustomFieldCellState();
}

class _CustomFieldCellState extends State<CustomFieldCell> {
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
    return cv.TextField(
      labelText: widget.field.getTitle(),
      value: widget.field.getValue(),
      onChanged: (value) {
        setState(() {
          widget.field.setValue(value);
        });
      },
      validator: (value) {},
      isLabeled: true,
      fieldPadding: EdgeInsets.zero,
    );
  }

  Widget _intCell(BuildContext context) {
    return cv.LabeledWidget(
      widget.field.getTitle(),
      child: Row(
        children: [
          SizedBox(
            width: 50,
            child: Align(
              alignment: Alignment.center,
              child: Text(
                widget.field.getValue(),
                style:
                    const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
              ),
            ),
          ),
          cv.NumberPicker(
            initialValue: int.tryParse(widget.field.getValue()) ?? 0,
            plusBackgroundColor: widget.color,
            minusBackgroundColor:
                CustomColors.textColor(context).withOpacity(0.1),
            onMinusClick: (value) {
              setState(() {
                widget.field.setValue(value.toString());
              });
            },
            onPlusClick: (value) {
              setState(() {
                widget.field.setValue(value.toString());
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _boolCell(BuildContext context) {
    return cv.LabeledWidget(
      widget.field.getTitle(),
      child: FlutterSwitch(
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
    );
  }
}

import 'package:flutter/material.dart';
import '../../../data/root.dart';
import '../../../custom_views/root.dart' as cv;
import 'package:flutter_switch/flutter_switch.dart';

class CustomFieldField extends StatefulWidget {
  const CustomFieldField({
    Key? key,
    required this.item,
  }) : super(key: key);
  final CustomField item;

  @override
  _CustomFieldFieldState createState() => _CustomFieldFieldState();
}

class _CustomFieldFieldState extends State<CustomFieldField> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        cv.TextField(
          fieldPadding: const EdgeInsets.all(0),
          showBackground: false,
          initialvalue: widget.item.title,
          isLabeled: true,
          labelText: "Title",
          charLimit: 25,
          showCharacters: true,
          onChanged: (value) {
            widget.item.title = value;
          },
          validator: (value) {},
        ),
        cv.SegmentedPicker(
          initialSelection: widget.item.type,
          titles: const ["Word", "Number", "True/False"],
          selections: const ["S", "I", "B"],
          onSelection: (value) {
            setState(() {
              widget.item.setType(value);
            });
          },
        ),
        SizedBox(height: 50, child: Center(child: _valField(context))),
      ],
    );
  }

  Widget _valField(BuildContext context) {
    switch (widget.item.type) {
      case "S":
        return cv.TextField(
          fieldPadding: const EdgeInsets.all(0),
          showBackground: false,
          isLabeled: true,
          initialvalue: widget.item.stringVal ?? "",
          labelText: "Value",
          charLimit: 25,
          showCharacters: true,
          onChanged: (value) {
            widget.item.setStringVal(value);
          },
          validator: (value) {},
        );
      case "I":
        return cv.LabeledWidget(
          "Value",
          child: Row(
            children: [
              SizedBox(
                width: 50,
                child: Center(
                  child: Text(
                    (widget.item.intVal ?? 0).toString(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              cv.NumberPicker(
                minValue: -100,
                maxValue: 100,
                onMinusClick: (value) {
                  setState(() {
                    widget.item.setIntVal(value);
                  });
                },
                onPlusClick: (value) {
                  setState(() {
                    widget.item.setIntVal(value);
                  });
                },
              ),
            ],
          ),
        );
      default:
        return cv.LabeledWidget(
          "Value",
          child: FlutterSwitch(
            value: widget.item.boolVal ?? false,
            height: 25,
            width: 50,
            toggleSize: 18,
            activeColor: Theme.of(context).colorScheme.primary,
            onToggle: (value) {
              setState(() {
                widget.item.setBoolVal(value);
              });
            },
          ),
        );
    }
  }
}

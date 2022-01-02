import 'package:flutter/material.dart';
import '../../data/root.dart';
import '../../custom_views/root.dart' as cv;
import 'package:flutter_switch/flutter_switch.dart';

class CustomFieldField extends StatefulWidget {
  const CustomFieldField({
    Key? key,
    required this.item,
    this.color = Colors.blue,
  }) : super(key: key);
  final DynamicField item;
  final Color color;

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
          value: widget.item.getTitle(),
          isLabeled: true,
          labelText: "Title",
          charLimit: 25,
          showCharacters: true,
          onChanged: (value) {
            widget.item.setTitle(value);
          },
          validator: (value) {},
        ),
        cv.SegmentedPicker(
          initialSelection: widget.item.getType(),
          titles: const ["Word", "Number", "True/False"],
          selections: const ["S", "I", "B"],
          onSelection: (value) {
            // change the type
            setState(() {
              widget.item.setType(value);
            });
            // change the value
            switch (value) {
              case "S":
                setState(() {
                  widget.item.setValue("");
                });
                break;
              case "I":
                setState(() {
                  widget.item.setValue("0");
                });
                break;
              default:
                setState(() {
                  widget.item.setValue("false");
                });
            }
          },
        ),
        SizedBox(height: 50, child: Center(child: _valField(context))),
      ],
    );
  }

  Widget _valField(BuildContext context) {
    switch (widget.item.getType()) {
      case "S":
        return cv.TextField(
          fieldPadding: const EdgeInsets.all(0),
          showBackground: false,
          isLabeled: true,
          value: widget.item.getValue(),
          labelText: "Value",
          charLimit: 25,
          showCharacters: true,
          onChanged: (value) {
            widget.item.setValue(value);
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
                    widget.item.getValue(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              cv.NumberPicker(
                plusBackgroundColor: widget.color,
                minValue: -100,
                maxValue: 100,
                onMinusClick: (value) {
                  setState(() {
                    widget.item.setValue(value);
                  });
                },
                onPlusClick: (value) {
                  setState(() {
                    widget.item.setValue(value);
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
            value: widget.item.getValue() == "true" ? true : false,
            height: 25,
            width: 50,
            toggleSize: 18,
            activeColor: Theme.of(context).colorScheme.primary,
            onToggle: (value) {
              setState(() {
                widget.item.setValue(value);
              });
            },
          ),
        );
    }
  }
}

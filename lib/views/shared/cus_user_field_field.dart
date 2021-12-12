import 'package:flutter/material.dart';
import '../../data/root.dart';
import '../../custom_views/root.dart' as cv;
import 'package:flutter_switch/flutter_switch.dart';

class CustomUserFieldField extends StatefulWidget {
  const CustomUserFieldField({
    Key? key,
    required this.item,
  }) : super(key: key);
  final CustomUserField item;

  @override
  _CustomUserFieldFieldState createState() => _CustomUserFieldFieldState();
}

class _CustomUserFieldFieldState extends State<CustomUserFieldField> {
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
            widget.item.setTitle(value);
          },
          validator: (value) {},
        ),
        cv.SegmentedPicker(
          initialSelection: widget.item.type,
          titles: const ["Word", "Number", "True/False"],
          selections: const ["S", "I", "B"],
          onSelection: (value) {
            switch (value) {
              case "S":
                setState(() {
                  widget.item.setType(value);
                  widget.item.setStringVal("");
                });
                break;
              case "I":
                setState(() {
                  widget.item.setType(value);
                  widget.item.setIntVal(0);
                });
                break;
              default:
                setState(
                  () {
                    widget.item.setType(value);
                    widget.item.setBoolVal(false);
                  },
                );
            }
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
          initialvalue: widget.item.defaultValue,
          labelText: "Default Value",
          charLimit: 25,
          showCharacters: true,
          onChanged: (value) {
            widget.item.setStringVal(value);
          },
          validator: (value) {},
        );
      case "I":
        return cv.LabeledWidget(
          "Default Value",
          child: Row(
            children: [
              SizedBox(
                width: 50,
                child: Center(
                  child: Text(
                    widget.item.defaultValue,
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
          "Default Value",
          child: FlutterSwitch(
            value: widget.item.defaultValue == "true" ? true : false,
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

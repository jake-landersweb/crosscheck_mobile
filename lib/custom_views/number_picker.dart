import 'package:flutter/material.dart';
import 'root.dart' as cv;

/// ```dart
/// this.initialValue = 0,
/// required this.onMinusClick,
/// required this.onPlusClick,
/// this.minValue = 0,
/// this.maxValue = 50,
/// this.plusBackgroundColor = Colors.blue,
/// this.minusBackgroundColor = Colors.grey,
/// this.plusIconColor = Colors.white,
/// this.minusIconColor = Colors.black,
/// this.cornerRadius = 10,
/// this.valueBoxSize = 30,
/// this.textStyle,
/// this.padding = const EdgeInsets.fromLTRB(15, 5, 15, 5),
/// this.plusIconSize = 20,
/// this.minusIconSize = 20,
/// ```
class NumberPicker extends StatefulWidget {
  NumberPicker({
    this.initialValue = 0,
    required this.onMinusClick,
    required this.onPlusClick,
    this.minValue = 0,
    this.maxValue = 50,
    this.plusBackgroundColor = Colors.blue,
    this.minusBackgroundColor = Colors.grey,
    this.plusIconColor = Colors.white,
    this.minusIconColor = Colors.black,
    this.cornerRadius = 10,
    this.valueBoxSize = 30,
    this.textStyle,
    this.padding = const EdgeInsets.fromLTRB(15, 5, 15, 5),
    this.plusIconSize = 20,
    this.minusIconSize = 20,
  });

  final int initialValue;
  final Function(int) onMinusClick;
  final Function(int) onPlusClick;
  final int minValue;
  final int maxValue;
  final Color plusBackgroundColor;
  final Color minusBackgroundColor;
  final Color plusIconColor;
  final Color minusIconColor;
  final double cornerRadius;
  final double valueBoxSize;
  final TextStyle? textStyle;
  final EdgeInsets padding;
  final double plusIconSize;
  final double minusIconSize;

  @override
  _NumberPickerState createState() => _NumberPickerState();
}

class _NumberPickerState extends State<NumberPicker> {
  int _value = 0;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        cv.BasicButton(
          child: Container(
            decoration: BoxDecoration(
              color: widget.minusBackgroundColor,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(widget.cornerRadius),
                  bottomLeft: Radius.circular(widget.cornerRadius)),
            ),
            child: Padding(
              padding: widget.padding,
              child: Icon(
                Icons.remove,
                color: widget.minusIconColor,
                size: widget.minusIconSize,
              ),
            ),
          ),
          onTap: () {
            if (_value > widget.minValue) {
              setState(() {
                _value -= 1;
              });
              widget.onMinusClick(_value);
            }
          },
        ),
        // SizedBox(
        //   width: widget.valueBoxSize,
        //   child: Center(child: Text('$_value', style: widget.textStyle)),
        // ),
        cv.BasicButton(
          child: Container(
            decoration: BoxDecoration(
              color: widget.plusBackgroundColor,
              borderRadius: BorderRadius.only(
                  topRight: Radius.circular(widget.cornerRadius),
                  bottomRight: Radius.circular(widget.cornerRadius)),
            ),
            child: Padding(
              padding: widget.padding,
              child: Icon(
                Icons.add,
                color: widget.plusIconColor,
                size: widget.plusIconSize,
              ),
            ),
          ),
          onTap: () {
            if (_value < widget.maxValue) {
              setState(() {
                _value += 1;
              });
              widget.onPlusClick(_value);
            }
          },
        ),
      ],
    );
  }
}

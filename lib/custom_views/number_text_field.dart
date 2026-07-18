import 'package:crosscheck_sports/extras/root.dart';
import 'package:flutter/material.dart';
import 'number_picker.dart' as cv;
import 'package:crosscheck_sports/components/layer/field.dart';

class NumberTextField extends StatefulWidget {
  const NumberTextField({
    super.key,
    required this.label,
    this.initValue = 0,
    required this.onChange,
    this.color = Colors.blue,
  });

  final String label;
  final int initValue;
  final Function(int) onChange;
  final Color color;

  @override
  _NumberTextFieldState createState() => _NumberTextFieldState();
}

class _NumberTextFieldState extends State<NumberTextField> {
  late TextEditingController _controller;

  @override
  void initState() {
    _controller = TextEditingController(text: widget.initValue.toString());
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 75,
          child: XCField(
            labelText: "Score",
            controller: _controller,
            isLabeled: false,
            onChanged: (val) {
              var v = int.tryParse(val) ?? 0;
              widget.onChange(v);
            },
          ),
        ),
        cv.NumberPicker(
          cornerRadius: 5,
          minValue: -1000,
          maxValue: 1000,
          plusBackgroundColor: widget.color,
          minusBackgroundColor:
              CustomColors.textColor(context).withOpacity(0.1),
          initialValue: int.tryParse(_controller.text) ?? 0,
          onPlusClick: (val) {
            var v = int.tryParse(_controller.text) ?? 0;
            v += 1;
            setState(() {
              _controller.text = v.toString();
            });
            widget.onChange(v);
          },
          onMinusClick: (val) {
            var v = int.tryParse(_controller.text) ?? 0;
            if (v > 0) {
              v -= 1;
            }
            setState(() {
              _controller.text = v.toString();
            });
            widget.onChange(v);
          },
        ),
        Expanded(
          child: Align(
            alignment: AlignmentDirectional.centerEnd,
            child: Text(
              widget.label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).brightness == Brightness.light
                    ? Colors.black.withOpacity(0.5)
                    : Colors.white.withOpacity(0.5),
              ),
            ),
          ),
        )
      ],
    );
  }
}

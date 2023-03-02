import 'package:crosscheck_sports/extras/root.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'text_field.dart' as cv;
import 'core/basic_button.dart' as cv;

enum TimePickerMode { text, spinner }

class TimePicker extends StatefulWidget {
  const TimePicker({
    super.key,
    required this.onSelection,
    required this.onCancel,
    this.initialDate,
    this.hourStyle,
    this.accentColor = Colors.blue,
    this.timePickerMode = TimePickerMode.text,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
  });
  final Function(DateTime date) onSelection;
  final VoidCallback onCancel;
  final DateTime? initialDate;
  final TextStyle? hourStyle;
  final Color accentColor;
  final TimePickerMode timePickerMode;
  final EdgeInsets padding;

  @override
  State<TimePicker> createState() => _TimePickerState();
}

class _TimePickerState extends State<TimePicker> {
  late DateTime d;
  late TextEditingController _hourController;
  late TextEditingController _minController;
  late int _hour;
  late int _min;
  late bool _isAm;

  @override
  void initState() {
    d = widget.initialDate ?? DateTime.now();
    _min = d.minute;

    // set am/pm
    if (d.hour > 11) {
      _isAm = false;
      if (d.hour > 12) {
        _hour = d.hour - 12;
      } else {
        _hour = d.hour;
      }
    } else {
      _isAm = true;
      _hour = d.hour;
    }
    if (d.hour == 0) {
      _hour = 12;
    }

    // make sure there is always a padding '0'
    String hr = _hour.toString();
    String mn = _min.toString();
    if (_hour < 10) {
      hr = hr.padLeft(2, "0");
    }
    if (_min < 10) {
      mn = mn.padLeft(2, "0");
    }

    // set controllers with init value
    _hourController = TextEditingController(text: hr);
    _minController = TextEditingController(text: mn);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.timePickerMode) {
      case TimePickerMode.text:
        return _textPicker(context);
      case TimePickerMode.spinner:
        return _spinnerPicker(context);
    }
  }

  Widget _spinnerPicker(BuildContext context) {
    return Container();
  }

  Widget _textPicker(BuildContext context) {
    return Padding(
      padding: widget.padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IntrinsicHeight(
            child: Row(
              children: [
                // hour
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: widget.accentColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: cv.TextField2(
                            key: const ValueKey("Hour"),
                            controller: _hourController,
                            labelText: "",
                            showBackground: false,
                            fieldPadding: EdgeInsets.zero,
                            textAlign: TextAlign.center,
                            isLabeled: false,
                            keyboardType: TextInputType.number,
                            charLimit: 2,
                            highlightColor: widget.accentColor,
                            formatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              _HourTextInputFormatter(),
                            ],
                            style: TextStyle(
                              fontSize: _fontSize,
                              color:
                                  MediaQuery.of(context).platformBrightness ==
                                          Brightness.light
                                      ? widget.accentColor
                                      : widget.accentColor.lighten(0.15),
                              fontWeight: _fontWeight,
                            ),
                            onChanged: (val) {
                              if (val != "") {
                                int? tmp = int.tryParse(val);
                                if (tmp != null) {
                                  setState(() {
                                    _hour = tmp;
                                  });
                                }
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    ":",
                    style: TextStyle(
                      fontSize: _fontSize,
                      color: CustomColors.textColor(context).withOpacity(0.3),
                      fontWeight: _fontWeight,
                    ),
                  ),
                ),
                // minute
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: CustomColors.textColor(context).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: cv.TextField2(
                            key: const ValueKey("Min"),
                            controller: _minController,
                            labelText: "",
                            showBackground: false,
                            fieldPadding: EdgeInsets.zero,
                            textAlign: TextAlign.center,
                            isLabeled: false,
                            keyboardType: TextInputType.number,
                            charLimit: 2,
                            highlightColor: widget.accentColor,
                            formatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              _MinuteTextInputFormatter(),
                            ],
                            style: TextStyle(
                              fontSize: _fontSize,
                              color:
                                  MediaQuery.of(context).platformBrightness ==
                                          Brightness.light
                                      ? CustomColors.textColor(context)
                                          .withOpacity(0.5)
                                      : CustomColors.textColor(context),
                              fontWeight: _fontWeight,
                            ),
                            onChanged: (val) {
                              if (val != "") {
                                int? tmp = int.tryParse(val);
                                if (tmp != null) {
                                  setState(() {
                                    _min = tmp;
                                  });
                                }
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // am/pm
                SizedBox(
                  width: 60,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Column(
                        children: [
                          _ampmCell(context, getAmColor(), getAmAccent(), true),
                          _ampmCell(
                              context, getPmColor(), getPmAccent(), false),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              const Spacer(),
              cv.BasicButton(
                onTap: () => widget.onCancel(),
                child: Text(
                  "Cancel",
                  style: TextStyle(
                    color: widget.accentColor.withOpacity(0.75),
                    fontWeight: FontWeight.w500,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 32),
              cv.BasicButton(
                onTap: () {
                  var h = _hour;
                  if (h == 12) {
                    h = 0;
                  }
                  var tmp = DateTime(
                      d.year, d.month, d.day, _isAm ? h : h + 12, _min, 0);
                  widget.onSelection(tmp);
                },
                child: Text(
                  "OK",
                  style: TextStyle(
                    color: widget.accentColor.withOpacity(0.75),
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Color getAmColor() {
    if (_isAm) {
      return MediaQuery.of(context).platformBrightness == Brightness.light
          ? widget.accentColor
          : widget.accentColor.lighten(0.15);
    } else {
      return CustomColors.textColor(context).withOpacity(0.5);
    }
  }

  Color getAmAccent() {
    if (_isAm) {
      return widget.accentColor.withOpacity(0.3);
    } else {
      return CustomColors.textColor(context).withOpacity(0.1);
    }
  }

  Color getPmColor() {
    if (!_isAm) {
      return MediaQuery.of(context).platformBrightness == Brightness.light
          ? widget.accentColor
          : widget.accentColor.lighten(0.15);
    } else {
      return CustomColors.textColor(context).withOpacity(0.5);
    }
  }

  Color getPmAccent() {
    if (!_isAm) {
      return widget.accentColor.withOpacity(0.3);
    } else {
      return CustomColors.textColor(context).withOpacity(0.1);
    }
  }

  Widget _ampmCell(
      BuildContext context, Color textColor, Color backgroundColor, bool isAm) {
    return Expanded(
      child: cv.BasicButton(
        onTap: () {
          setState(() {
            _isAm = isAm;
          });
        },
        child: Container(
          color: backgroundColor,
          width: double.infinity,
          child: Center(
            child: Text(
              isAm ? "AM" : "PM",
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
          ),
        ),
      ),
    );
  }

  static const double _fontSize = 60;
  static const FontWeight _fontWeight = FontWeight.w600;
}

class _HourTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    TextSelection newSelection = newValue.selection;
    String value = newValue.text;

    int? tmp = int.tryParse(value);

    if (tmp == null) {
      return oldValue;
    }

    if (tmp > 12) {
      tmp = 12;
    }

    String newText = tmp.toString();

    if (tmp < 10) {
      newText = newText.padLeft(2, '0');
    }

    newSelection = newValue.selection.copyWith(
      baseOffset: math.min(newText.length, newText.length),
      extentOffset: math.min(newText.length, newText.length),
    );

    return TextEditingValue(
      text: newText,
      selection: newSelection,
      composing: TextRange.empty,
    );
  }
}

class _MinuteTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    TextSelection newSelection = newValue.selection;
    String value = newValue.text;

    int? tmp = int.tryParse(value);

    if (tmp == null) {
      return oldValue;
    }

    if (tmp > 59) {
      tmp = 59;
    }

    String newText = tmp.toString();

    if (tmp < 10) {
      newText = newText.padLeft(2, '0');
    }

    newSelection = newValue.selection.copyWith(
      baseOffset: math.min(newText.length, newText.length),
      extentOffset: math.min(newText.length, newText.length),
    );

    return TextEditingValue(
      text: newText,
      selection: newSelection,
      composing: TextRange.empty,
    );
  }
}

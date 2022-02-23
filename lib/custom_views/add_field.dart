import 'package:flutter/material.dart';
import 'package:pnflutter/extras/root.dart';
import 'text_field.dart' as cv;
import 'core/basic_button.dart' as cv;

/// ```dart
/// Key? key,
/// required this.labelText,
/// this.buttonText = "Add",
/// this.onChange,
/// required this.onCommit,
/// this.cellColor,
/// this.iconColor = Colors.blue,
/// this.icon = Icons.add,
/// this.textColor,
/// this.clearTextOnAction = true,
/// this.borderRadius = 10,
/// this.validator,
/// ```
class AddField extends StatefulWidget {
  const AddField({
    Key? key,
    required this.labelText,
    this.buttonText = "Add",
    this.onChange,
    required this.onCommit,
    this.cellColor,
    this.iconColor = Colors.blue,
    this.icon = Icons.add,
    this.textColor,
    this.clearTextOnAction = true,
    this.borderRadius = 25,
    this.validator,
  }) : super(key: key);
  final String labelText;
  final String buttonText;
  final Function(String)? onChange;
  final Function(String) onCommit;
  final Color? cellColor;
  final Color? textColor;
  final Color iconColor;
  final IconData icon;
  final bool clearTextOnAction;
  final double borderRadius;
  final bool Function(String)? validator;

  @override
  _AddFieldState createState() => _AddFieldState();
}

class _AddFieldState extends State<AddField> {
  late TextEditingController _controller;

  @override
  void initState() {
    _controller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      child: Container(
        color: widget.cellColor ?? CustomColors.cellColor(context),
        child: IntrinsicHeight(
          child: Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: cv.TextField(
                    labelText: widget.labelText,
                    controller: _controller,
                    showBackground: false,
                    onChanged: (value) {
                      if (widget.onChange != null) {
                        widget.onChange!(value);
                      }
                    },
                    validator: (value) => null,
                  ),
                ),
                cv.BasicButton(
                  onTap: () {
                    if (widget.validator != null) {
                      if (widget.validator!(_controller.text)) {
                        widget.onCommit(_controller.text);
                        _controller.text = "";
                      }
                    } else {
                      if (_controller.text != "") {
                        widget.onCommit(_controller.text);
                        _controller.text = "";
                      }
                    }
                  },
                  child: SizedBox(
                    width: 50,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(widget.icon, color: widget.iconColor),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

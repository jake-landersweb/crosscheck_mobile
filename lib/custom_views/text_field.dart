import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/cupertino.dart';

import 'core/root.dart';

///
/// Creates a text field with custom styling that is follows
/// simple material design guidlines for android. On iOS and macOS,
/// a TextField from SwiftUI embeded into a List design priciples are
/// followed. Best to use on a black background in darkmode, or a purple tinted
/// background in light mode.
/// All of the highlight coloring is handled by [highlightColor].
class TextField extends StatefulWidget {
  final String labelText;
  final void Function(String) onChanged;
  final String? Function(String?)? validator;
  final Icon? icon;
  final bool obscureText;
  final Color highlightColor;
  final bool showCharacters;
  final int charLimit;
  final String initialvalue;
  final TextStyle? style;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final bool showBackground;

  TextField({
    Key? key,
    required this.labelText,
    required this.onChanged,
    required this.validator,
    this.icon,
    this.obscureText = false,
    this.highlightColor = Colors.blue,
    this.showCharacters = false,
    this.charLimit = 100,
    this.initialvalue = '',
    this.style,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.sentences,
    this.showBackground = true,
  })  : assert(
          validator != null,
        ),
        super(key: key);
  @override
  _TextFieldState createState() => _TextFieldState();
}

class _TextFieldState extends State<TextField> {
  String _inputText = '';

  @override
  void initState() {
    super.initState();
    _inputText = widget.initialvalue;
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      key: widget.key,
      data: Theme.of(context).copyWith(
        primaryColor: widget.highlightColor,
        inputDecorationTheme: InputDecorationTheme(
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              style: BorderStyle.solid,
              color: _underlineColor(),
            ),
          ),
        ),
      ),
      child: Stack(
        alignment: AlignmentDirectional.topEnd,
        children: [
          if (kIsWeb)
            _materialTextField(context)
          else if (Platform.isIOS || Platform.isMacOS)
            if (widget.showBackground)
              Material(
                color: ViewColors.cellColor(context),
                shape: ContinuousRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                child: _cupertinoTextField(context),
              )
            else
              _cupertinoTextField(context)
          else
            _materialTextField(context),
          if (widget.showCharacters)
            Text(
              '${_inputText.length} / ${widget.charLimit}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
        ],
      ),
    );
  }

  Widget _materialTextField(BuildContext context) {
    return TextFormField(
      autocorrect: false,
      textCapitalization: widget.textCapitalization,
      keyboardType: widget.keyboardType,
      keyboardAppearance: MediaQuery.of(context).platformBrightness,
      initialValue: widget.initialvalue,
      cursorColor: widget.highlightColor,
      obscureText: widget.obscureText,
      style: widget.style ??
          TextStyle(
            color: MediaQuery.of(context).platformBrightness == Brightness.light
                ? Colors.black
                : Colors.white,
          ),
      decoration: InputDecoration(
        hintText: widget.labelText,
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
              color:
                  MediaQuery.of(context).platformBrightness == Brightness.light
                      ? Colors.black.withOpacity(0.5)
                      : Colors.white.withOpacity(0.5)),
        ),
        icon: widget.icon,
        hintStyle: TextStyle(
            color: MediaQuery.of(context).platformBrightness == Brightness.light
                ? Colors.black.withOpacity(0.5)
                : Colors.white.withOpacity(0.5)),
      ),
      onChanged: (value) {
        if (widget.showCharacters) {
          setState(() {
            _inputText = value;
          });
        }
        widget.onChanged(value);
      },
      validator: widget.validator,
    );
  }

  Widget _cupertinoTextField(BuildContext context) {
    return TextFormField(
      autocorrect: false,
      textCapitalization: widget.textCapitalization,
      keyboardType: widget.keyboardType,
      keyboardAppearance: MediaQuery.of(context).platformBrightness,
      initialValue: widget.initialvalue,
      cursorColor: widget.highlightColor,
      obscureText: widget.obscureText,
      style: widget.style ??
          TextStyle(
            color: MediaQuery.of(context).platformBrightness == Brightness.light
                ? Colors.black
                : Colors.white,
          ),
      decoration: InputDecoration(
        hintText: widget.labelText,
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.transparent),
        ),
        icon: widget.icon,
        hintStyle: TextStyle(
            color: MediaQuery.of(context).platformBrightness == Brightness.light
                ? Colors.black.withOpacity(0.5)
                : Colors.white.withOpacity(0.5)),
      ),
      onChanged: (value) {
        if (widget.showCharacters) {
          setState(() {
            _inputText = value;
          });
        }
        widget.onChanged(value);
      },
      validator: widget.validator,
    );
  }

  // no underline if on apple platform
  Color _underlineColor() {
    if (kIsWeb) {
      return widget.highlightColor;
    } else if (Platform.isIOS || Platform.isMacOS) {
      return Colors.transparent;
    } else {
      return widget.highlightColor;
    }
  }
}

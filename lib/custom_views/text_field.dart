import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import 'core/root.dart';

enum TextFieldType { string, integer }

/// ```dart
/// Key? key,
/// required this.label,
/// this.onChanged,
/// this.validator,
/// this.controller,
/// this.icon,
/// this.obscureText = false,
/// this.formatters = const [],
/// this.initialValue = "",
/// this.keyboardType,
/// this.type = TextFieldType.string,
/// this.color = Colors.blue,
/// this.style,
/// this.textCapitalization = TextCapitalization.sentences,
/// this.fieldPadding = const EdgeInsets.only(left: 16),
/// ```
class TextField extends StatefulWidget {
  const TextField({
    Key? key,
    required this.label,
    this.onChanged,
    this.validator,
    this.controller,
    this.icon,
    this.obscureText = false,
    this.formatters = const [],
    this.initialValue = "",
    this.keyboardType,
    this.type = TextFieldType.string,
    this.color = Colors.blue,
    this.style,
    this.textCapitalization = TextCapitalization.sentences,
    this.fieldPadding = const EdgeInsets.only(left: 16),
  }) : super(key: key);
  final String label;
  final Function(String)? onChanged;
  final String? Function(String?)? validator;
  final TextEditingController? controller;
  final IconData? icon;
  final bool obscureText;
  final List<TextInputFormatter> formatters;
  final String initialValue;
  final TextInputType? keyboardType;
  final TextFieldType type;
  final Color color;
  final TextStyle? style;
  final TextCapitalization textCapitalization;
  final EdgeInsets fieldPadding;

  @override
  _TextFieldState createState() => _TextFieldState();
}

class _TextFieldState extends State<TextField> {
  TextEditingController? _controller;

  @override
  void initState() {
    if (widget.controller == null) {
      _controller = TextEditingController(text: widget.initialValue);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      key: widget.key,
      data: Theme.of(context).copyWith(
        primaryColor: widget.color,
        inputDecorationTheme: const InputDecorationTheme(
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              style: BorderStyle.none,
            ),
          ),
        ),
      ),
      child: TextFormField(
        autocorrect: false,
        controller: widget.controller ?? _controller,
        inputFormatters: widget.formatters +
            [
              if (widget.type == TextFieldType.integer)
                FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))
            ],
        textCapitalization: widget.textCapitalization,
        keyboardType: widget.keyboardType,
        keyboardAppearance: MediaQuery.of(context).platformBrightness,
        cursorColor: widget.color,
        obscureText: widget.obscureText,
        style: widget.style ??
            TextStyle(
              color:
                  MediaQuery.of(context).platformBrightness == Brightness.light
                      ? Colors.black
                      : Colors.white,
            ),
        decoration: InputDecoration(
          counterStyle: const TextStyle(
            height: double.minPositive,
          ),
          counterText: "",
          hintText: widget.label,
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.transparent),
          ),
          contentPadding: widget.fieldPadding,
          icon: widget.icon == null ? null : Icon(widget.icon),
          hintStyle: TextStyle(
              color:
                  MediaQuery.of(context).platformBrightness == Brightness.light
                      ? Colors.black.withOpacity(0.5)
                      : Colors.white.withOpacity(0.5)),
        ),
        onChanged: (value) {
          if (widget.onChanged != null) {
            widget.onChanged!(value);
          }
        },
        validator: widget.validator,
      ),
    );
  }
}

///
/// Creates a text field with custom styling that is follows
/// simple material design guidlines for android. On iOS and macOS,
/// a TextField from SwiftUI embeded into a List design priciples are
/// followed. Best to use on a black background in darkmode, or a purple tinted
/// background in light mode.
/// All of the highlight coloring is handled by [highlightColor].
class TextField2 extends StatefulWidget {
  final String labelText;
  final void Function(String) onChanged;
  final String? Function(String?)? validator;
  final Icon? icon;
  final bool obscureText;
  final Color highlightColor;
  final bool showCharacters;
  final int charLimit;
  String? value;
  final TextStyle? style;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final bool showBackground;
  final bool isLabeled;
  final EdgeInsets fieldPadding;
  final TextEditingController? controller;
  final List<TextInputFormatter> formatters;

  TextField2({
    Key? key,
    required this.labelText,
    required this.onChanged,
    required this.validator,
    this.icon,
    this.obscureText = false,
    this.highlightColor = Colors.blue,
    this.showCharacters = false,
    this.charLimit = 100,
    this.value,
    this.style,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.sentences,
    this.showBackground = true,
    this.isLabeled = false,
    this.fieldPadding = const EdgeInsets.only(left: 16),
    this.formatters = const [],
    this.controller,
  })  : assert(
          validator != null,
        ),
        super(key: key);
  @override
  _TextField2State createState() => _TextField2State();
}

class _TextField2State extends State<TextField2> {
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
            _getLabeledMaterial(context)
          else if (Platform.isIOS || Platform.isMacOS)
            if (widget.showBackground)
              Material(
                color: ViewColors.cellColor(context),
                shape: ContinuousRectangleBorder(
                    borderRadius: BorderRadius.circular(35)),
                child: Padding(
                  padding: widget.fieldPadding,
                  child: _getLabeledCupertino(context),
                ),
              )
            else
              _getLabeledCupertino(context)
          else
            _getLabeledMaterial(context),
          if (widget.showCharacters)
            Text(
              '${widget.value?.length} / ${widget.charLimit}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
        ],
      ),
    );
  }

  Widget _getLabeledMaterial(BuildContext context) {
    if (widget.isLabeled) {
      return _labelWrapper(context, _cupertinoTextField(context));
    } else {
      return _cupertinoTextField(context);
    }
  }

  Widget _getLabeledCupertino(BuildContext context) {
    if (widget.isLabeled) {
      return _labelWrapper(context, _cupertinoTextField(context));
    } else {
      return _cupertinoTextField(context);
    }
  }

  Widget _labelWrapper(BuildContext context, Widget child) {
    return Stack(
      alignment: AlignmentDirectional.centerEnd,
      children: [
        child,
        Padding(
          padding: widget.showBackground
              ? EdgeInsets.only(right: widget.fieldPadding.left)
              : const EdgeInsets.all(0),
          child: Text(
            widget.labelText,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).brightness == Brightness.light
                  ? Colors.black.withOpacity(0.5)
                  : Colors.white.withOpacity(0.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _materialTextField(BuildContext context) {
    return TextFormField(
      autocorrect: false,
      controller: widget.controller,
      textCapitalization: widget.textCapitalization,
      keyboardType: widget.keyboardType,
      keyboardAppearance: MediaQuery.of(context).platformBrightness,
      initialValue: widget.value,
      cursorColor: widget.highlightColor,
      obscureText: widget.obscureText,
      maxLength: widget.charLimit,
      style: widget.style ??
          TextStyle(
            color: MediaQuery.of(context).platformBrightness == Brightness.light
                ? Colors.black
                : Colors.white,
          ),
      decoration: InputDecoration(
        counterStyle: const TextStyle(
          height: double.minPositive,
        ),
        counterText: "",
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
            widget.value = value;
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
      controller: widget.controller,
      inputFormatters: widget.formatters,
      textCapitalization: widget.textCapitalization,
      keyboardType: widget.keyboardType,
      keyboardAppearance: MediaQuery.of(context).platformBrightness,
      initialValue: widget.value,
      cursorColor: widget.highlightColor,
      obscureText: widget.obscureText,
      maxLength: widget.charLimit,
      style: widget.style ??
          TextStyle(
            color: MediaQuery.of(context).platformBrightness == Brightness.light
                ? Colors.black
                : Colors.white,
          ),
      decoration: InputDecoration(
        counterStyle: const TextStyle(
          height: double.minPositive,
        ),
        counterText: "",
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
            widget.value = value;
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

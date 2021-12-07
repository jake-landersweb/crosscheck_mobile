import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

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
  final bool isLabeled;
  final EdgeInsets fieldPadding;

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
    this.isLabeled = false,
    this.fieldPadding = const EdgeInsets.only(left: 16),
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
              '${_inputText.length} / ${widget.charLimit}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
        ],
      ),
    );
  }

  Widget _getLabeledMaterial(BuildContext context) {
    if (widget.isLabeled) {
      return _labelWrapper(context, _materialTextField(context));
    } else {
      return _materialTextField(context);
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
      textCapitalization: widget.textCapitalization,
      keyboardType: widget.keyboardType,
      keyboardAppearance: MediaQuery.of(context).platformBrightness,
      initialValue: widget.initialvalue,
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

class DynamicTextField extends StatefulWidget {
  final String labelText;
  final void Function(String) onChanged;
  final Icon? icon;
  final bool obscureText;
  final Color highlightColor;
  final bool showCharacters;
  final int charLimit;
  String value;
  final bool enforceCharLimit;
  final TextStyle? style;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final bool showBackground;
  final bool isLabeled;
  final EdgeInsets fieldPadding;

  DynamicTextField({
    Key? key,
    required this.labelText,
    required this.onChanged,
    required this.value,
    this.enforceCharLimit = false,
    this.icon,
    this.obscureText = false,
    this.highlightColor = Colors.blue,
    this.showCharacters = false,
    this.charLimit = 100,
    this.style,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.sentences,
    this.showBackground = true,
    this.isLabeled = false,
    this.fieldPadding = const EdgeInsets.only(left: 16),
  }) : super(key: key);
  @override
  _DynamicTextFieldState createState() => _DynamicTextFieldState();
}

class _DynamicTextFieldState extends State<DynamicTextField> {
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
              '${widget.value.length} / ${widget.charLimit}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
        ],
      ),
    );
  }

  Widget _getLabeledMaterial(BuildContext context) {
    if (widget.isLabeled) {
      return _labelWrapper(context, _materialTextField(context));
    } else {
      return _materialTextField(context);
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
          if (widget.enforceCharLimit &&
              widget.value.length > widget.charLimit) {
            // do nothing
          } else {
            setState(() {
              widget.onChanged(value);
            });
          }
        }
      },
    );
  }

  Widget _cupertinoTextField(BuildContext context) {
    return TextFormField(
      autocorrect: false,
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
          if (widget.enforceCharLimit &&
              widget.value.length > widget.charLimit) {
            // do nothing
          } else {
            setState(() {
              widget.onChanged(value);
            });
          }
        }
      },
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

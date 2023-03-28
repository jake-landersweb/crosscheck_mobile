import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import 'core/root.dart';

enum TextFieldType { string, integer }

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
  final Icon? icon;
  final bool obscureText;
  final Color? highlightColor;
  final bool showCharacters;
  final int? charLimit;
  final String? value;
  final TextStyle? style;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final bool showBackground;
  final bool isLabeled;
  final EdgeInsets fieldPadding;
  final TextEditingController? controller;
  final List<TextInputFormatter> formatters;
  final int? maxLines;
  final String? hintText;
  final int? minLines;
  final TextInputAction textInputAction;
  final bool autocorrect;
  final Color? backgroundColor;
  final TextAlign textAlign;
  final bool enabled;
  final double labelEdgePadding;

  const TextField2({
    Key? key,
    required this.labelText,
    required this.onChanged,
    this.icon,
    this.obscureText = false,
    this.highlightColor,
    this.showCharacters = false,
    this.charLimit,
    this.value,
    this.style,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.sentences,
    this.showBackground = true,
    this.isLabeled = true,
    this.fieldPadding = const EdgeInsets.only(left: 16),
    this.formatters = const [],
    this.controller,
    this.maxLines,
    this.hintText,
    this.minLines,
    this.textInputAction = TextInputAction.done,
    this.autocorrect = false,
    this.backgroundColor,
    this.textAlign = TextAlign.start,
    this.enabled = true,
    this.labelEdgePadding = 0,
  }) : super(key: key);
  @override
  _TextField2State createState() => _TextField2State();
}

class _TextField2State extends State<TextField2> {
  TextEditingController? _controller;

  @override
  void initState() {
    if (widget.controller == null) {
      _controller = TextEditingController(text: widget.value);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: widget.enabled ? 1 : 0.5,
      child: Theme(
        key: widget.key,
        data: Theme.of(context).copyWith(
          primaryColor: widget.highlightColor,
          colorScheme: Theme.of(context)
              .colorScheme
              .copyWith(primary: widget.highlightColor),
          inputDecorationTheme: const InputDecorationTheme(
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                style: BorderStyle.solid,
                color: Colors.transparent,
              ),
            ),
          ),
        ),
        child: Stack(
          alignment: AlignmentDirectional.topEnd,
          children: [
            if (widget.showBackground)
              Container(
                decoration: BoxDecoration(
                  color:
                      widget.backgroundColor ?? ViewColors.cellColor(context),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: widget.fieldPadding,
                  child: _getLabeledCupertino(context),
                ),
              )
            else
              _getLabeledCupertino(context),
            if (widget.showCharacters)
              Text(
                '${widget.controller == null ? _controller!.text.length : widget.controller!.text.length} / ${widget.charLimit}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
          ],
        ),
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
    return Row(
      children: [
        Expanded(child: child),
        // show label when text is empty
        if (widget.controller == null
            ? _controller!.text.isNotEmpty
            : widget.controller!.text.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(right: widget.labelEdgePadding),
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

  Widget _cupertinoTextField(BuildContext context) {
    return TextFormField(
      autocorrect: widget.autocorrect,
      textInputAction: widget.textInputAction,
      controller: widget.controller ?? _controller!,
      enabled: widget.enabled,
      maxLines: widget.obscureText ? 1 : (widget.maxLines ?? 1),
      inputFormatters: widget.formatters,
      textCapitalization: widget.textCapitalization,
      keyboardType: widget.keyboardType,
      keyboardAppearance: Theme.of(context).brightness,
      cursorColor: widget.highlightColor,
      obscureText: widget.obscureText,
      maxLength: widget.charLimit,
      minLines: widget.minLines ?? 1,
      textAlign: widget.textAlign,
      style: widget.style ??
          TextStyle(
            color: Theme.of(context).brightness == Brightness.light
                ? Colors.black
                : Colors.white,
          ),
      decoration: InputDecoration(
        counterStyle: const TextStyle(
          height: double.minPositive,
        ),
        counterText: "",
        hintText: widget.hintText ?? widget.labelText,
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.transparent),
        ),
        icon: widget.icon,
        hintStyle: TextStyle(
          color: Theme.of(context).brightness == Brightness.light
              ? Colors.black.withOpacity(0.5)
              : Colors.white.withOpacity(0.5),
        ),
      ),
      onChanged: (value) {
        widget.onChanged(value);
        // update internal state incase not used elsewhere
        setState(() {});
      },
    );
  }
}

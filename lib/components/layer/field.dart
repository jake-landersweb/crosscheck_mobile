import 'package:crosscheck_sports/style/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A text field component with optional label display and clear button.
/// Renders without underline borders for a clean appearance.
class XCField extends StatefulWidget {
  final String? labelText;
  final void Function(String)? onChanged;
  final Icon? icon;
  final bool obscureText;
  final bool showCharacters;
  final int? charLimit;
  final String? value;
  final TextStyle? style;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final bool isLabeled;
  final TextEditingController? controller;
  final List<TextInputFormatter> formatters;
  final int? maxLines;
  final String? hintText;
  final int? minLines;
  final TextInputAction textInputAction;
  final bool autocorrect;
  final TextAlign textAlign;
  final bool hasClearButton;
  final FocusNode? focusNode;
  final bool dense;

  const XCField({
    super.key,
    this.labelText,
    this.onChanged,
    this.icon,
    this.obscureText = false,
    this.showCharacters = false,
    this.charLimit,
    this.value,
    this.style,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.sentences,
    this.isLabeled = true,
    this.formatters = const [],
    this.controller,
    this.maxLines,
    this.hintText,
    this.minLines,
    this.textInputAction = TextInputAction.done,
    this.autocorrect = false,
    this.textAlign = TextAlign.start,
    this.hasClearButton = false,
    this.focusNode,
    this.dense = false,
  });

  @override
  State<XCField> createState() => _XCFieldState();
}

class _XCFieldState extends State<XCField> {
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
    return Stack(
      alignment: AlignmentDirectional.topEnd,
      children: [
        _getLabeledWidget(context),
        if (widget.showCharacters)
          Text(
            '${widget.controller == null ? _controller!.text.length : widget.controller!.text.length} / ${widget.charLimit}',
            style: XCTheme.of(
              context,
            ).text.caption.copyWith(color: XCTheme.of(context).foregroundMuted),
          ),
      ],
    );
  }

  Widget _getLabeledWidget(BuildContext context) {
    if (widget.isLabeled) {
      return _labelWrapper(context, _buildTextField(context));
    } else {
      return _buildTextField(context);
    }
  }

  Widget _labelWrapper(BuildContext context, Widget child) {
    final hasText = widget.controller == null
        ? _controller!.text.isNotEmpty
        : widget.controller!.text.isNotEmpty;

    return Row(
      children: [
        Expanded(child: child),
        if (hasText && widget.labelText != null)
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Text(
              widget.labelText!,
              style: XCTheme.of(context).text.small.copyWith(
                fontWeight: FontWeight.w500,
                color: XCTheme.of(context).foregroundMuted,
              ),
            ),
          ),
        if (hasText && widget.hasClearButton)
          GestureDetector(
            onTap: () {
              if (widget.controller == null) {
                setState(() {
                  _controller!.text = "";
                });
              } else {
                setState(() {
                  widget.controller!.text = "";
                });
              }
              widget.onChanged?.call("");
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Icon(
                Icons.cancel,
                color: Theme.of(context).brightness == Brightness.light
                    ? Colors.black.withValues(alpha: 0.3)
                    : Colors.white.withValues(alpha: 0.3),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTextField(BuildContext context) {
    return TextFormField(
      autocorrect: widget.autocorrect,
      textInputAction: widget.textInputAction,
      controller: widget.controller ?? _controller!,
      focusNode: widget.focusNode,
      maxLines: widget.obscureText ? 1 : (widget.maxLines ?? 1),
      inputFormatters: widget.formatters,
      textCapitalization: widget.textCapitalization,
      keyboardType: widget.keyboardType,
      keyboardAppearance: Theme.of(context).brightness,
      obscureText: widget.obscureText,
      maxLength: widget.charLimit,
      minLines: widget.minLines ?? 1,
      textAlign: widget.textAlign,
      style:
          widget.style ??
          TextStyle(
            color: Theme.of(context).brightness == Brightness.light
                ? Colors.black
                : Colors.white,
          ),
      decoration: InputDecoration(
        isCollapsed: widget.dense,
        isDense: widget.dense,
        contentPadding: widget.dense ? EdgeInsets.zero : null,
        counterStyle: const TextStyle(height: double.minPositive),
        counterText: "",
        hintText: widget.hintText ?? widget.labelText ?? '',
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.transparent),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.transparent),
        ),
        icon: widget.icon,
        hintStyle: TextStyle(
          color: Theme.of(context).brightness == Brightness.light
              ? Colors.black.withValues(alpha: 0.5)
              : Colors.white.withValues(alpha: 0.5),
        ),
      ),
      onChanged: (value) {
        widget.onChanged?.call(value);
        setState(() {});
      },
    );
  }
}

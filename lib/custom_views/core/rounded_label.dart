import 'package:flutter/material.dart';
import 'package:pnflutter/custom_views/core/basic_button.dart';
import 'loading_indicator.dart';

/// For Creating Rounded Labels
class RoundedLabel extends StatefulWidget {
  const RoundedLabel(
    this.label, {
    Key? key,
    this.color,
    this.textColor,
    this.onTap,
    this.height = 50,
    this.isNavigator = false,
    this.child,
    this.fontSize = 16,
    this.fontWeight = FontWeight.w500,
    this.width = double.infinity,
    this.isLoading,
  }) : super(key: key);

  final String label;
  final Color? color;
  final Color? textColor;
  final VoidCallback? onTap;
  final double height;
  final bool isNavigator;
  final Widget? child;
  final double fontSize;
  final FontWeight fontWeight;
  final double width;
  final bool? isLoading;

  @override
  _RoundedLabelState createState() => _RoundedLabelState();
}

class _RoundedLabelState extends State<RoundedLabel> {
  @override
  Widget build(BuildContext context) {
    if (widget.onTap == null) {
      return _body(context);
    } else {
      return BasicButton(onTap: widget.onTap, child: _body(context));
    }
  }

  Widget _body(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.height / 2),
        color: widget.color,
      ),
      width: widget.width,
      height: widget.height,
      child: Center(
        child: _title(context),
      ),
    );
  }

  Widget _title(BuildContext context) {
    if (widget.isNavigator) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 8, 0),
        child: Row(
          children: [
            widget.child == null ? _loadingTitle(context) : widget.child!,
            const Spacer(),
            Icon(Icons.chevron_right, color: widget.textColor),
          ],
        ),
      );
    } else {
      return widget.child == null ? _loadingTitle(context) : widget.child!;
    }
  }

  Widget _loadingTitle(BuildContext context) {
    if (widget.isLoading != null) {
      if (widget.isLoading!) {
        return LoadingIndicator(color: widget.textColor);
      } else {
        return Text(
          widget.label,
          style: TextStyle(
            fontSize: widget.fontSize,
            fontWeight: widget.fontWeight,
            color: widget.textColor,
          ),
        );
      }
    } else {
      return Text(
        widget.label,
        style: TextStyle(
          fontSize: widget.fontSize,
          fontWeight: widget.fontWeight,
          color: widget.textColor,
        ),
      );
    }
  }
}

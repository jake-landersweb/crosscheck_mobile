import 'package:crosscheck_sports/client/root.dart';
import 'package:crosscheck_sports/components/core/clickable.dart';
import 'package:crosscheck_sports/data/indicator_item.dart';
import 'package:crosscheck_sports/style/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

/// A value row with a trailing muted label, in the new UI style.
///
/// Replaces the legacy `cv.LabeledCell` from `custom_views/labeled_cell.dart`.
/// When [clickable] is true, tapping the value copies it to the clipboard
/// (or invokes [onValueClick] when provided).
class XCLabeledCell extends StatelessWidget {
  const XCLabeledCell({
    super.key,
    required this.label,
    required this.value,
    this.height = 50,
    this.textColor,
    this.clickable = false,
    this.onValueClick,
  });

  final String label;
  final String value;
  final double height;
  final Color? textColor;
  final bool clickable;
  final Function(String)? onValueClick;

  @override
  Widget build(BuildContext context) {
    final dmodel = Provider.of<DataModel>(context);
    return Row(
      children: [
        if (clickable)
          Expanded(
            child: Clickable(
              onTap: () {
                if (onValueClick != null) {
                  onValueClick!(value);
                } else {
                  Clipboard.setData(ClipboardData(text: value));
                  dmodel.addIndicator(
                    IndicatorItem.success("Successfully copied to clipboard."),
                  );
                }
              },
              child: Row(children: [_value(context)]),
            ),
          )
        else
          _value(context),
        SizedBox(height: height),
        Text(
          label,
          style: XCTheme.of(context).text.small.copyWith(
                fontWeight: FontWeight.w500,
                color: XCTheme.of(context).foregroundMuted,
              ),
        ),
      ],
    );
  }

  Widget _value(BuildContext context) {
    final theme = XCTheme.of(context);
    return Expanded(
      child: Text(
        value,
        style: theme.text.body.copyWith(
          fontWeight: FontWeight.w500,
          color: textColor ?? theme.foreground,
        ),
      ),
    );
  }
}

/// A widget row with a trailing muted label, in the new UI style.
///
/// Replaces the legacy `cv.LabeledWidget` from
/// `custom_views/labeled_widget.dart`.
class XCLabeledWidget extends StatelessWidget {
  const XCLabeledWidget(
    this.label, {
    super.key,
    required this.child,
    this.height,
    this.reversed = false,
    this.isExpanded = true,
  });

  final String label;
  final Widget child;
  final double? height;
  final bool reversed;
  final bool isExpanded;

  @override
  Widget build(BuildContext context) {
    final theme = XCTheme.of(context);
    final labelText = Text(
      label,
      style: theme.text.small.copyWith(
        fontWeight: FontWeight.w500,
        color: theme.foregroundMuted,
      ),
    );
    return reversed
        ? Row(
            children: [
              labelText,
              SizedBox(height: height ?? 50),
              if (isExpanded)
                Expanded(child: child)
              else
                Row(children: [const Spacer(), child]),
            ],
          )
        : Row(
            children: [
              if (isExpanded) Expanded(child: child),
              if (!isExpanded) child,
              if (!isExpanded) const Spacer(),
              SizedBox(height: height ?? 50),
              labelText,
            ],
          );
  }
}

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'core/root.dart';

enum NativeListStyle { androidStyle, iOSStyle }

// creats a SwiftUI list style that does NOT scroll
class NativeList extends StatefulWidget {
  const NativeList({
    Key? key,
    required this.children,
    this.padding = const EdgeInsets.all(0),
    this.itemPadding = const EdgeInsets.fromLTRB(16, 4, 16, 4),
    this.style,
    this.color,
  }) : super(key: key);

  final List<Widget> children;
  final EdgeInsets padding;
  final EdgeInsets itemPadding;
  final NativeListStyle? style;
  final Color? color;

  @override
  _NativeListState createState() => _NativeListState();
}

class _NativeListState extends State<NativeList> {
  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        dividerColor: Theme.of(context).brightness == Brightness.light
            ? Colors.black.withOpacity(0.1)
            : Colors.white.withOpacity(0.1),
        dividerTheme: const DividerThemeData(
          thickness: 0.5,
          indent: 16,
          endIndent: 0,
        ),
      ),
      child: showCorrectView(context),
    );
  }

  Widget showCorrectView(BuildContext context) {
    if (widget.style != null) {
      if (widget.style! == NativeListStyle.androidStyle) {
        return androidStyle(context);
      } else {
        return iOSStyle(context);
      }
    } else if (kIsWeb) {
      return androidStyle(context);
    } else if (Platform.isIOS || Platform.isMacOS) {
      return iOSStyle(context);
    } else {
      return androidStyle(context);
    }
  }

  Widget iOSStyle(BuildContext context) {
    return Material(
      color: widget.color ?? ViewColors.cellColor(context),
      shape: widget.children.length == 1
          ? RoundedRectangleBorder(borderRadius: BorderRadius.circular(25))
          : ContinuousRectangleBorder(borderRadius: BorderRadius.circular(35)),
      child: Padding(
        padding: widget.padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (Widget i in widget.children)
              Column(
                children: [
                  Padding(
                    padding: widget.itemPadding,
                    child: SizedBox(
                      width: double.infinity,
                      child: i,
                    ),
                  ),
                  if (i != widget.children.last) const Divider(height: 0.5),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget androidStyle(BuildContext context) {
    return Material(
      color: widget.color ?? ViewColors.cellColor(context),
      shape: widget.children.length == 1
          ? RoundedRectangleBorder(borderRadius: BorderRadius.circular(25))
          : ContinuousRectangleBorder(borderRadius: BorderRadius.circular(35)),
      child: Padding(
        padding: widget.padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (Widget i in widget.children)
              Column(
                children: [
                  Padding(
                    padding: widget.itemPadding,
                    child: SizedBox(
                      width: double.infinity,
                      child: i,
                    ),
                  ),
                  if (i != widget.children.last)
                    const Divider(
                      height: 0.5,
                      indent: 0,
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

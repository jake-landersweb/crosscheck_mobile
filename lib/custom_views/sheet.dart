import 'package:flutter/material.dart';
import 'package:sprung/sprung.dart';

import 'core/root.dart' as cv;

class CancelButton extends StatelessWidget {
  const CancelButton(
      {Key? key, this.color = Colors.blue, this.closeText = "Cancel"})
      : super(key: key);
  final Color color;
  final String closeText;

  @override
  Widget build(BuildContext context) {
    return cv.BasicButton(
      onTap: () {
        Navigator.of(context).pop();
      },
      child: Text(
        closeText,
        style: TextStyle(
          color: color,
          fontSize: 20,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class SheetHeader extends StatelessWidget {
  const SheetHeader({
    Key? key,
    required this.title,
    this.height = 50,
    this.color = Colors.blue,
    this.closeText = "Cancel",
  }) : super(key: key);

  final String title;
  final double height;
  final Color color;
  final String closeText;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
      color: MediaQuery.of(context).platformBrightness == Brightness.light
          ? Colors.black.withOpacity(0.1)
          : Colors.white.withOpacity(0.1),
      child: Stack(
        alignment: AlignmentDirectional.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          Row(children: [
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: CancelButton(
                color: color,
                closeText: closeText,
              ),
            ),
          ])
        ],
      ),
    );
  }
}

class Sheet extends StatefulWidget {
  const Sheet({
    Key? key,
    required this.title,
    required this.child,
    this.headerHeight = 50,
    this.color = Colors.blue,
    this.closeText = "Cancel",
    this.padding = const EdgeInsets.all(8),
  }) : super(key: key);

  final String title;
  final Widget child;
  final double headerHeight;
  final Color color;
  final String closeText;
  final EdgeInsets padding;

  @override
  _SheetState createState() => _SheetState();
}

class _SheetState extends State<Sheet> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          color: cv.ViewColors.cellColor(context),
          child: Padding(
            padding: widget.padding,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.title,
                        style: TextStyle(
                          color: cv.ViewColors.textColor(context),
                          fontSize: 26,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    cv.BasicButton(
                        onTap: () => Navigator.of(context).pop(),
                        child: Icon(Icons.close, color: widget.color)),
                  ],
                ),
                widget.child,
              ],
            ),
          ),
        ),
      ],
    );
  }
}

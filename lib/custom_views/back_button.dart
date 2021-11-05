import 'package:flutter/material.dart';
import 'core/basic_button.dart' as cv;

class BackButton extends StatelessWidget {
  final String title;
  final Color? color;
  final bool showText;
  BackButton({
    this.title = 'Back',
    this.color,
    this.showText = false,
  });
  @override
  Widget build(BuildContext context) {
    return cv.BasicButton(
      onTap: () {
        Navigator.of(context).pop();
      },
      child: Row(
        children: [
          Icon(
            Icons.chevron_left,
            size: 30,
            color: color ?? Theme.of(context).colorScheme.primary,
          ),
          if (showText)
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: color ?? Theme.of(context).colorScheme.primary,
              ),
            ),
        ],
      ),
    );
  }
}

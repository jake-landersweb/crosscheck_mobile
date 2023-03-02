import 'package:flutter/material.dart';
import 'core/basic_button.dart' as cv;

class BackButton extends StatelessWidget {
  final String title;
  final Color? color;
  final bool showText;
  final bool showIcon;
  final bool useRoot;
  const BackButton({
    Key? key,
    this.title = 'Back',
    this.color,
    this.showText = false,
    this.showIcon = true,
    this.useRoot = false,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return cv.BasicButton(
      onTap: () {
        Navigator.of(context, rootNavigator: useRoot).pop();
      },
      child: Row(
        children: [
          if (showIcon)
            Icon(
              Icons.chevron_left_rounded,
              size: 30,
              color: color ?? Theme.of(context).colorScheme.primary,
            ),
          if (showText)
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: color ?? Theme.of(context).colorScheme.primary,
              ),
            ),
        ],
      ),
    );
  }
}

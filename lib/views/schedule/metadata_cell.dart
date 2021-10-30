import 'package:flutter/material.dart';

import '../../custom_views/root.dart' as cv;
import '../../extras/root.dart';

class EventMetaDataCell extends StatelessWidget {
  EventMetaDataCell({
    Key? key,
    required this.title,
    this.child,
    required this.icon,
    this.onTap,
  }) : super(key: key);
  final String title;
  final Widget? child;
  final IconData icon;
  VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return cv.BasicButton(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: CustomColors.textColor(context)),
          const SizedBox(width: 16),
          child ??
              Expanded(
                child: SelectableText(
                  title,
                  style: TextStyle(
                    color: CustomColors.textColor(context),
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

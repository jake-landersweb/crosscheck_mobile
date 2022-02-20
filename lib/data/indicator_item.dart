import 'package:flutter/material.dart';

enum IndicatorItemType { status, success, error }

class IndicatorItem {
  late String title;
  late IndicatorItemType type;
  late double duration;

  IndicatorItem({
    required this.title,
    required this.type,
    required this.duration,
  });

  IndicatorItem clone() =>
      IndicatorItem(title: title, type: type, duration: duration);

  IndicatorItem.status(this.title, {double? duration}) {
    this.duration = duration ?? 3;
    type = IndicatorItemType.status;
  }

  IndicatorItem.success(this.title, {double? duration}) {
    this.duration = duration ?? 3;
    type = IndicatorItemType.success;
  }

  IndicatorItem.error(this.title, {double? duration}) {
    this.duration = duration ?? 3;
    type = IndicatorItemType.error;
  }

  Color getColor(BuildContext context) {
    switch (type) {
      case IndicatorItemType.success:
        return MediaQuery.of(context).platformBrightness == Brightness.light
            ? Colors.black
            : Colors.white;
      default:
        return Colors.red;
    }
  }

  Color getTextColor(BuildContext context) {
    switch (type) {
      case IndicatorItemType.success:
        return Colors.white;
      default:
        return MediaQuery.of(context).platformBrightness == Brightness.light
            ? Colors.white
            : Colors.black;
    }
  }

  IconData getIcon() {
    switch (type) {
      case IndicatorItemType.success:
        return Icons.done;
      default:
        return Icons.priority_high;
    }
  }

  double getOpacity() {
    switch (type) {
      case IndicatorItemType.success:
        return 0.1;
      default:
        return 0.3;
    }
  }
}

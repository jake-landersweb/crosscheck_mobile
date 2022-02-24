import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

enum IndicatorItemType { status, success, error }

class IndicatorItem {
  late String id;
  late String title;
  late IndicatorItemType type;
  late double duration;

  IndicatorItem({
    required this.id,
    required this.title,
    required this.type,
    required this.duration,
  });

  IndicatorItem clone() =>
      IndicatorItem(id: id, title: title, type: type, duration: duration);

  IndicatorItem.status(this.title, {double? duration}) {
    id = const Uuid().v4();
    this.duration = duration ?? 3;
    type = IndicatorItemType.status;
  }

  IndicatorItem.success(this.title, {double? duration}) {
    id = const Uuid().v4();
    this.duration = duration ?? 3;
    type = IndicatorItemType.success;
  }

  IndicatorItem.error(this.title, {double? duration}) {
    id = const Uuid().v4();
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
      case IndicatorItemType.error:
        return Colors.white;
      default:
        return MediaQuery.of(context).platformBrightness == Brightness.light
            ? Colors.black
            : Colors.white;
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

import 'package:crosscheck_sports/client/root.dart';
import 'package:crosscheck_sports/extras/root.dart';
import 'package:flutter/material.dart';

import '../../custom_views/root.dart' as cv;

cv.SegmentedPickerStyle segmentedPickerStyle(
  BuildContext context,
  DataModel dmodel, {
  Color? backgroundColor,
  double? height,
  Color? sliderColor,
  Color? selectedTextColor,
}) {
  return cv.SegmentedPickerStyle(
    sliderColor: sliderColor ?? dmodel.color.withOpacity(0.3),
    selectedTextColor: selectedTextColor ?? dmodel.color,
    backgroundColor: backgroundColor ?? CustomColors.cellColor(context),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    height: height ?? 40,
  );
}

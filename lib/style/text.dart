import 'package:crosscheck_sports/style/theme.dart';
import 'package:flutter/material.dart';

// Font family constant (synced with design/tokens/typography.json)
const kFontBody = 'Rubik';

class XCThemeText {
  late XCThemeData data;

  TextStyle get title => TextStyle(
    fontFamily: kFontBody,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: data.foreground,
  );

  TextStyle get subTitle => TextStyle(
    fontFamily: kFontBody,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: data.foreground,
  );

  TextStyle get label => TextStyle(
    fontFamily: kFontBody,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: data.foreground,
  );
  TextStyle get body => TextStyle(
    fontFamily: kFontBody,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: data.foreground,
  );

  TextStyle get small => TextStyle(
    fontFamily: kFontBody,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: data.foreground,
  );

  TextStyle get caption => TextStyle(
    fontFamily: kFontBody,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: data.foregroundMuted,
  );

  XCThemeText({required this.data});
}

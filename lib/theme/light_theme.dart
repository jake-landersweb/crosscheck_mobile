import 'package:flutter/material.dart';

import 'root.dart';
import '../extras/root.dart';

ThemeData lightTheme = ThemeData(
  backgroundColor: CustomColors.lightList,
  fontFamily: fontFamily(),
  brightness: Brightness.light,
  canvasColor: CustomColors.lightList,
  cardColor: Colors.white,
  cardTheme: CardTheme(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    color: Colors.white,
  ),
  colorScheme: ColorScheme(
    background: CustomColors.lightList,
    brightness: Brightness.light,
    error: Colors.red,
    onBackground: Colors.black,
    onError: Colors.white,
    onPrimary: Colors.grey[400]!, // used for accent buttons and objects
    onSecondary: Colors.grey[300]!,
    onSurface: Colors.black,
    primary: Colors.blue, // accent color for the app
    primaryVariant: Colors.blue[900]!,
    secondary: Colors.white,
    secondaryVariant: Colors.orange[900]!,
    surface: Colors.white,
  ),
  dividerColor: Colors.black.withOpacity(0.1),
  dividerTheme: const DividerThemeData(
    thickness: 0.5,
    indent: 16,
    endIndent: 0,
  ),
  scaffoldBackgroundColor: CustomColors.lightList, // scaffold base color
);

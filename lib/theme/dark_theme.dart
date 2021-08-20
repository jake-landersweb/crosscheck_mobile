import 'package:flutter/material.dart';

import 'root.dart';
import '../extras/root.dart';

ThemeData darkTheme = ThemeData(
  backgroundColor: Colors.black,
  fontFamily: fontFamily(),
  brightness: Brightness.dark,
  canvasColor: Colors.black,
  cardColor: CustomColors.darkList,
  cardTheme: CardTheme(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    color: CustomColors.darkList,
  ),
  colorScheme: ColorScheme(
    background: Colors.black,
    brightness: Brightness.dark,
    error: Colors.red,
    onBackground: Colors.white,
    onError: Colors.white,
    onPrimary: Colors.grey[400]!, // used for accent buttons and objects
    onSecondary: Colors.grey[300]!,
    onSurface: Colors.white,
    primary: Colors.blue, // accent color for the app
    primaryVariant: Colors.blue[900]!,
    secondary: Colors.black,
    secondaryVariant: Colors.orange[900]!,
    surface: Colors.black,
  ),
  dividerColor: Colors.white.withOpacity(0.1),
  dividerTheme: const DividerThemeData(
    thickness: 0.5,
    indent: 16,
    endIndent: 0,
  ),
  scaffoldBackgroundColor: Colors.black, // scaffold base color
);

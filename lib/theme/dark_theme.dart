import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'root.dart';
import '../extras/root.dart';

const Color dbg = Color.fromRGBO(30, 30, 33, 1);

ThemeData darkTheme = ThemeData(
  backgroundColor: dbg,
  fontFamily: fontFamily(),
  brightness: Brightness.dark,
  canvasColor: dbg,
  cardColor: CustomColors.darkList,
  cardTheme: CardTheme(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    color: CustomColors.darkList,
  ),
  colorScheme: ColorScheme(
    background: dbg,
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
    surface: dbg,
  ),
  dividerColor: Colors.white.withOpacity(0.1),
  dividerTheme: const DividerThemeData(
    thickness: 0.5,
    indent: 16,
    endIndent: 0,
  ),
  scaffoldBackgroundColor: dbg, // scaffold base color
);

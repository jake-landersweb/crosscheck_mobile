// ignore_for_file: constant_identifier_names

import 'package:crosscheck_sports/style/root.dart';
import 'package:flutter/material.dart';

// =============================================================================
// Brand Colors - synced with design/tokens/colors.json
// Source of truth: design/tokens/*.json and design/themes/*.json
// =============================================================================

// Brand colors (from design/tokens/colors.json)
const _primary = Color(0xFF06D6A0);

// Semantic colors (shared across themes)
const _success = Color(0xFF4a9d6b);
const _info = Color.fromARGB(255, 7, 7, 16);
const _error = Color(0xFFDC2626); // Distinct from coral

// Light theme colors (from design/themes/light.json)
const _lightBackground = Color(0xFFECEDEB); // Warm gray
const _lightForeground = Color(0xFF1A1A2E); // Navy
const _lightForegroundMuted = Color(0xFF6B7280); // Gray
const _lightCell = Color(0xFFFDFCF8); // Almost white with warm tint
const _lightBorder = Color(0xFFE5E5E5); // Silver

// Dark theme colors (matching original Crosscheck dark mode)
const _darkBackground = Color(0xFF1E1E21); // Dark charcoal
const _darkForeground = Color(0xFFF5F5F5); // Near white
const _darkForegroundMuted = Color(0xFF8E8E93); // System gray
const _darkCell = Color(0xFF303032); // Dark grey cards
const _darkBorder = Color(0xFF48484A); // Subtle borders

// =============================================================================
// XCThemeData
// =============================================================================

class XCThemeData {
  static const double buttonHeight = 48;
  static const double listItemHeight = 48;

  final Brightness brightness;
  final Color primary;
  final Color background;
  final Color foreground;
  final Color foregroundMuted;
  final Color cell;
  final Color border;
  final Color success;
  final Color info;
  final Color error;

  XCThemeRadius get radius => XCThemeRadius(data: this);
  XCThemeText get text => XCThemeText(data: this);

  const XCThemeData({
    required this.brightness,
    required this.primary,
    required this.background,
    required this.foreground,
    required this.foregroundMuted,
    required this.cell,
    required this.border,
    required this.success,
    required this.info,
    required this.error,
  });

  XCThemeData copyWith({
    Brightness? brightness,
    Color? primary,
    Color? background,
    Color? foreground,
    Color? foregroundMuted,
    Color? cell,
    Color? border,
    Color? success,
    Color? info,
    Color? error,
  }) {
    return XCThemeData(
      brightness: brightness ?? this.brightness,
      primary: primary ?? this.primary,
      background: background ?? this.background,
      foreground: foreground ?? this.foreground,
      foregroundMuted: foregroundMuted ?? this.foregroundMuted,
      cell: cell ?? this.cell,
      border: border ?? this.border,
      success: success ?? this.success,
      info: info ?? this.info,
      error: error ?? this.error,
    );
  }

  ColorScheme getColorScheme() {
    return ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: Colors.white,
      primaryContainer: cell,
      onPrimaryContainer: foreground,
      secondary: cell,
      onSecondary: foreground,
      secondaryContainer: cell,
      onSecondaryContainer: foreground,
      tertiary: primary,
      onTertiary: Colors.white,
      tertiaryContainer: cell,
      onTertiaryContainer: foreground,
      error: error,
      onError: Colors.white,
      errorContainer: cell,
      onErrorContainer: foreground,
      surface: background,
      onSurface: foreground,
      onSurfaceVariant: foregroundMuted,
      outline: border,
      shadow: brightness == Brightness.light ? Colors.black : Colors.white,
      inverseSurface: foreground,
      inversePrimary: primary,
    );
  }

  ThemeData getTheme() {
    var colorScheme = getColorScheme();
    return ThemeData.from(colorScheme: colorScheme);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is XCThemeData &&
          brightness == other.brightness &&
          primary == other.primary &&
          background == other.background &&
          foreground == other.foreground &&
          foregroundMuted == other.foregroundMuted &&
          cell == other.cell &&
          border == other.border &&
          success == other.success &&
          info == other.info &&
          error == other.error;

  @override
  int get hashCode => Object.hash(
    brightness,
    primary,
    background,
    foreground,
    foregroundMuted,
    cell,
    border,
    success,
    info,
    error,
  );
}

// =============================================================================
// Theme Definitions - synced with design/themes/*.json
// =============================================================================

const xcColorSchemeLight = XCThemeData(
  brightness: Brightness.light,
  primary: _primary,
  background: _lightBackground,
  foreground: _lightForeground,
  foregroundMuted: _lightForegroundMuted,
  cell: _lightCell,
  border: _lightBorder,
  success: _success,
  info: _info,
  error: _error,
);

const xcColorSchemeDark = XCThemeData(
  brightness: Brightness.dark,
  primary: _primary,
  background: _darkBackground,
  foreground: _darkForeground,
  foregroundMuted: _darkForegroundMuted,
  cell: _darkCell,
  border: _darkBorder,
  success: _success,
  info: _info,
  error: _error,
);

XCThemeData getXCColorScheme(BuildContext context, Brightness brightness) {
  return brightness == Brightness.dark ? xcColorSchemeDark : xcColorSchemeLight;
}

class XCTheme extends InheritedWidget {
  final XCThemeData data;

  const XCTheme({super.key, required this.data, required super.child});

  static XCThemeData of(BuildContext context) {
    final widget = context.dependOnInheritedWidgetOfExactType<XCTheme>();
    return widget?.data ?? xcColorSchemeLight;
  }

  @override
  bool updateShouldNotify(XCTheme oldWidget) => data != oldWidget.data;
}

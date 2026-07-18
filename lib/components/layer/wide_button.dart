import 'package:crosscheck_sports/components/core/animated_container.dart';
import 'package:crosscheck_sports/style/root.dart';
import 'package:flutter/material.dart';

enum _WideButtonStyle { primary, neutral, destructive }

/// A full-width action button in the new UI style.
///
/// Replaces the legacy `comp.ActionButton`, `comp.SubActionButton`, and
/// `comp.DestructionButton` from `views/components/buttons.dart`.
class XCWideButton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final bool? isLoading;
  final Color? color;
  final Color? backgroundColor;
  final double horizPadding;
  final _WideButtonStyle _style;

  /// Prominent tinted button for the main action on a screen.
  const XCWideButton.primary({
    super.key,
    required this.title,
    required this.onTap,
    this.color,
    this.isLoading,
    this.horizPadding = 0,
  }) : backgroundColor = null,
       _style = _WideButtonStyle.primary;

  /// Neutral cell-colored button for secondary actions.
  const XCWideButton.neutral({
    super.key,
    required this.title,
    required this.onTap,
    this.isLoading,
    this.backgroundColor,
    this.horizPadding = 0,
  }) : color = null,
       _style = _WideButtonStyle.neutral;

  /// Red button for destructive actions.
  const XCWideButton.destructive({
    super.key,
    required this.title,
    required this.onTap,
    this.isLoading,
    this.horizPadding = 0,
  }) : color = null,
       backgroundColor = null,
       _style = _WideButtonStyle.destructive;

  Color _bg(BuildContext context) {
    final theme = XCTheme.of(context);
    return switch (_style) {
      _WideButtonStyle.primary => color ?? theme.primary,
      _WideButtonStyle.neutral => backgroundColor ?? theme.cell,
      _WideButtonStyle.destructive => theme.error,
    };
  }

  Color _fg(BuildContext context) {
    final theme = XCTheme.of(context);
    return switch (_style) {
      _WideButtonStyle.primary => Colors.white,
      _WideButtonStyle.neutral => theme.foreground,
      _WideButtonStyle.destructive => Colors.white,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = XCTheme.of(context);
    final fg = _fg(context);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizPadding),
      child: XCAnimatedContainer.custom(
        customRadius: XCThemeData.buttonHeight / 2,
        onTap: onTap,
        color: _bg(context),
        height: XCThemeData.buttonHeight,
        width: double.infinity,
        child: Center(
          child: isLoading ?? false
              ? SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator.adaptive(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(fg),
                  ),
                )
              : Text(
                  title,
                  style: theme.text.body.copyWith(
                    color: fg,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }
}

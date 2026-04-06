import 'package:crosscheck_sports/style/theme.dart';
import 'package:flutter/material.dart';

/// A reusable row component with consistent styling.
///
/// Features:
/// - Optional icon or custom leading widget
/// - Title text
/// - Optional sublabel text
/// - Optional trailing widget (pill, chevron, etc.)
class XCRow extends StatelessWidget {
  final String title;
  final String? sublabel;
  final IconData? icon;
  final Color? iconColor;
  final Widget? leading;
  final Widget? trailing;
  final TextStyle? titleStyle;
  final TextStyle? sublabelStyle;

  const XCRow({
    super.key,
    required this.title,
    this.sublabel,
    this.icon,
    this.iconColor,
    this.leading,
    this.trailing,
    this.titleStyle,
    this.sublabelStyle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = XCTheme.of(context);

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: XCThemeData.listItemHeight),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            if (leading != null) ...[
              leading!,
              const SizedBox(width: 12),
            ] else if (icon != null) ...[
              Icon(icon, size: 20, color: iconColor ?? theme.foreground),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: sublabel != null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: titleStyle ?? theme.text.body),
                        Text(
                          sublabel!,
                          style:
                              sublabelStyle ??
                              theme.text.small.copyWith(
                                color: theme.foregroundMuted,
                              ),
                        ),
                      ],
                    )
                  : Text(title, style: titleStyle ?? theme.text.body),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}

/// A group container for XCRow widgets with rounded corners and dividers.
class XCRowGroup extends StatelessWidget {
  final List<Widget> children;

  const XCRowGroup({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = XCTheme.of(context);

    return ClipPath(
      clipper: ShapeBorderClipper(
        shape: RoundedSuperellipseBorder(
          borderRadius: BorderRadius.circular(theme.radius.large),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < children.length; i++) ...[
            children[i],
            if (i < children.length - 1)
              ColoredBox(
                color: theme.cell,
                child: Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Divider(height: 1, thickness: 1, color: theme.border),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

/// A header row for XCRowGroup with muted label styling.
class XCRowGroupHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;

  const XCRowGroupHeader({super.key, required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    final theme = XCTheme.of(context);

    return ColoredBox(
      color: theme.cell,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Text(
              title,
              style: theme.text.label.copyWith(color: theme.foregroundMuted),
            ),
            if (trailing != null) ...[const Spacer(), trailing!],
          ],
        ),
      ),
    );
  }
}

/// A status pill widget for displaying status text with colored background.
class XCStatusPill extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final Color textColor;

  const XCStatusPill({
    super.key,
    required this.text,
    required this.backgroundColor,
    required this.textColor,
  });

  /// Creates a success-styled pill.
  factory XCStatusPill.success(BuildContext context, String text) {
    final theme = XCTheme.of(context);
    return XCStatusPill(
      text: text,
      backgroundColor: theme.success.withValues(alpha: 0.15),
      textColor: theme.success,
    );
  }

  /// Creates a warning-styled pill (orange).
  factory XCStatusPill.warning(BuildContext context, String text) {
    return XCStatusPill(
      text: text,
      backgroundColor: Colors.orange.withValues(alpha: 0.15),
      textColor: Colors.orange,
    );
  }

  /// Creates an error-styled pill.
  factory XCStatusPill.error(BuildContext context, String text) {
    final theme = XCTheme.of(context);
    return XCStatusPill(
      text: text,
      backgroundColor: theme.error.withValues(alpha: 0.15),
      textColor: theme.error,
    );
  }

  /// Creates a muted/neutral-styled pill.
  factory XCStatusPill.muted(BuildContext context, String text) {
    final theme = XCTheme.of(context);
    return XCStatusPill(
      text: text,
      backgroundColor: theme.foregroundMuted.withValues(alpha: 0.15),
      textColor: theme.foregroundMuted,
    );
  }

  /// Creates a primary-styled pill.
  factory XCStatusPill.primary(BuildContext context, String text) {
    final theme = XCTheme.of(context);
    return XCStatusPill(
      text: text,
      backgroundColor: theme.primary.withValues(alpha: 0.15),
      textColor: theme.primary,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = XCTheme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: theme.text.caption.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

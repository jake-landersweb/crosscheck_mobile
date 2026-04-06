import 'package:crosscheck_sports/style/theme.dart';
import 'package:flutter/material.dart';

/// A large title text widget matching the HeaderBar large title style.
///
/// Renders text at 32px with weight w900, supporting up to 2 lines
/// with ellipsis overflow.
class XCLargeTitle extends StatelessWidget {
  const XCLargeTitle({super.key, required this.title, this.color});

  /// The title text to display.
  final String title;

  /// Optional override for the text color.
  /// Defaults to [XCThemeData.foreground].
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = XCTheme.of(context);
    return Text(
      title,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: theme.text.title.copyWith(
        fontSize: 32,
        fontWeight: FontWeight.w900,
        color: color ?? theme.foreground,
      ),
    );
  }
}

import 'package:flutter/widgets.dart';

/// An icon that can be rendered natively on each platform.
///
/// On iOS, uses SF Symbols via the [sfSymbol] name.
/// On Android/other platforms, uses Flutter [IconData].
///
/// SF Symbol names can be found at: https://developer.apple.com/sf-symbols/
/// You can also use the SF Symbols app on macOS to browse available icons.
///
/// Example:
/// ```dart
/// const myIcon = AdaptiveIcon(
///   icon: CupertinoIcons.heart,
///   sfSymbol: 'heart',
///   selectedIcon: CupertinoIcons.heart_fill,
///   selectedSfSymbol: 'heart.fill',
/// );
/// ```
class AdaptiveIcon {
  const AdaptiveIcon({
    required this.icon,
    required this.sfSymbol,
    this.selectedIcon,
    this.selectedSfSymbol,
  });

  /// Flutter icon for Android/other platforms.
  final IconData icon;

  /// SF Symbol name for iOS.
  ///
  /// Common SF Symbol patterns:
  /// - Outline: `map`, `heart`, `star`
  /// - Filled: `map.fill`, `heart.fill`, `star.fill`
  /// - Circle variants: `map.circle`, `map.circle.fill`
  final String sfSymbol;

  /// Optional selected state icon for Android/other platforms.
  /// Falls back to [icon] if not provided.
  final IconData? selectedIcon;

  /// Optional selected state SF Symbol for iOS.
  /// Falls back to [sfSymbol] if not provided.
  final String? selectedSfSymbol;

  /// Gets the appropriate icon for the current selection state.
  IconData getIcon({bool selected = false}) {
    if (selected && selectedIcon != null) {
      return selectedIcon!;
    }
    return icon;
  }

  /// Gets the appropriate SF Symbol for the current selection state.
  String getSfSymbol({bool selected = false}) {
    if (selected && selectedSfSymbol != null) {
      return selectedSfSymbol!;
    }
    return sfSymbol;
  }
}

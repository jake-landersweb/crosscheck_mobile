import '../icon/adaptive_icon.dart';

/// A tab item configuration for the adaptive tab bar.
///
/// Uses [AdaptiveIcon] to provide platform-appropriate icons.
class AdaptiveTabBarItem {
  const AdaptiveTabBarItem({
    required this.label,
    required this.icon,
    this.badge,
    this.isSearchTab = false,
  });

  final String label;
  final AdaptiveIcon icon;
  final String? badge;

  /// Whether this tab is a search tab.
  ///
  /// Search tabs activate search mode without navigating to a new page.
  final bool isSearchTab;
}

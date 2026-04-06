import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'adaptive_icon.dart';

/// Pre-defined adaptive icons for common use cases.
///
/// Uses FontAwesome icons for cross-platform consistency.
/// SF Symbol names are retained for native iOS rendering when needed.
abstract class AdaptiveIcons {
  /// Map icon with outline/filled variants.
  static const map = AdaptiveIcon(
    icon: FontAwesomeIcons.map,
    sfSymbol: 'map',
    selectedIcon: FontAwesomeIcons.map,
    selectedSfSymbol: 'map.fill',
  );

  /// Video/play rectangle icon with outline/filled variants.
  static const video = AdaptiveIcon(
    icon: FontAwesomeIcons.play,
    sfSymbol: 'play.rectangle',
    selectedIcon: FontAwesomeIcons.play,
    selectedSfSymbol: 'play.rectangle.fill',
  );

  /// Home icon with outline/filled variants.
  static const home = AdaptiveIcon(
    icon: FontAwesomeIcons.house,
    sfSymbol: 'house',
    selectedIcon: FontAwesomeIcons.house,
    selectedSfSymbol: 'house.fill',
  );

  /// Search/magnifying glass icon.
  static const search = AdaptiveIcon(
    icon: FontAwesomeIcons.magnifyingGlass,
    sfSymbol: 'magnifyingglass',
  );

  /// Settings/gear icon with outline/filled variants.
  static const settings = AdaptiveIcon(
    icon: FontAwesomeIcons.gear,
    sfSymbol: 'gear',
    selectedIcon: FontAwesomeIcons.gear,
    selectedSfSymbol: 'gear',
  );

  /// Person/profile icon with outline/filled variants.
  static const person = AdaptiveIcon(
    icon: FontAwesomeIcons.user,
    sfSymbol: 'person',
    selectedIcon: FontAwesomeIcons.solidUser,
    selectedSfSymbol: 'person.fill',
  );

  /// Heart/favorite icon with outline/filled variants.
  static const heart = AdaptiveIcon(
    icon: FontAwesomeIcons.heart,
    sfSymbol: 'heart',
    selectedIcon: FontAwesomeIcons.solidHeart,
    selectedSfSymbol: 'heart.fill',
  );

  /// Star icon with outline/filled variants.
  static const star = AdaptiveIcon(
    icon: FontAwesomeIcons.star,
    sfSymbol: 'star',
    selectedIcon: FontAwesomeIcons.solidStar,
    selectedSfSymbol: 'star.fill',
  );

  /// Bookmark icon with outline/filled variants.
  static const bookmark = AdaptiveIcon(
    icon: FontAwesomeIcons.bookmark,
    sfSymbol: 'bookmark',
    selectedIcon: FontAwesomeIcons.solidBookmark,
    selectedSfSymbol: 'bookmark.fill',
  );

  /// Location/pin icon with outline/filled variants.
  static const location = AdaptiveIcon(
    icon: FontAwesomeIcons.locationDot,
    sfSymbol: 'location',
    selectedIcon: FontAwesomeIcons.locationDot,
    selectedSfSymbol: 'location.fill',
  );

  /// Navigation arrow icon (classic compass/navigate symbol).
  static const navigation = AdaptiveIcon(
    icon: FontAwesomeIcons.locationArrow,
    sfSymbol: 'location.fill',
    selectedIcon: FontAwesomeIcons.locationArrow,
    selectedSfSymbol: 'location.fill',
  );

  /// Close/dismiss icon (X mark).
  static const close = AdaptiveIcon(
    icon: FontAwesomeIcons.xmark,
    sfSymbol: 'xmark',
  );

  /// Back/chevron left icon.
  static const chevronLeft = AdaptiveIcon(
    icon: FontAwesomeIcons.chevronLeft,
    sfSymbol: 'chevron.left',
  );

  /// Checkmark/confirm icon.
  static const check = AdaptiveIcon(
    icon: FontAwesomeIcons.check,
    sfSymbol: 'checkmark',
  );

  /// Add/plus icon.
  static const add = AdaptiveIcon(
    icon: FontAwesomeIcons.plus,
    sfSymbol: 'plus',
  );

  /// List icon with outline/filled variants.
  static const list = AdaptiveIcon(
    icon: FontAwesomeIcons.list,
    sfSymbol: 'list.bullet',
    selectedIcon: FontAwesomeIcons.list,
    selectedSfSymbol: 'list.bullet',
  );

  /// More/ellipsis icon.
  static const more = AdaptiveIcon(
    icon: FontAwesomeIcons.ellipsis,
    sfSymbol: 'ellipsis',
  );

  /// Envelope/mail icon with outline/filled variants.
  static const envelope = AdaptiveIcon(
    icon: FontAwesomeIcons.envelope,
    sfSymbol: 'envelope',
    selectedIcon: FontAwesomeIcons.solidEnvelope,
    selectedSfSymbol: 'envelope.fill',
  );
}

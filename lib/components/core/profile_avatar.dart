import 'package:cached_network_image/cached_network_image.dart';
import 'package:crosscheck_sports/style/color.dart';
import 'package:crosscheck_sports/style/theme.dart';
import 'package:flutter/material.dart';

/// A reusable circular avatar that shows a user's profile image
/// or falls back to a colored circle with their initial.
///
/// For authenticated users, pass the server avatar endpoint URL
/// as [imageUrl] (e.g., `${baseUrl}/avatar/${userId}`), which
/// handles the full fallback chain server-side.
class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    required this.seed,
    this.name,
    this.imageUrl,
    this.radius = 50,
  });

  /// Seed string used for deterministic background color (typically user ID).
  final String seed;

  /// User's display name, used to derive the fallback initial.
  final String? name;

  /// Image URL — can be the server avatar endpoint or a direct image URL.
  final String? imageUrl;

  /// Radius of the circle avatar.
  final double radius;

  @override
  Widget build(BuildContext context) {
    final theme = XCTheme.of(context);
    final initial = (name != null && name!.isNotEmpty)
        ? name![0].toUpperCase()
        : '?';

    // Scale font size relative to avatar radius.
    final fontSize = radius * 0.96;

    final fallback = CircleAvatar(
      radius: radius,
      backgroundColor: ColorUtil.random(seed),
      child: Text(
        initial,
        style: theme.text.title.copyWith(
          fontSize: fontSize,
          color: Colors.white,
        ),
      ),
    );

    if (imageUrl == null) return fallback;

    return ClipOval(
      child: SizedBox(
        width: radius * 2,
        height: radius * 2,
        child: CachedNetworkImage(
          imageUrl: imageUrl!,
          fit: BoxFit.cover,
          placeholder: (context, url) => fallback,
          errorWidget: (context, url, error) => fallback,
          fadeInDuration: Duration.zero,
          fadeOutDuration: Duration.zero,
        ),
      ),
    );
  }
}

import 'package:crosscheck_sports/style/theme.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// A small checkbox indicator for selection state.
///
/// Used in list/recommendation selection modals to indicate
/// whether an item is currently selected.
class SelectionCheckbox extends StatelessWidget {
  const SelectionCheckbox({super.key, required this.isSelected});

  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final theme = XCTheme.of(context);

    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: isSelected ? theme.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(theme.radius.small),
        border: Border.all(
          color: isSelected ? theme.primary : theme.foregroundMuted,
          width: 2,
        ),
      ),
      child: isSelected
          ? const Icon(FontAwesomeIcons.check, size: 12, color: Colors.white)
          : null,
    );
  }
}

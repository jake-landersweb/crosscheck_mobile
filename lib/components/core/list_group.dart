import 'package:crosscheck_sports/components/core/row.dart';
import 'package:crosscheck_sports/components/core/tap_effect.dart';
import 'package:crosscheck_sports/style/theme.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class XCListGroupItem {
  final String title;
  final String? sublabel;
  final IconData? icon;
  final Color? iconColor;
  final Widget? leading;
  final bool showChevron;
  final Widget? trailing;
  final VoidCallback? onTap;
  final TextStyle? titleStyle;
  final TextStyle? sublabelStyle;

  const XCListGroupItem({
    required this.title,
    this.sublabel,
    this.icon,
    this.iconColor,
    this.leading,
    this.showChevron = false,
    this.trailing,
    this.onTap,
    this.titleStyle,
    this.sublabelStyle,
  });
}

class XCListGroup extends StatelessWidget {
  final String? title;
  final List<XCListGroupItem> items;

  const XCListGroup({super.key, this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    final theme = XCTheme.of(context);
    const padding = 10.0;
    final innerRadius = theme.radius.large - padding;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (title != null) ...[
          Padding(
            padding: const EdgeInsets.only(left: 24, bottom: 8),
            child: Text(
              title!,
              style: theme.text.body.copyWith(
                color: theme.foregroundMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
        Container(
          decoration: ShapeDecoration(
            color: theme.cell,
            shape: RoundedSuperellipseBorder(
              borderRadius: BorderRadius.circular(theme.radius.large),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(padding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final item in items)
                  XCTapEffect(
                    borderRadius: innerRadius,
                    onTap: item.onTap,
                    child: XCRow(
                      title: item.title,
                      sublabel: item.sublabel,
                      icon: item.icon,
                      iconColor: item.iconColor,
                      leading: item.leading,
                      titleStyle: item.titleStyle,
                      sublabelStyle: item.sublabelStyle,
                      trailing: item.showChevron
                          ? Icon(
                              FontAwesomeIcons.chevronRight,
                              size: 14,
                              color: theme.foregroundMuted,
                            )
                          : item.trailing,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

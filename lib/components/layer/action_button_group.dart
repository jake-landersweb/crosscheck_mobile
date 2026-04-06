import 'package:crosscheck_sports/components/adaptive/icon/adaptive_icon.dart';
import 'package:crosscheck_sports/components/core/container.dart';
import 'package:crosscheck_sports/style/root.dart';
import 'package:flutter/material.dart';

class XCActionButtonGroupItem {
  final AdaptiveIcon icon;
  final void Function() onTap;
  final String? label;
  final bool isLoading;

  const XCActionButtonGroupItem({
    required this.icon,
    required this.onTap,
    this.label,
    this.isLoading = false,
  });
}

class XCActionButtonGroup extends StatelessWidget {
  final List<XCActionButtonGroupItem> items;
  final double size;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const XCActionButtonGroup({
    super.key,
    required this.items,
    this.size = XCThemeData.listItemHeight,
    this.backgroundColor,
    this.foregroundColor,
  });

  Color _bg(BuildContext context) {
    return backgroundColor ?? XCTheme.of(context).cell;
  }

  Color _fg(BuildContext context) {
    return foregroundColor ?? XCTheme.of(context).foreground;
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size / 2),
        boxShadow: const [
          // Soft ambient shadow
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.06),
            blurRadius: 16,
            spreadRadius: 0,
            offset: Offset(0, 1),
          ),
          // Tighter contact shadow
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.04),
            blurRadius: 4,
            spreadRadius: 0,
          ),
        ],
      ),
      child: XCContainer.custom(
        customRadius: size / 2,
        color: _bg(context),
        child: SizedBox(
          height: size,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: _buildChildren(context),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildChildren(BuildContext context) {
    final children = <Widget>[];

    for (var i = 0; i < items.length; i++) {
      final item = items[i];

      children.add(
        XCContainer(
          onTap: item.onTap,
          child: SizedBox(
            width: size,
            height: size,
            child: Center(child: _buildItemContent(context, item)),
          ),
        ),
      );
    }

    return children;
  }

  Widget _buildItemContent(BuildContext context, XCActionButtonGroupItem item) {
    if (item.isLoading) {
      return SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator.adaptive(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(_fg(context)),
        ),
      );
    }

    return Icon(item.icon.icon, color: _fg(context), size: 20);
  }
}

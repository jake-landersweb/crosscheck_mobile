import 'package:flutter/material.dart';
import 'package:crosscheck_sports/data/root.dart';
import 'package:crosscheck_sports/extras/root.dart';
import '../../custom_views/root.dart' as cv;
import 'root.dart';

class RosterCell extends StatelessWidget {
  const RosterCell({
    Key? key,
    required this.name,
    required this.type,
    this.seed,
    this.color = Colors.blue,
    this.size = 50,
    this.fontSize = 30,
    this.isSelected,
    this.padding = const EdgeInsets.all(8),
    this.isMVP = false,
    this.trailingWidget,
    this.backgroundColor,
    this.textColor,
    this.subtext,
  }) : super(key: key);
  final String name;
  final String? seed;
  final RosterListType type;
  final Color color;
  final double size;
  final double fontSize;
  final bool? isSelected;
  final EdgeInsets padding;
  final bool isMVP;
  final Widget? trailingWidget;
  final Color? backgroundColor;
  final Color? textColor;
  final String? subtext;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor ?? CustomColors.cellColor(context),
      child: Padding(
        padding: padding,
        child: Row(
          children: [
            RosterAvatar(name: name, seed: seed),
            const SizedBox(width: 8),
            Expanded(child: _name(context)),
            _endContent(context),
          ],
        ),
      ),
    );
  }

  Widget _name(BuildContext context) {
    if (subtext != null && subtext != "") {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 18,
              color: textColor ?? CustomColors.textColor(context),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 2),
          Text(
            subtext!,
            style: TextStyle(
              fontSize: 14,
              color: CustomColors.textColor(context).withOpacity(0.5),
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      );
    } else {
      return Text(
        name,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 18,
          color: textColor ?? CustomColors.textColor(context),
        ),
      );
    }
  }

  Widget _endContent(BuildContext context) {
    switch (type) {
      case RosterListType.selector:
        if (isSelected!) {
          return Icon(Icons.check_circle, color: color);
        } else {
          return const Icon(Icons.circle_outlined);
        }
      case RosterListType.navigator:
        return const Icon(Icons.chevron_right_rounded);
      default:
        if (trailingWidget != null) {
          return trailingWidget!;
        } else {
          return Container();
        }
    }
  }
}

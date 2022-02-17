import 'package:flutter/material.dart';
import 'package:pnflutter/data/root.dart';
import 'package:pnflutter/extras/root.dart';
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
  }) : super(key: key);
  final String name;
  final String? seed;
  final RosterListType type;
  final Color color;
  final double size;
  final double fontSize;
  final bool? isSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: CustomColors.cellColor(context),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            RosterAvatar(name: name, seed: seed),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                name,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  color: CustomColors.textColor(context),
                ),
              ),
            ),
            _endContent(context),
          ],
        ),
      ),
    );
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
        return Container();
    }
  }
}

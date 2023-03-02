import 'package:crosscheck_sports/data/root.dart';
import 'package:flutter/material.dart';
import 'package:crosscheck_sports/extras/root.dart';
import 'root.dart';

class BasicRosterCell extends StatelessWidget {
  const BasicRosterCell({super.key, required this.user, required this.team});
  final SeasonUser user;
  final Team team;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        RosterAvatar(name: user.name(team.showNicknames), seed: user.email),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            user.name(team.showNicknames),
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 18,
              color: CustomColors.textColor(context),
            ),
          ),
        ),
      ],
    );
  }
}

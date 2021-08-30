import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/root.dart';
import '../../custom_views/root.dart' as cv;
import '../../client/root.dart';
import '../../extras/root.dart';
import '../root.dart';

class Team extends StatefulWidget {
  const Team({
    Key? key,
    required this.teamId,
  }) : super(key: key);

  final String teamId;

  @override
  _TeamState createState() => _TeamState();
}

class _TeamState extends State<Team> {
  @override
  Widget build(BuildContext context) {
    return cv.NativeList(
      itemPadding: const EdgeInsets.all(16),
      children: [
        cv.BasicButton(
          onTap: () {
            cv.Navigate(context, TeamRoster(teamId: widget.teamId));
          },
          child: Row(
            children: [
              const Text(
                "Full Team Roster",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              Icon(Icons.chevron_right,
                  color: CustomColors.textColor(context).withOpacity(0.5)),
            ],
          ),
        ),
      ],
    );
  }
}

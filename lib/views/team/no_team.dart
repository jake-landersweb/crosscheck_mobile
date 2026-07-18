import 'package:crosscheck_sports/views/tsce/tsce_root.dart';
import 'package:crosscheck_sports/components/layer/snapping_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:crosscheck_sports/client/root.dart';
import 'package:provider/provider.dart';
import '../../custom_views/root.dart' as cv;
import 'root.dart';
import 'package:crosscheck_sports/components/layer/wide_button.dart';

class NoTeam extends StatefulWidget {
  const NoTeam({super.key});

  @override
  _NoTeamState createState() => _NoTeamState();
}

class _NoTeamState extends State<NoTeam> {
  @override
  Widget build(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    return Column(
      children: [
        cv.NoneFound(
          "You are not on any teams",
          color: dmodel.color,
          asset: "assets/svg/road.svg",
        ),
        const SizedBox(height: 32),
        XCWideButton.primary(
          color: dmodel.color,
          title: "Join Team",
          onTap: () {
            // join team
            showSnappingSheet(
      context: context,
      child: JoinTeam(email: dmodel.user!.email),
    );
          },
        ),
        const SizedBox(height: 16),
        XCWideButton.neutral(
          title: "Create My Team",
          onTap: () {
            showSnappingSheet(
              context: context,
              child: TSCERoot(user: dmodel.user!),
            );
          },
        ),
      ],
    );
  }
}

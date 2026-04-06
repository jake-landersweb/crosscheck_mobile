import 'package:flutter/material.dart';
import 'package:crosscheck_sports/views/root.dart';
import 'package:provider/provider.dart';
import '../../client/root.dart';
import '../../data/root.dart';
import '../../custom_views/root.dart' as cv;
import 'package:crosscheck_sports/components/layer/snapping_sheet.dart';
import '../components/root.dart' as comp;

class NoSeason extends StatefulWidget {
  const NoSeason({super.key});

  @override
  _NoSeasonState createState() => _NoSeasonState();
}

class _NoSeasonState extends State<NoSeason> {
  @override
  Widget build(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    return Column(
      children: [
        cv.NoneFound("It looks like this team has no seasons",
            color: dmodel.color),
        const SizedBox(height: 16),
        if (dmodel.tus?.user.isTeamAdmin() ?? false)
          comp.ActionButton(
            onTap: () {
              // create season
              if (dmodel.tus != null) {
                showSnappingSheet(
                    context: context,
                    child: SCERoot(
                      team: dmodel.tus!.team,
                      isCreate: true,
                    ),
                  );
              } else {
                dmodel.addIndicator(IndicatorItem.error(
                    "You have no loaded team data. How did that happen? Pull to refresh"));
              }
            },
            color: dmodel.color,
            title: "Create Season",
          ),
      ],
    );
  }
}

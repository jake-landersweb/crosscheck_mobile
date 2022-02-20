import 'package:flutter/material.dart';
import 'package:pnflutter/client/api_helpers.dart';
import 'package:pnflutter/views/root.dart';
import 'package:provider/provider.dart';
import '../../client/root.dart';
import '../../data/root.dart';
import '../../extras/root.dart';
import '../menu/root.dart';
import '../../custom_views/root.dart' as cv;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class NoSeason extends StatefulWidget {
  const NoSeason({Key? key}) : super(key: key);

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
          cv.RoundedLabel(
            "Create Season",
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: dmodel.color,
            textColor: Colors.white,
            onTap: () {
              // create team
              if (dmodel.tus != null) {
                showMaterialModalBottomSheet(
                  enableDrag: false,
                  context: context,
                  builder: (context) {
                    return SCERoot(team: dmodel.tus!.team, isCreate: true);
                  },
                );
              } else {
                dmodel.addIndicator(IndicatorItem.error(
                    "You have no loaded team data. How did that happen? Pull to refresh"));
              }
            },
          )
      ],
    );
  }
}

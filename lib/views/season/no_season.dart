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
          _buttonCell(
            "Create Season",
            () {
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
                dmodel.setError(
                    "You have no loaded team data. How did that happen? Pull to refresh",
                    true);
              }
            },
            dmodel.color,
            Colors.white,
            dmodel,
          ),
      ],
    );
  }

  Widget _buttonCell(String title, VoidCallback onTap, Color color,
      Color textColor, DataModel dmodel) {
    return cv.BasicButton(
      onTap: onTap,
      child: Material(
        color: color,
        shape: ContinuousRectangleBorder(
          borderRadius: BorderRadius.circular(35),
        ),
        child: SizedBox(
          height: cellHeight,
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                  color: textColor, fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}

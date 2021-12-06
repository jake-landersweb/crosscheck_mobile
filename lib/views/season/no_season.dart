import 'package:flutter/material.dart';
import 'package:pnflutter/client/api_helpers.dart';
import 'package:provider/provider.dart';
import '../../client/root.dart';
import '../../data/root.dart';
import '../../extras/root.dart';
import '../menu/root.dart';
import '../../custom_views/root.dart' as cv;

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
        const Text(
          "It looks like this team has no seasons.",
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        if (dmodel.tus!.user.isTeamAdmin())
          _buttonCell(
            "Create Season",
            () {
              // create team
              // cv.Navigate(context, const CreateTeam());
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
          height: 50,
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

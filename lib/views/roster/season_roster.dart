import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../root.dart';
import '../../client/root.dart';
import '../../data/root.dart';
import '../../custom_views/root.dart' as cv;

class SeasonRoster extends StatefulWidget {
  const SeasonRoster({Key? key}) : super(key: key);

  @override
  _SeasonRosterState createState() => _SeasonRosterState();
}

class _SeasonRosterState extends State<SeasonRoster> {
  @override
  void initState() {
    super.initState();
    _checkRoster(context.read<DataModel>());
  }

  @override
  Widget build(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    if (dmodel.seasonRoster == null) {
      // show loading
      return cv.NativeList(
        children: [
          for (int i = 0; i < 15; i++) const UserCellLoading(),
        ],
      );
    } else {
      if (dmodel.seasonRoster!.isEmpty) {
        return const Padding(
          padding: EdgeInsets.only(top: 20),
          child: Text(
            "There are no users a part of this season",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
        );
      } else {
        return Column(children: [
          cv.NativeList(
            children: [
              for (SeasonUser i in dmodel.seasonRoster!)
                _rosterCell(context, i, dmodel),
            ],
          ),
          const SizedBox(height: 30),
        ]);
      }
    }
  }

  Widget _rosterCell(BuildContext context, SeasonUser user, DataModel dmodel) {
    return cv.BasicButton(
      onTap: () {
        cv.Navigate(
          context,
          SeasonUserDetail(
            user: user,
            teamId: dmodel.tus!.team.teamId,
            seasonId: dmodel.currentSeason!.seasonId,
          ),
        );
      },
      child: UserCell(
        user: user,
        isClickable: true,
      ),
    );
  }

  void _checkRoster(DataModel dmodel) async {
    if (dmodel.seasonRoster == null) {
      await dmodel.getSeasonRoster(
          dmodel.tus!.team.teamId, dmodel.currentSeason!.seasonId, (users) {
        dmodel.setSeasonRoster(users);
      });
    } else {
      print('already have roster');
    }
  }
}

import 'package:crosscheck_sports/client/root.dart';
import 'package:crosscheck_sports/data/root.dart';
import 'package:crosscheck_sports/extras/root.dart';
import 'package:crosscheck_sports/views/root.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../custom_views/root.dart' as cv;
import '../../components/root.dart' as comp;
import 'root.dart';

class FTHome extends StatefulWidget {
  const FTHome({super.key});

  @override
  State<FTHome> createState() => _FTHomeState();
}

class _FTHomeState extends State<FTHome> {
  @override
  Widget build(BuildContext context) {
    FTModel ftmodel = Provider.of<FTModel>(context);
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        // list of users
        cv.Section(
          "Selected Users",
          child: cv.ListView<SeasonUser>(
            children: ftmodel.selectedUsers,
            childPadding: const EdgeInsets.all(8),
            horizontalPadding: 0,
            allowsDelete: true,
            onDelete: (item) async => ftmodel.removeUser(item),
            onChildTap: (context, item) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RUCERoot(
                    team: ftmodel.team,
                    season: ftmodel.season,
                    isSheet: true,
                    user: item,
                    isCreate: true,
                    teamToSeason: true,
                    onUserSave: (user) => ftmodel.handleUpdate(user),
                  ),
                ),
              );
            },
            childBuilder: (context, item) {
              return RosterCell(
                name: item.name(ftmodel.team.showNicknames),
                type: RosterListType.navigator,
                seed: item.email,
                padding: EdgeInsets.zero,
              );
            },
          ),
        ),
        // button to show model to add more users
        const SizedBox(height: 16),
        comp.SubActionButton(
          title: "Select Team Users",
          onTap: () {
            cv.cupertinoSheet(
              context: context,
              builder: (context) {
                return ListenableProvider.value(
                  value: ftmodel,
                  child: const FTTeamUsers(),
                );
              },
            );
          },
        ),
      ],
    );
  }
}

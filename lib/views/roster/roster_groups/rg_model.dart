import 'package:crosscheck_sports/client/root.dart';
import 'package:crosscheck_sports/data/root.dart';
import 'package:crosscheck_sports/data/roster/roster_group.dart';
import 'package:crosscheck_sports/views/root.dart';
import 'package:flutter/material.dart';

class RGModel extends ChangeNotifier {
  late Team team;
  late Season season;
  late List<SeasonUser> seasonRoster;
  List<RosterGroup>? rosterGroups;
  bool isLoading = true;
  String errorText = "";

  RGModel({
    required this.team,
    required this.season,
    required this.seasonRoster,
    required DataModel dmodel,
  }) {
    getRosterGroups(dmodel);
  }

  Future<void> getRosterGroups(DataModel dmodel) async {
    await dmodel.getAllRosterGroups(team.teamId, season.seasonId, (p0) {
      rosterGroups = p0;
      isLoading = false;
      notifyListeners();
    }, () {
      isLoading = false;
      errorText = "There was an issue fetching your roster groups";
      notifyListeners();
    });
  }

  Widget getRosterRow(String id) {
    final su = seasonRoster.firstWhere((element) => element.email == id);
    return RosterCell(
      name: su.name(team.showNicknames),
      type: RosterListType.none,
    );
  }

  Future<void> createRosterGroup(
    BuildContext context,
    DataModel dmodel,
    Map<String, dynamic> body,
  ) async {
    await dmodel.createRostergroup(team.teamId, season.seasonId, body, (p0) {
      rosterGroups!.add(p0);
      notifyListeners();
      dmodel.addIndicator(
        IndicatorItem.success("Successfully created roster group"),
      );
      Navigator.of(context, rootNavigator: true).pop();
    }, () {
      dmodel.addIndicator(
        IndicatorItem.error("There was an issue creating your roster group"),
      );
    });
  }

  Future<void> editRosterGroup(
    BuildContext context,
    DataModel dmodel,
    RosterGroup rg,
    Map<String, dynamic> body,
  ) async {
    await dmodel.updateRosterGroup(
        team.teamId, season.seasonId, rg.sortKey, body, (p0) {
      // replace the roster group with the returned value
      rosterGroups!
          .firstWhere((element) => element.sortKey == rg.sortKey)
          .update(p0);
      notifyListeners();
      dmodel.addIndicator(
        IndicatorItem.success("Successfully updated roster group"),
      );
      Navigator.of(context, rootNavigator: true).pop();
    }, () {
      dmodel.addIndicator(
        IndicatorItem.error("There was an issue updating your roster group"),
      );
    });
  }
}

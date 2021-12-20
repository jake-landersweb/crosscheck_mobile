import 'package:flutter/material.dart';
import 'package:pnflutter/client/root.dart';
import 'package:pnflutter/extras/root.dart';
import '../../../data/root.dart';

class SCEModel extends ChangeNotifier {
  String title = "";

  String website = "";
  String seasonNote = "";
  bool showNicknames = false;

  TeamPositions positions = TeamPositions.empty();

  List<CustomField> customFields = [];
  List<CustomUserField> customUserFields = [];
  List<CustomUserField> oldCustomUserFields = [];

  List<SeasonUser> teamUsers = [];

  TeamStat stats = TeamStat.empty();
  TeamStat oldStats = TeamStat.empty();

  int index = 0;

  late bool isCreate;

  int seasonStatus = 2;

  SCEModel.create(Team team) {
    isCreate = true;
    positions = TeamPositions.of(team.positions);
  }

  SCEModel.update(Team team, Season season) {
    isCreate = false;
    positions = TeamPositions.of(team.positions);
    title = season.title;
    website = season.website;
    seasonNote = season.seasonNote;
    showNicknames = season.showNicknames;
    positions = TeamPositions.of(season.positions);
    customFields = List.of(season.customFields);
    customUserFields = List.of(season.customUserFields);
    oldCustomUserFields = List.of(season.customUserFields);
    stats = TeamStat.of(season.stats);
    oldStats = TeamStat.of(season.stats);
    seasonStatus = season.seasonStatus;
  }

  Widget status(BuildContext context, DataModel dmodel) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isCreate ? 16 : 32.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _cell(context, dmodel, "Basic Info", 0, Icons.lightbulb),
          _spacer(context, dmodel),
          _cell(context, dmodel, "Positions", 1, Icons.engineering),
          _spacer(context, dmodel),
          _cell(context, dmodel, "Custom", 2, Icons.settings),
          _spacer(context, dmodel),
          _cell(context, dmodel, "Stats", 3, Icons.signal_cellular_alt),
          if (isCreate) _spacer(context, dmodel),
          if (isCreate) _cell(context, dmodel, "Users", 4, Icons.person_add),
        ],
      ),
    );
  }

  Widget _cell(BuildContext context, DataModel dmodel, String title, int status,
      IconData icon) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              height: MediaQuery.of(context).size.width / 8,
              width: MediaQuery.of(context).size.width / 8,
              decoration: BoxDecoration(
                border: Border.all(
                    width: 2,
                    color: status == index ? Colors.transparent : dmodel.color),
                color: status > index ? Colors.transparent : dmodel.color,
                shape: BoxShape.circle,
              ),
            ),
            Icon(icon, color: status > index ? dmodel.color : Colors.white),
          ],
        ),
        const SizedBox(height: 3),
        Text(
          title,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w300,
            color: CustomColors.textColor(context).withOpacity(0.5),
          ),
        ),
      ],
    );
  }

  Widget _spacer(BuildContext context, DataModel dmodel) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Container(
              height: 0.5,
              color: dmodel.color,
            ),
            const SizedBox(height: 3),
            Text(
              "",
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w300,
                color: CustomColors.textColor(context).withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void setIndex(int index) {
    this.index = index;
    notifyListeners();
  }

  void addStat(StatItem item) {
    stats.stats.add(item);
    notifyListeners();
  }

  void removeStat(int index) {
    stats.stats.removeAt(index);
    notifyListeners();
  }

  bool isAtEnd() {
    if (isCreate && index == 4) {
      return true;
    } else if (!isCreate && index == 3) {
      return true;
    } else {
      return false;
    }
  }

  String buttonTitle() {
    if (customFields.any((element) => element.title.isEmpty)) {
      return "Custom Fields Need Title";
    } else if (customUserFields.any((element) => element.title.isEmpty)) {
      return "Custom User Fields Need Title";
    } else if (stats.stats.any((element) => element.title.isEmpty)) {
      return "Stats Need A Title";
    } else {
      return isCreate ? "Create Season" : "Edit Season";
    }
  }

  bool isValidated() {
    if (customFields.any((element) => element.title.isEmpty)) {
      return false;
    } else if (customUserFields.any((element) => element.title.isEmpty)) {
      return false;
    } else if (stats.stats.any((element) => element.title.isEmpty)) {
      return false;
    } else {
      return true;
    }
  }
}

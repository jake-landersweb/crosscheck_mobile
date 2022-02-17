import 'package:flutter/material.dart';
import 'package:pnflutter/client/root.dart';
import 'package:pnflutter/extras/root.dart';
import '../../../data/root.dart';
import '../../../custom_views/root.dart' as cv;
import 'root.dart';
import 'package:sprung/sprung.dart';

class SCEModel extends ChangeNotifier {
  String title = "";

  String website = "";
  String seasonNote = "";

  TeamPositions positions = TeamPositions.empty();

  List<CustomField> customFields = [];
  List<CustomField> customUserFields = [];
  List<CustomField> oldCustomUserFields = [];

  List<CustomField> eventCustomFieldsTemplate = [];
  List<CustomField> eventCustomUserFieldsTemplate = [];

  List<SeasonUser> teamUsers = [];

  int index = 0;

  late bool isCreate;

  int seasonStatus = 2;

  int sportCode = 0;

  SCEModel.create(Team team) {
    isCreate = true;
    positions = TeamPositions.of(team.positions);
  }

  SCEModel.update(Team team, Season season) {
    setSeasonData(team, season);
    isCreate = false;
  }

  void setSeasonData(Team team, Season season) {
    positions = TeamPositions.of(team.positions);
    title = season.title;
    website = season.website;
    seasonNote = season.seasonNote;
    positions = TeamPositions.of(season.positions);
    customFields = [for (var i in season.customFields) i.clone()];
    customUserFields = [for (var i in season.customUserFields) i.clone()];
    oldCustomUserFields = [for (var i in season.customUserFields) i.clone()];
    seasonStatus = season.seasonStatus;
    sportCode = season.sportCode;
    eventCustomFieldsTemplate = [
      for (var i in season.eventCustomFieldsTemplate) i.clone()
    ];
    eventCustomUserFieldsTemplate = [
      for (var i in season.eventCustomUserFieldsTemplate) i.clone()
    ];
    notifyListeners();
  }

  Widget status(
      BuildContext context, DataModel dmodel, PageController controller) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isCreate ? 16 : 32.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          cv.BasicButton(
              onTap: () {
                controller.animateToPage(
                  0,
                  duration: const Duration(milliseconds: 700),
                  curve: Sprung.overDamped,
                );
                notifyListeners();
              },
              child: _cell(context, dmodel, "Basic Info", 0, Icons.lightbulb)),
          _spacer(context, dmodel),
          cv.BasicButton(
            onTap: () {
              controller.animateToPage(
                1,
                duration: const Duration(milliseconds: 700),
                curve: Sprung.overDamped,
              );
              notifyListeners();
            },
            child: _cell(context, dmodel, "Positions", 1, Icons.engineering),
          ),
          _spacer(context, dmodel),
          cv.BasicButton(
            onTap: () {
              controller.animateToPage(
                2,
                duration: const Duration(milliseconds: 700),
                curve: Sprung.overDamped,
              );
              notifyListeners();
            },
            child: _cell(context, dmodel, "Custom", 2, Icons.settings),
          ),
          if (isCreate) _spacer(context, dmodel),
          if (isCreate)
            cv.BasicButton(
              onTap: () {
                controller.animateToPage(
                  3,
                  duration: const Duration(milliseconds: 700),
                  curve: Sprung.overDamped,
                );
                notifyListeners();
              },
              child: _cell(context, dmodel, "Users", 3, Icons.person_add),
            ),
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

  // Widget statView(BuildContext context, DataModel dmodel) {
  //   return cv.AnimatedList<StatItem>(
  //     padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
  //     buttonPadding: 20,
  //     children: stats.stats,
  //     cellBuilder: (BuildContext context, StatItem item) {
  //       // return CustomFieldField(item: item);
  //       return StatCell(
  //         item: item,
  //         color: dmodel.color,
  //         onTitleChange: (value) {
  //           item.setTitle(value);
  //           notifyListeners();
  //         },
  //       );
  //     },
  //     onRemove: (index) {
  //       removeStat(index);
  //     },
  //   );
  // }

  void setIndex(int index) {
    this.index = index;
    notifyListeners();
  }

  bool isAtEnd() {
    if (isCreate && index == 3) {
      return true;
    } else if (!isCreate && index == 2) {
      return true;
    } else {
      return false;
    }
  }

  String buttonTitle() {
    if (title.isEmpty) {
      return "Title Cannot Be Blank";
    } else if (customFields.any((element) => element.title.isEmpty)) {
      return "Custom Field Title Empty";
    } else if (customUserFields.any((element) => element.title.isEmpty)) {
      return "Custom Field Title Empty";
    } else if (eventCustomFieldsTemplate
        .any((element) => element.title.isEmpty)) {
      return "Custom Field Title Empty";
    } else if (eventCustomUserFieldsTemplate
        .any((element) => element.title.isEmpty)) {
      return "Custom Field Title Empty";
    } else {
      return isCreate ? "Create Season" : "Edit Season";
    }
  }

  bool isValidated() {
    if (title.isEmpty) {
      return false;
    } else if (customFields.any((element) => element.title.isEmpty)) {
      return false;
    } else if (customUserFields.any((element) => element.title.isEmpty)) {
      return false;
    } else if (eventCustomFieldsTemplate
        .any((element) => element.title.isEmpty)) {
      return false;
    } else if (eventCustomUserFieldsTemplate
        .any((element) => element.title.isEmpty)) {
      return false;
    } else {
      return true;
    }
  }
}

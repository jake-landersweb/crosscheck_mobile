import 'package:crosscheck_sports/data/templates/template.dart';
import 'package:flutter/material.dart';
import 'package:crosscheck_sports/client/root.dart';
import 'package:crosscheck_sports/extras/root.dart';
import '../../../data/root.dart';
import '../../../custom_views/root.dart' as cv;
import 'root.dart';
import 'package:sprung/sprung.dart';

class SCEModel extends ChangeNotifier {
  Team team;
  Season? season;
  String title = "";

  String website = "";
  String seasonNote = "";
  String timezone = "US/Pacific";

  TeamPositions positions = TeamPositions.empty();

  List<CustomField> customFields = [];
  List<CustomField> customUserFields = [];
  List<CustomField> oldCustomUserFields = [];

  List<CustomField> eventCustomFieldsTemplate = [];
  List<CustomField> eventCustomUserFieldsTemplate = [];

  List<EventDuty> eventDuties = [];

  TeamStat stats = TeamStat.empty();
  bool hasStats = true;

  int index = 0;

  late bool isCreate;

  int seasonStatus = 2;

  int sportCode = 0;

  List<TemplateName>? names;
  List<TemplateName>? seasonTemplates;
  String selectedName = "None";

  SCEModel.create(this.team, this.season) {
    isCreate = true;
    positions = TeamPositions.of(team.positions);
    if (season != null) {
      setSeasonData(season!);
    }
  }

  SCEModel.update(this.team, this.season) {
    setSeasonData(season!);
    isCreate = false;
  }

  void setSeasonData(Season season) {
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
    stats = TeamStat(
        isActive: season.stats.isActive, stats: List.of(season.stats.stats));
    hasStats = season.hasStats;
    timezone = season.timezone;
    notifyListeners();
  }

  void setTemplate(Template template) {
    title = template.title;
    positions = TeamPositions.of(template.meta.positions);
    customFields = [for (var i in template.meta.customFields) i.clone()];
    customUserFields = [
      for (var i in template.meta.customUserFields) i.clone()
    ];
    eventCustomFieldsTemplate = [
      for (var i in template.meta.eventCustomFieldsTemplate!) i.clone()
    ];
    eventCustomUserFieldsTemplate = [
      for (var i in template.meta.eventCustomUserFieldsTemplate!) i.clone()
    ];
    stats = TeamStat(
      isActive: template.meta.stats!.isActive,
      stats: List.of(
        template.meta.stats!.stats,
      ),
    );
    notifyListeners();
  }

  Widget status(
      BuildContext context, DataModel dmodel, PageController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          if (isCreate)
            _cell(context, dmodel, controller, "Template", 0,
                Icons.category_rounded),
          if (isCreate) _spacer(context, dmodel),
          _cell(context, dmodel, controller, "Basic Info",
              1 - (isCreate ? 0 : 1), Icons.lightbulb),
          _spacer(context, dmodel),
          _cell(context, dmodel, controller, "Positions",
              2 - (isCreate ? 0 : 1), Icons.engineering),
          _spacer(context, dmodel),
          _cell(context, dmodel, controller, "Custom", 3 - (isCreate ? 0 : 1),
              Icons.settings),
          _spacer(context, dmodel),
          _cell(context, dmodel, controller, "Stats", 4 - (isCreate ? 0 : 1),
              Icons.bar_chart),
        ],
      ),
    );
  }

  Widget _cell(BuildContext context, DataModel dmodel,
      PageController controller, String title, int status, IconData icon) {
    return cv.BasicButton(
      onTap: () {
        controller.animateToPage(
          status,
          duration: const Duration(milliseconds: 700),
          curve: Sprung.overDamped,
        );
        notifyListeners();
      },
      child: Column(
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
                      color:
                          status == index ? Colors.transparent : dmodel.color),
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
      ),
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
    if (isCreate && index == 4) {
      return true;
    } else if (!isCreate && index == 3) {
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

import 'package:crosscheck_sports/client/root.dart';
import 'package:crosscheck_sports/data/root.dart';
import 'package:crosscheck_sports/data/templates/template.dart';
import 'package:crosscheck_sports/data/tuple.dart';
import 'package:crosscheck_sports/extras/root.dart';
import 'package:crosscheck_sports/views/roster/from_excel/su_excel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:crosscheck_sports/custom_views/root.dart' as cv;
import 'package:sprung/sprung.dart';

class TSCEModel extends ChangeNotifier {
  late String email;
  int index = 0;

  // team and season fields
  TextEditingController teamName = TextEditingController();
  TextEditingController seasonName = TextEditingController();
  String website = "";
  String seasonNote = "";
  String color = "7bc5d6";
  bool isLight = true;
  bool showNicknames = true;
  String timezone = "US/Pacific";
  TeamPositions positions = TeamPositions.empty();
  List<CustomField> teamCustomFields = [];
  List<CustomField> teamCustomUserFields = [];
  List<CustomField> seasonCustomFields = [];
  List<CustomField> seasonCustomUserFields = [];
  List<CustomField> eventCustomFieldsTemplate = [];
  List<CustomField> eventCustomUserFieldsTemplate = [];
  TeamStat stats = TeamStat.empty();
  bool hasStats = true;
  List<SUExcel> users = [];
  bool autoPositions = false;

  List<TemplateName>? names;
  String selectedName = "None";

  TSCEModel({required this.email});

  void setTemplate(Template template) {
    seasonName.text = template.title;
    positions = TeamPositions.of(template.meta.positions);
    teamCustomFields = [for (var i in template.meta.customFields) i.clone()];
    teamCustomUserFields = [
      for (var i in template.meta.customUserFields) i.clone()
    ];
    seasonCustomFields = [for (var i in template.meta.customFields) i.clone()];
    seasonCustomUserFields = [
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
          _cell(context, dmodel, controller, "Template", 0,
              Icons.category_rounded),
          _spacer(context, dmodel),
          _cell(context, dmodel, controller, "Basic Info", 1, Icons.lightbulb),
          _spacer(context, dmodel),
          _cell(context, dmodel, controller, "Roster", 2,
              Icons.people_alt_rounded),
          _spacer(context, dmodel),
          _cell(context, dmodel, controller, "Additional", 3, Icons.settings),
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

  void setIndex(int index) {
    this.index = index;
    notifyListeners();
  }

  bool isAtEnd() {
    return index == 3;
  }

  // DO NOT DO THIS (unless you are me)
  void updateState() {
    notifyListeners();
  }

  Tuple<bool, String> isValidated() {
    if (teamName.text.isEmpty) {
      return Tuple(false, "No Team Name");
    } else if (seasonName.text.isEmpty) {
      return Tuple(false, "No Season Name");
    } else if (seasonCustomFields.any((element) => element.title.isEmpty)) {
      return Tuple(false, "Custom Field Empty");
    } else if (seasonCustomUserFields.any((element) => element.title.isEmpty)) {
      return Tuple(false, "Custom Field Empty");
    } else if (eventCustomFieldsTemplate
        .any((element) => element.title.isEmpty)) {
      return Tuple(false, "Custom Field Empty");
    } else if (eventCustomUserFieldsTemplate
        .any((element) => element.title.isEmpty)) {
      return Tuple(false, "Custom Field Empty");
    } else {
      return Tuple(true, "Create My Team");
    }
  }

  Map<String, dynamic> getBody() {
    return {
      "email": email,
      "teamName": teamName.text,
      "seasonName": seasonName.text,
      "color": color,
      "isLight": isLight,
      "showNicknames": showNicknames,
      "website": website,
      "seasonNote": seasonNote,
      "tz": timezone,
      "positions": positions.toJson(),
      "seasonCustomFields": seasonCustomFields.map((e) => e.toJson()).toList(),
      "seasonCustomUserFields":
          seasonCustomUserFields.map((e) => e.toJson()).toList(),
      "eventCustomFieldsTemplate":
          eventCustomFieldsTemplate.map((e) => e.toJson()).toList(),
      "eventCustomUserFieldsTemplate":
          eventCustomUserFieldsTemplate.map((e) => e.toJson()).toList(),
      "stats": stats.toJson(),
      "hasStats": hasStats,
      "users": users.map((e) => e.toMap()).toList(),
      "autoPositions": autoPositions,
    };
  }
}

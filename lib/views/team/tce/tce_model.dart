import 'package:crosscheck_sports/data/templates/template.dart';
import 'package:flutter/material.dart';
import 'package:crosscheck_sports/client/root.dart';
import 'package:crosscheck_sports/data/root.dart';
import 'package:crosscheck_sports/extras/root.dart';
import 'package:sprung/sprung.dart';
import '../../../custom_views/root.dart' as cv;

class TCEModel extends ChangeNotifier {
  late User user;
  late Team team;
  late bool isCreate;
  late bool imgIsUrl;

  List<TemplateName>? names;
  String selectedName = "None";

  TCEModel.create(this.user, this.team, this.isCreate) {
    imgIsUrl = false;
  }
  TCEModel.update(this.user, Team team, this.isCreate) {
    this.team = team.clone();
    imgIsUrl = team.image.contains("https://crosscheck-sports.s3.amazonaws.com")
        ? false
        : true;
  }

  int index = 0;

  Widget status(
      BuildContext context, DataModel dmodel, PageController controller) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isCreate ? 16 : 32),
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
    if (isCreate && index == 3) {
      return true;
    } else if (!isCreate && index == 2) {
      return true;
    } else {
      return false;
    }
  }

  Tuple<bool, String> isValidated() {
    if (team.title == "") {
      return Tuple(false, "Title cannot be empty");
    } else if (team.customFields.any((element) => element.title.isEmpty)) {
      return Tuple(false, "Custom Fields empty");
    } else if (team.customUserFields.any((element) => element.title.isEmpty)) {
      return Tuple(false, "Custom User Fields empty");
    } else {
      return Tuple(true, isCreate ? "Create Team" : "Edit Team");
    }
  }

  void setTemplate(Template template) {
    team.title = template.title;
    team.positions = TeamPositions.of(template.meta.positions);
    team.customFields = [for (var i in template.meta.customFields) i.clone()];
    team.customUserFields = [
      for (var i in template.meta.customUserFields) i.clone()
    ];
    notifyListeners();
  }
}

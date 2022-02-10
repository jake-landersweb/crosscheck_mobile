import 'package:flutter/material.dart';
import 'package:pnflutter/client/root.dart';
import 'package:pnflutter/extras/root.dart';
import '../../../data/root.dart';
import '../../../custom_views/root.dart' as cv;
import 'root.dart';
import 'package:sprung/sprung.dart';

class ECEModel extends ChangeNotifier {
  late bool isCreate;
  Event event = Event.empty();
  int index = 0;
  DateTime eventDate = DateTime.now();
  String opponentName = "";
  bool isHome = true;
  List<String> subEmails = [];
  Team? team;
  Season season;

  List<CustomField> oldCustomUserFields = [];

  ECEModel.create(this.season) {
    isCreate = true;
    this.event.customFields = [
      for (var i in season.eventCustomFieldsTemplate) i.clone()
    ];
    this.event.customUserFields = [
      for (var i in season.eventCustomUserFieldsTemplate) i.clone()
    ];
  }

  ECEModel.update(this.team, this.season, Event event) {
    isCreate = false;
    setSeasonData(team!, season, event);
  }

  void setSeasonData(Team team, Season season, Event event) {
    this.event = event.clone();
    eventDate = stringToDate(event.eDate);
    opponentName = event.getOpponentTitle(team.teamId);
    isHome = event.isHome();
    oldCustomUserFields = [for (var i in event.customUserFields) i.clone()];
    notifyListeners();
  }

  Widget status(
      BuildContext context, DataModel dmodel, PageController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
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
            child: _cell(context, dmodel, "Custom", 1, Icons.settings),
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
            child: _cell(context, dmodel, "Extra", 2, Icons.map),
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

  void setIndex(int index) {
    this.index = index;
    notifyListeners();
  }

  void addCustomField() {}

  bool isAtEnd() {
    if (index > 1) {
      return true;
    } else {
      return false;
    }
  }

  String buttonTitle() {
    if (event.eventType == 1 && opponentName.isEmpty) {
      return "Opponent cannot be empty";
    } else if (event.eventType != 1 && event.eTitle.isEmpty) {
      return "Title cannot be empty";
    } else if (event.customFields.any((element) => element.title.isEmpty)) {
      return "Empty Custom Field";
    } else if (event.customUserFields.any((element) => element.title.isEmpty)) {
      return "Empty Custom Field";
    } else {
      return isCreate ? "Create Event" : "Edit Event";
    }
  }

  bool isValidated() {
    if (event.eventType == 1 && opponentName.isEmpty) {
      return false;
    } else if (event.eventType != 1 && event.eTitle.isEmpty) {
      return false;
    } else if (event.customFields.any((element) => element.title.isEmpty)) {
      return false;
    } else if (event.customUserFields.any((element) => element.title.isEmpty)) {
      return false;
    } else {
      return true;
    }
  }
}

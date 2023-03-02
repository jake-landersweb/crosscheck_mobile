import 'package:flutter/material.dart';
import 'package:crosscheck_sports/client/root.dart';
import 'package:crosscheck_sports/extras/root.dart';
import '../../../data/root.dart';
import '../../../custom_views/root.dart' as cv;
import 'root.dart';
import 'package:sprung/sprung.dart';

class ECEModel extends ChangeNotifier {
  late bool isCreate;
  Event event = Event.empty();
  int index = 0;
  late DateTime eventDate;
  bool isHome = true;
  Team? team;
  Season season;
  late TextEditingController titleController;
  String? loadingOpponent;

  List<SeasonUser> users;

  List<CustomField> oldCustomUserFields = [];
  List<SeasonUser> addUsers = [];

  ECEModel.create(this.team, this.season, this.users) {
    titleController = TextEditingController();
    isCreate = true;
    eventDate = DateTime.now().add(const Duration(days: 1));
    event.customFields = [
      for (var i in season.eventCustomFieldsTemplate) i.clone()
    ];
    event.customUserFields = [
      for (var i in season.eventCustomUserFieldsTemplate) i.clone()
    ];
    // add all users to add list that are not subs
    for (var i in users) {
      if (!i.seasonFields!.isSub && i.seasonFields!.seasonUserStatus == 1) {
        addUsers.add(i);
      }
    }
  }

  ECEModel.update(this.team, this.season, Event event, this.users,
      List<SeasonUser>? eventUsers) {
    isCreate = false;
    if (event.eventType == 1) {
      if (event.overrideTitle) {
        titleController = TextEditingController(text: event.eTitle);
      } else {
        titleController =
            TextEditingController(text: event.getOpponentTitle(team!.teamId));
      }
    } else {
      titleController = TextEditingController(text: event.eTitle);
    }
    setSeasonData(team!, season, event);
    if (eventUsers != null) {
      addUsers = List.of(eventUsers);
    } else {
      addUsers = [];
    }
  }

  void setSeasonData(Team team, Season season, Event event) {
    this.event = event.clone();
    eventDate = stringToDate(event.eDate);
    isHome = event.isHomeTeam();
    oldCustomUserFields = [for (var i in event.customUserFields) i.clone()];
    notifyListeners();
  }

  Widget status(
      BuildContext context, DataModel dmodel, PageController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
            child: _cell(context, dmodel, "Users", 2, Icons.person),
          ),
          _spacer(context, dmodel),
          cv.BasicButton(
            onTap: () {
              controller.animateToPage(
                3,
                duration: const Duration(milliseconds: 700),
                curve: Sprung.overDamped,
              );
              notifyListeners();
            },
            child: _cell(context, dmodel, "Extra", 3, Icons.map),
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
    if (index > 2) {
      return true;
    } else {
      return false;
    }
  }

  String buttonTitle() {
    if (event.eventType == 1 && titleController.text.isEmpty) {
      return "Opponent cannot be empty";
    } else if (event.eventType != 1 && titleController.text.isEmpty) {
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
    if (titleController.text.isEmpty) {
      return false;
    } else if (event.customFields.any((element) => element.title.isEmpty)) {
      return false;
    } else if (event.customUserFields.any((element) => element.title.isEmpty)) {
      return false;
    } else {
      return true;
    }
  }

  Future<void> removeOpponentTitle(DataModel dmodel, String title) async {
    loadingOpponent = title;
    notifyListeners();
    List<String> titles = List.from(season.opponents);
    titles = [
      for (var i in titles)
        if (i != title) i
    ];
    await dmodel.updateSeason(
      team!.teamId,
      season.seasonId,
      {"opponents": titles},
      () {
        season.opponents = titles;
        dmodel.currentSeason!.opponents = titles;
      },
    );
    loadingOpponent = null;
    notifyListeners();
  }
}

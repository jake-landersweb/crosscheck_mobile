import 'package:crosscheck_sports/client/root.dart';
import 'package:crosscheck_sports/data/root.dart';
import 'package:crosscheck_sports/data/season/poll.dart';
import 'package:crosscheck_sports/extras/root.dart';
import 'package:flutter/material.dart';
import 'package:crosscheck_sports/custom_views/root.dart' as cv;
import 'package:sprung/sprung.dart';

class PollsModel extends ChangeNotifier {
  int index = 0;
  late Poll poll;
  late bool isCreate;
  late DateTime time;
  late Team team;
  late Season season;
  List<SeasonUser> users;
  List<SeasonUser> addUsers = [];

  PollsModel.create(this.team, this.season, this.users) {
    poll = Poll.empty();
    isCreate = true;
    time = DateTime.now().add(const Duration(days: 1));
    poll.choices = ["True", "False"];
    for (var i in users) {
      if (!i.seasonFields!.isSub && i.seasonFields!.seasonUserStatus == 1) {
        addUsers.add(i);
      }
    }
  }

  PollsModel.update(Poll poll, this.team, this.season, this.users,
      List<SeasonUser> pollUsers) {
    this.poll = poll.clone();
    isCreate = false;
    time = stringToDate(poll.date);
    addUsers = List.of(pollUsers);
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
              child: _cell(
                  context, dmodel, "Choices", 1, Icons.format_list_bulleted)),
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

  bool isAtEnd() {
    if (index > 1) {
      return true;
    } else {
      return false;
    }
  }

  bool isValidated() {
    if (poll.title.isEmpty) {
      return false;
    } else if (poll.pollType == 3) {
      return true;
    } else if (poll.choices.isEmpty) {
      return false;
    } else {
      return true;
    }
  }

  String buttonTitle() {
    if (poll.title.isEmpty) {
      return "Title empty";
    } else if (poll.pollType == 3) {
      return isCreate ? "Create Poll" : "Update Poll";
    } else if (poll.choices.isEmpty) {
      return "No Choices";
    } else {
      return isCreate ? "Create Poll" : "Update Poll";
    }
  }
}

import 'package:flutter/material.dart';
import 'package:pnflutter/client/root.dart';
import 'package:pnflutter/data/root.dart';
import 'package:pnflutter/extras/root.dart';
import 'package:sprung/sprung.dart';
import '../../../custom_views/root.dart' as cv;

class TCEModel extends ChangeNotifier {
  late User user;
  late Team team;
  late bool isCreate;

  TCEModel.create(this.user) {
    team = Team.empty();
    isCreate = true;
  }

  TCEModel.update(this.user, Team team) {
    this.team = team.clone();
    isCreate = false;
  }

  int index = 0;

  Widget status(
      BuildContext context, DataModel dmodel, PageController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
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
            child: _cell(context, dmodel, "Stats", 3, Icons.bar_chart),
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
    if (index == 3) {
      return true;
    } else {
      return false;
    }
  }

  String buttonTitle() {
    return "";
  }

  bool isValidated() {
    return false;
  }
}

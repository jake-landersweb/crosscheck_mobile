import 'package:crosscheck_sports/client/root.dart';
import 'package:crosscheck_sports/crosscheck_engine.dart';
import 'package:crosscheck_sports/data/root.dart';
import 'package:crosscheck_sports/extras/extensions.dart';
import 'package:crosscheck_sports/views/root.dart';
import 'package:crosscheck_sports/views/team/tce/image_uploader.dart';
import 'package:crosscheck_sports/views/team/tce/tce_root.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:crosscheck_sports/custom_views/root.dart' as cv;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TeamModel extends StatefulWidget {
  const TeamModel({
    super.key,
    required this.team,
  });
  final Team team;

  @override
  State<TeamModel> createState() => _TeamModelState();
}

class _TeamModelState extends State<TeamModel> {
  @override
  Widget build(BuildContext context) {
    var dmodel = Provider.of<DataModel>(context);
    return cv.Sheet(
      title: "",
      color: dmodel.color,
      child: ListView(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        children: [
          Row(
            children: [
              if (dmodel.currentSeasonUser?.isTeamAdmin() ??
                  dmodel.tus!.user.isTeamAdmin())
                cv.BasicButton(
                  onTap: () {
                    cv.cupertinoSheet(
                      context: context,
                      builder: (context) => ImageUploader(
                        team: widget.team,
                        imgIsUrl: widget.team.image.contains(
                            "https://crosscheck-sports.s3.amazonaws.com"),
                        onImageChange: (img) {
                          setState(() {
                            widget.team.image = img;
                            dmodel.tus!.team.image = img;
                          });
                        },
                      ),
                    );
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      TeamLogo(
                        url: widget.team.image,
                        size: 50,
                        color: dmodel.color,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Icon(
                          Icons.add_a_photo_outlined,
                          color:
                              CustomColors.textColor(context).withOpacity(0.5),
                          size: 24,
                        ),
                      )
                    ],
                  ),
                )
              else
                TeamLogo(
                  url: widget.team.image,
                  size: 50,
                  color: dmodel.color,
                ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.team.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
              ),
            ],
          ),
          if (dmodel.currentSeasonUser?.isTeamAdmin() ??
              dmodel.tus!.user.isTeamAdmin())
            Column(
              children: [
                const SizedBox(height: 16),
                cv.BasicButton(
                  onTap: () async {
                    Navigator.of(context).pop();
                    await Future.delayed(const Duration(milliseconds: 500));
                    cv.cupertinoSheet(
                      context: context,
                      builder: (context) => TCERoot(
                        user: dmodel.user!,
                        team: widget.team,
                        isCreate: false,
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: CustomColors.cellColor(context),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: dmodel.color,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.all(4),
                              child: Icon(Icons.edit_rounded,
                                  size: 20, color: Colors.white),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "Edit Team",
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: CustomColors.textColor(context),
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          cv.Section(
            "My Teams",
            child: cv.ListView(
              color: dmodel.color,
              horizontalPadding: 0,
              children: dmodel.user!.teams.map((e) => e.title).toList(),
              childBuilder: (context, String item) {
                return Text(
                  item,
                  style: TextStyle(
                    fontWeight: item == dmodel.tus?.team.title
                        ? FontWeight.w500
                        : FontWeight.w400,
                    fontSize: 18,
                    color: item == dmodel.tus?.team.title
                        ? dmodel.color
                        : CustomColors.textColor(context),
                  ),
                );
              },
              allowsSelect: true,
              selected: [dmodel.tus?.team.title ?? ""],
              onSelect: (String item) {
                // change the team to the selected team in prefs
                _changeTeam(
                  context,
                  dmodel.user!.teams
                      .firstWhere((element) => element.title == item)
                      .teamId,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _changeTeam(BuildContext context, String teamId) async {
    await FirebaseAnalytics.instance.logEvent(
      name: "team_change",
      parameters: {"platform": "mobile"},
    );
    var prefs = await SharedPreferences.getInstance();
    prefs.setString("teamId", teamId);
    RestartWidget.restartApp(context);
  }
}

import 'package:crosscheck_sports/client/root.dart';
import 'package:crosscheck_sports/data/indicator_item.dart';
import 'package:crosscheck_sports/data/root.dart';
import 'package:crosscheck_sports/data/roster/roster_group.dart';
import 'package:crosscheck_sports/extras/root.dart';
import 'package:crosscheck_sports/views/root.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:provider/provider.dart';
import 'package:sprung/sprung.dart';
import 'root.dart';
import 'package:crosscheck_sports/custom_views/root.dart' as cv;

class PollsUsers extends StatefulWidget {
  const PollsUsers({Key? key}) : super(key: key);

  @override
  State<PollsUsers> createState() => _PollsUsersState();
}

class _PollsUsersState extends State<PollsUsers> {
  RosterGroup? _rg;

  @override
  Widget build(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    PollsModel pmodel = Provider.of<PollsModel>(context);
    return ListView(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      children: [
        _users(context, dmodel, pmodel),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _users(BuildContext context, DataModel dmodel, PollsModel pmodel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          cv.Section(
            "Roster Group",
            child: cv.ListAppearance(
              onTap: () {
                cv.showFloatingSheet(
                    context: context,
                    builder: (context) {
                      return cv.Sheet(
                        title: "Roster Groups",
                        color: dmodel.color,
                        child: RosterGroups(
                          team: pmodel.team,
                          season: pmodel.season,
                          seasonRoster: pmodel.users,
                          hasAppBar: false,
                          animateOnAppear: true,
                          loadingOverride: Center(
                            child: cv.LoadingIndicator(color: dmodel.color),
                          ),
                          onSelect: (rg) {
                            pmodel.addUsers = [];
                            for (var i in rg.ids) {
                              SeasonUser su = pmodel.users.firstWhere(
                                  (element) => element.email == i,
                                  orElse: () => SeasonUser.empty());
                              if (su.email.isNotEmpty) {
                                pmodel.addUsers.add(su);
                              }
                            }
                            _rg = rg;
                            setState(() {});
                            Navigator.of(context).pop();
                          },
                        ),
                      );
                    });
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_rg != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _rg!.getIcon(32),
                    ),
                  Text(
                    _rg == null ? "Select:" : _rg!.title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: CustomColors.textColor(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
          cv.Section(
            "Select Users",
            child: cv.ListView<SeasonUser>(
              children: sortSeasonUsers(pmodel.users,
                  showNicknames: pmodel.team.showNicknames)
                ..sort((a, b) {
                  if (b.seasonFields!.isSub) {
                    return 1;
                  } else {
                    return -1;
                  }
                }),
              allowsSelect: true,
              horizontalPadding: 0,
              color: dmodel.color,
              selected: pmodel.addUsers,
              childPadding: const EdgeInsets.all(8),
              onSelect: (user) {
                if (pmodel.addUsers
                    .any((element) => element.email == user.email)) {
                  // remove the user from the add list
                  setState(() {
                    pmodel.addUsers
                        .removeWhere((element) => element.email == user.email);
                  });
                } else {
                  // add to add list
                  setState(() {
                    pmodel.addUsers.add(user);
                  });
                }
              },
              childBuilder: (context, user) {
                return Row(
                  children: [
                    RosterAvatar(
                        name: user.name(pmodel.team.showNicknames),
                        size: 50,
                        seed: user.email),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        user.name(pmodel.team.showNicknames),
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                          color: CustomColors.textColor(context),
                        ),
                      ),
                    ),
                    if (user.seasonFields!.isSub)
                      const Text(
                        "sub",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    if (user.seasonFields!.seasonUserStatus == -1)
                      const Text(
                        "inactive",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

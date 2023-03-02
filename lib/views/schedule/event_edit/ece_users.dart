import 'package:crosscheck_sports/data/root.dart';
import 'package:crosscheck_sports/data/roster/roster_group.dart';
import 'package:flutter/material.dart';
import 'package:crosscheck_sports/extras/root.dart';
import 'package:crosscheck_sports/views/root.dart';
import 'root.dart';
import '../../../client/root.dart';
import 'package:provider/provider.dart';
import '../../../custom_views/root.dart' as cv;

class ECEUsers extends StatefulWidget {
  const ECEUsers({Key? key}) : super(key: key);

  @override
  _ECEUsersState createState() => _ECEUsersState();
}

class _ECEUsersState extends State<ECEUsers> {
  RosterGroup? _rg;

  @override
  Widget build(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    ECEModel ecemodel = Provider.of<ECEModel>(context);
    return ListView(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      children: [
        if (ecemodel.event.hasAttendance) _users(context, dmodel, ecemodel),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _users(BuildContext context, DataModel dmodel, ECEModel ecemodel) {
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
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: RosterGroups(
                          team: ecemodel.team!,
                          season: ecemodel.season,
                          seasonRoster: ecemodel.users,
                          hasAppBar: false,
                          animateOnAppear: true,
                          loadingOverride: Center(
                            child: cv.LoadingIndicator(color: dmodel.color),
                          ),
                          onSelect: (rg) {
                            ecemodel.addUsers = [];
                            for (var i in rg.ids) {
                              SeasonUser su = ecemodel.users.firstWhere(
                                  (element) => element.email == i,
                                  orElse: () => SeasonUser.empty());
                              if (su.email.isNotEmpty) {
                                ecemodel.addUsers.add(su);
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
              children: sortSeasonUsers(
                ecemodel.users,
                showNicknames: dmodel.tus!.team.showNicknames,
              )..sort((a, b) {
                  if (b.seasonFields!.isSub) {
                    return 1;
                  } else {
                    return -1;
                  }
                }),
              allowsSelect: true,
              horizontalPadding: 0,
              color: dmodel.color,
              selected: ecemodel.addUsers,
              childPadding: const EdgeInsets.all(8),
              onSelect: (user) {
                if (ecemodel.addUsers
                    .any((element) => element.email == user.email)) {
                  // remove the user from the add list
                  setState(() {
                    ecemodel.addUsers
                        .removeWhere((element) => element.email == user.email);
                  });
                } else {
                  // add to add list
                  setState(() {
                    ecemodel.addUsers.add(user);
                  });
                }
              },
              childBuilder: (context, user) {
                return Row(
                  children: [
                    RosterAvatar(
                        name: user.name(ecemodel.team!.showNicknames),
                        size: 50,
                        seed: user.email),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        user.name(ecemodel.team!.showNicknames),
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

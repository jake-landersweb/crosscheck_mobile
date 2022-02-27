import 'package:flutter/material.dart';
import 'package:pnflutter/extras/root.dart';
import 'package:pnflutter/views/root.dart';
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
  @override
  Widget build(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    ECEModel ecemodel = Provider.of<ECEModel>(context);
    return ListView(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      children: [
        _users(context, dmodel, ecemodel),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _users(BuildContext context, DataModel dmodel, ECEModel ecemodel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          // subs to add
          cv.Section(
            "Select Users",
            child: RosterList(
              users: ecemodel.users
                ..sort((a, b) {
                  if (b.seasonFields!.isSub) {
                    return 1;
                  } else {
                    return -1;
                  }
                }),
              team: ecemodel.team!,
              type: RosterListType.selector,
              selected: ecemodel.addUsers,
              color: dmodel.color,
              cellBuilder: (context, user, isSelected) {
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
                    const SizedBox(width: 4),
                    (isSelected)
                        ? Icon(Icons.check_circle, color: dmodel.color)
                        : const Icon(Icons.circle_outlined),
                  ],
                );
              },
              onSelect: (user) {
                if (ecemodel.addUsers
                    .any((element) => element.email == user.email)) {
                  // remove the user from the add list
                  ecemodel.addUsers
                      .removeWhere((element) => element.email == user.email);
                } else {
                  // add to add list
                  ecemodel.addUsers.add(user);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

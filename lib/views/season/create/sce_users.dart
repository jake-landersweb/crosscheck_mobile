import 'package:flutter/material.dart';
import 'package:pnflutter/client/api_helpers.dart';
import 'package:pnflutter/views/root.dart';
import 'package:pnflutter/views/season/create/sce_model.dart';
import 'package:pnflutter/views/season/create/sce_customf.dart';
import 'package:pnflutter/views/shared/positions_create.dart';
import 'package:provider/provider.dart';
import '../../../client/root.dart';
import '../../../data/root.dart';
import '../../../extras/root.dart';
import '../../menu/root.dart';
import '../../../custom_views/root.dart' as cv;
import 'package:flutter_switch/flutter_switch.dart';
import '../../shared/root.dart';

class SCEUsers extends StatefulWidget {
  const SCEUsers({
    Key? key,
    required this.team,
  }) : super(key: key);
  final Team team;

  @override
  _SCEUsersState createState() => _SCEUsersState();
}

class _SCEUsersState extends State<SCEUsers> {
  @override
  Widget build(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    SCEModel scemodel = Provider.of<SCEModel>(context);
    return ListView(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      children: [
        const SizedBox(height: 16),
        _selectTeamUser(context, dmodel, scemodel),
        const SizedBox(height: 16),
        _teamUsers(context, dmodel, scemodel),
        const SizedBox(height: 48),
      ],
    );
  }

  Widget _selectTeamUser(
      BuildContext context, DataModel dmodel, SCEModel scemodel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: cv.RoundedLabel(
        "Full Team Roster",
        color: CustomColors.cellColor(context),
        textColor: CustomColors.textColor(context).withOpacity(0.7),
        isNavigator: true,
        onTap: () {
          cv.Navigate(
            context,
            FullTeamRoster(
              team: widget.team,
              allowSelect: true,
              onSelection: (user) {
                if (scemodel.teamUsers
                    .any((element) => element.email == user.email)) {
                  setState(() {
                    scemodel.teamUsers
                        .removeWhere((element) => element.email == user.email);
                  });
                } else {
                  setState(() {
                    scemodel.teamUsers.add(user);
                  });
                }
              },
              childBuilder: (user) {
                return Stack(
                  alignment: AlignmentDirectional.centerEnd,
                  children: [
                    UserCell(
                      user: user,
                      isClickable: false,
                      season: Season.empty(),
                    ),
                    Icon(
                      scemodel.teamUsers
                              .any((element) => element.email == user.email)
                          ? Icons.radio_button_checked
                          : Icons.circle,
                      color: scemodel.teamUsers
                              .any((element) => element.email == user.email)
                          ? dmodel.color
                          : null,
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _teamUsers(BuildContext context, DataModel dmodel, SCEModel scemodel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: scemodel.teamUsers.isEmpty
          ? Container()
          : cv.Section(
              "Team Users",
              child: cv.NativeList(
                children: [
                  cv.AnimatedList<SeasonUser>(
                    childPadding: EdgeInsets.zero,
                    padding: EdgeInsets.zero,
                    enabled: false,
                    children: scemodel.teamUsers,
                    cellBuilder: (context, item) {
                      return cv.BasicButton(
                        onTap: () {
                          setState(() {
                            scemodel.teamUsers.removeWhere(
                                (element) => element.email == item.email);
                          });
                        },
                        child: Stack(
                          alignment: AlignmentDirectional.centerEnd,
                          children: [
                            UserCell(
                              user: item,
                              isClickable: false,
                              season: Season.empty(),
                            ),
                            Icon(Icons.radio_button_checked,
                                color: dmodel.color),
                          ],
                        ),
                      );
                    },
                  )
                ],
              ),
            ),
    );
  }

  // Future<void> _create(BuildContext context, DataModel dmodel) async {
  //   List<String> teamUserEmails = [];

  //   // create email list
  //   for (var i in scemodel.teamUsers) {
  //     teamUserEmails.add(i.email);
  //   }

  //   Map<String, dynamic> body = {
  //     "title": widget.model.title,
  //     "website": widget.model.website,
  //     "seasonNote": widget.model.seasonNote,
  //     "showNicknames": widget.model.showNicknames,
  //     "customFields": widget.model.customFields.map((e) => e.toJson()).toList(),
  //     "positions": widget.model.positions.toJson(),
  //     "teamUserEmails": teamUserEmails,
  //     "date": dateToString(DateTime.now()),
  //     "customUserFields":
  //         widget.model.customUserFields.map((e) => e.toJson()).toList(),
  //     "stats": widget.model.stats.toJson(),
  //   };

  //   print(body);

  //   await dmodel.createSeason(widget.team.teamId, body, () {
  //     // success, get out of widget
  //     Navigator.of(context).pop();
  //     Navigator.of(context).pop();
  //     Navigator.of(context).pop();
  //     Navigator.of(context).pop();
  //     if (widget.model.isCreate) {
  //       Navigator.of(context).pop();
  //     }
  //     // get tus
  //     dmodel.teamUserSeasonsGet(widget.team.teamId, dmodel.user!.email, (tus) {
  //       dmodel.setTUS(tus);
  //     });
  //   });
  // }
}

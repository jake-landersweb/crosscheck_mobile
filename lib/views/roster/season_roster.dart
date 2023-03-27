import 'package:crosscheck_sports/views/roster/from_excel/su_excel_root.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:crosscheck_sports/client/root.dart';
import 'package:crosscheck_sports/data/root.dart';
import 'package:crosscheck_sports/views/root.dart';
import 'package:provider/provider.dart';
import 'package:crosscheck_sports/extras/root.dart';
import '../../custom_views/root.dart' as cv;
import 'dart:math' as math;

class SeasonRoster extends StatefulWidget {
  const SeasonRoster({Key? key}) : super(key: key);

  @override
  _SeasonRosterState createState() => _SeasonRosterState();
}

class _SeasonRosterState extends State<SeasonRoster> {
  @override
  void initState() {
    _checkSeasonRoster(context, context.read<DataModel>());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    return cv.AppBar(
      title: "Roster",
      isLarge: true,
      refreshable: true,
      backgroundColor: CustomColors.backgroundColor(context),
      color: dmodel.color,
      childPadding: const EdgeInsets.fromLTRB(16, 0, 16, 48),
      itemBarPadding: const EdgeInsets.fromLTRB(8, 0, 16, 8),
      leading: [cv.BackButton(color: dmodel.color)],
      trailing: [_createUser(context, dmodel)],
      onRefresh: () async {
        await dmodel.getBatchSeasonRoster(
          dmodel.tus!.team.teamId,
          dmodel.currentSeason!.seasonId,
          (p0) => dmodel.setSeasonUsers(p0),
        );
      },
      children: [
        if (dmodel.seasonUsers != null)
          ChangeNotifierProvider<RosterSorting>(
            create: (_) => RosterSorting(
              team: dmodel.tus!.team,
              season: dmodel.currentSeason!,
            ),
            // we use `builder` to obtain a new `BuildContext` that has access to the provider
            builder: (context, child) {
              // No longer throws
              return _body(context, dmodel);
            },
          )
        else
          const RosterLoading(),
      ],
    );
  }

  Widget _body(BuildContext context, DataModel dmodel) {
    RosterSorting smodel = Provider.of<RosterSorting>(context);
    return Column(
      children: [
        smodel.header(context, dmodel),
        const SizedBox(height: 8),
        if ((dmodel.tus?.user.isTeamAdmin() ?? false) ||
            (dmodel.currentSeasonUser?.isSeasonAdmin() ?? false))
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: cv.BasicButton(
              onTap: () {
                if (dmodel.seasonUsers != null) {
                  cv.Navigate(
                    context,
                    RosterGroups(
                      team: dmodel.tus!.team,
                      season: dmodel.currentSeason!,
                      seasonRoster: dmodel.seasonUsers!,
                    ),
                  );
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: CustomColors.cellColor(context),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 50),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 8, 0),
                      child: Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.purple,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.all(4),
                              child: Icon(
                                Icons.group_rounded,
                                size: 20,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              "Roster Groups",
                              style: TextStyle(
                                fontSize: 18,
                                color: CustomColors.textColor(context),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.chevron_right_rounded,
                            color: CustomColors.textColor(context)
                                .withOpacity(0.5),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        if (dmodel.currentSeasonUser?.isSeasonAdmin() ??
            dmodel.tus!.user.isTeamAdmin())
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: cv.ListView<_RosterCreateObject>(
              horizontalPadding: 0,
              childPadding: const EdgeInsets.fromLTRB(16, 0, 8, 0),
              onChildTap: ((context, item) {
                cv.cupertinoSheet(
                  context: context,
                  wrapInNavigator: item.wrapInNavigator,
                  builder: (context) {
                    return item.child;
                  },
                );
              }),
              childBuilder: ((context, item) {
                return ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 50),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: item.color,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Icon(item.icon, size: 20, color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          item.title,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: CustomColors.textColor(context),
                          ),
                        ),
                      ),
                      Transform.rotate(
                        angle: -math.pi / 2,
                        child: Icon(
                          Icons.chevron_right_rounded,
                          color:
                              CustomColors.textColor(context).withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              children: [
                _RosterCreateObject(
                  title: "Create New User",
                  icon: Icons.person_add_rounded,
                  color: Colors.blue,
                  child: RUCERoot(
                    team: dmodel.tus!.team,
                    season: dmodel.currentSeason!,
                    isSheet: true,
                    isCreate: true,
                    useRoot: true,
                    onFunction: (body) async {
                      // create the season user
                      await dmodel.seasonUserAdd(
                        dmodel.tus!.team.teamId,
                        dmodel.currentSeason!.seasonId,
                        body,
                        (seasonUser) async {
                          // add the user to this list
                          Navigator.of(context, rootNavigator: true).pop();
                          // refresh the data
                          await dmodel.refreshData(dmodel.user!.email);
                        },
                      );
                    },
                  ),
                ),
                _RosterCreateObject(
                  title: "Add Users From Team",
                  color: Colors.orange,
                  icon: Icons.group_add_rounded,
                  wrapInNavigator: true,
                  child: FTRoot(
                    team: dmodel.tus!.team,
                    season: dmodel.currentSeason!,
                    onCompletion: (teamId, seasonId, body) async {
                      await dmodel.seasonUserAddFromList(
                        teamId,
                        seasonId,
                        body,
                        () async {
                          Navigator.of(context, rootNavigator: true).pop();
                          // refresh the data
                          await dmodel.refreshData(dmodel.user!.email);
                        },
                      );
                      // add the user to this list
                    },
                  ),
                ),
                _RosterCreateObject(
                  title: "Add Users From Seasons",
                  color: Colors.red,
                  icon: Icons.content_paste_search_rounded,
                  wrapInNavigator: true,
                  child: FSRoot(
                    team: dmodel.tus!.team,
                    seasonRoster: dmodel.seasonUsers!,
                    season: dmodel.currentSeason!,
                  ),
                ),
                _RosterCreateObject(
                  title: "Add Users From Excel",
                  color: Colors.green,
                  icon: Icons.newspaper_rounded,
                  child: SUFromExcel(
                    positions: dmodel.currentSeason!.positions.available,
                    onCreate: (users) async {
                      bool v = false;
                      await dmodel.uploadRosterExcel(dmodel.tus!.team.teamId,
                          dmodel.currentSeason!.seasonId, users, () {
                        v = true;
                      }, onError: () {
                        v = false;
                      });
                      await dmodel.refreshData(dmodel.user!.email);
                      return v;
                    },
                    onDispose: () {
                      dmodel.blockRefresh = false;
                    },
                  ),
                ),
              ],
            ),
          ),
        // filtering toggle
        _rosterList(
          context,
          dmodel,
          _active(context, dmodel, smodel),
          smodel,
        ),
        if (_invited(context, dmodel, smodel).isNotEmpty)
          cv.Section(
            "Invited",
            child: _rosterList(
              context,
              dmodel,
              _invited(context, dmodel, smodel),
              smodel,
            ),
          ),
        if (_notValidated(context, dmodel, smodel).isNotEmpty)
          cv.Section(
            "Not Validated",
            child: _rosterList(
              context,
              dmodel,
              _notValidated(context, dmodel, smodel),
              smodel,
            ),
          )
      ],
    );
  }

  Widget _rosterList(BuildContext context, DataModel dmodel,
      List<SeasonUser> users, RosterSorting smodel) {
    return RosterList(
      users: users,
      team: dmodel.tus!.team,
      type: RosterListType.navigator,
      isMVP: (seasonUser) {
        return dmodel.currentSeason!.positions.mvp ==
            seasonUser.seasonFields!.pos;
      },
      cellBuilder: (context, i, isSelected) {
        return RosterCell(
          name: i.name(dmodel.tus!.team.showNicknames),
          seed: i.email,
          padding: EdgeInsets.zero,
          type: RosterListType.none,
          color: dmodel.color,
          isSelected: isSelected,
          trailingWidget: _trailingWidget(context, i, smodel),
        );
      },
      onNavigate: (user) {
        cv.Navigate(
          context,
          RosterUserDetail(
            team: dmodel.tus!.team,
            season: dmodel.currentSeason!,
            seasonUser: user,
            teamUser: dmodel.tus!.user,
            appSeasonUser: dmodel.currentSeasonUser,
            isTeam: false,
            onDelete: () async {
              setState(() {
                dmodel.seasonUsers = null;
                print("Hey");
              });
              _checkSeasonRoster(context, dmodel);
            },
            onUserEdit: (body) async {
              await dmodel.seasonUserUpdate(
                dmodel.tus!.team.teamId,
                dmodel.currentSeason!.seasonId,
                user.email,
                body,
                () async {
                  setState(() {
                    dmodel.isScaled = false;
                  });
                  Navigator.of(context, rootNavigator: true).pop();
                  Navigator.of(context, rootNavigator: true).pop();
                  // get latest season roster data
                  setState(() {
                    dmodel.seasonUsers = null;
                  });
                  await dmodel.getBatchSeasonRoster(
                    dmodel.tus!.team.teamId,
                    dmodel.currentSeason!.seasonId,
                    (p0) => dmodel.setSeasonUsers(p0),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget _trailingWidget(
      BuildContext context, SeasonUser user, RosterSorting smodel) {
    if (smodel.sortCF != null) {
      String val = user.seasonFields!.customFields
          .firstWhere(
              (element) => element.getTitle() == smodel.sortCF!.getTitle())
          .getValue();
      return Text(val);
    } else {
      return const Icon(Icons.chevron_right_rounded);
    }
  }

  List<SeasonUser> _active(
      BuildContext context, DataModel dmodel, RosterSorting smodel) {
    return smodel
        .users(dmodel.seasonUsers!,
            showNicknames: dmodel.tus!.team.showNicknames)
        .where((element) => element.teamFields!.validationStatus == 1)
        .toList();
  }

  List<SeasonUser> _notValidated(
      BuildContext context, DataModel dmodel, RosterSorting smodel) {
    return smodel
        .users(dmodel.seasonUsers!,
            showNicknames: dmodel.tus!.team.showNicknames)
        .where((element) => element.teamFields!.validationStatus == 0)
        .toList();
  }

  List<SeasonUser> _invited(
      BuildContext context, DataModel dmodel, RosterSorting smodel) {
    return smodel
        .users(dmodel.seasonUsers!,
            showNicknames: dmodel.tus!.team.showNicknames)
        .where((element) => element.teamFields!.validationStatus == 2)
        .toList();
  }

  Widget _createUser(BuildContext context, DataModel dmodel) {
    if (dmodel.seasonUsers == null) {
      return Container();
    } else {
      return Row(
        children: [
          cv.BasicButton(
            onTap: () {
              cv.cupertinoSheet(
                  context: context,
                  builder: (context) {
                    return BasicNotification(
                      team: dmodel.tus!.team,
                      users: dmodel.seasonUsers!,
                    );
                  });
            },
            child: Icon(Icons.mail_outline_rounded, color: dmodel.color),
          ),
        ],
      );
    }
  }

  Future<void> _checkSeasonRoster(
      BuildContext context, DataModel dmodel) async {
    if (dmodel.seasonUsers == null) {
      await dmodel.getBatchSeasonRoster(
        dmodel.tus!.team.teamId,
        dmodel.currentSeason!.seasonId,
        (p0) => dmodel.setSeasonUsers(p0),
      );
    }
  }
}

class _RosterCreateObject {
  final String title;
  final IconData icon;
  final Color color;
  final Widget child;
  final bool wrapInNavigator;

  const _RosterCreateObject({
    required this.title,
    required this.icon,
    required this.color,
    required this.child,
    this.wrapInNavigator = false,
  });
}

// class SeasonUserAdd extends StatefulWidget {
//   const SeasonUserAdd({
//     Key? key,
//     required this.team,
//     required this.teamUser,
//     required this.season,
//     required this.seasonUser,
//   }) : super(key: key);
//   final Team team;
//   final SeasonUserTeamFields teamUser;
//   final Season season;
//   final SeasonUser seasonUser;

//   @override
//   _SeasonUserAddState createState() => _SeasonUserAddState();
// }

// class _SeasonUserAddState extends State<SeasonUserAdd> {
//   List<SeasonUser> _selectedTeamUsers = [];

//   bool _isLoading = false;

//   @override
//   Widget build(BuildContext context) {
//     DataModel dmodel = Provider.of<DataModel>(context);
//     return cv.AppBar(
//       title: "Add User",
//       isLarge: true,
//       refreshable: false,
//       backgroundColor: CustomColors.backgroundColor(context),
//       color: dmodel.color,
//       leading: [
//         cv.BackButton(
//           color: dmodel.color,
//           showIcon: false,
//           showText: true,
//           title: "Cancel",
//         ),
//       ],
//       children: [
//         cv.Section(
//           "New User",
//           child: cv.RoundedLabel(
//             "Create User",
//             color: CustomColors.cellColor(context),
//             textColor: CustomColors.textColor(context),
//             isNavigator: true,
//             onTap: () => cv.Navigate(
//               context,
//               _newUser(context, dmodel),
//             ),
//           ),
//         ),
//         const SizedBox(height: 16),
//         cv.Section(
//           "Existing Users",
//           child: cv.RoundedLabel(
//             "Team Roster List",
//             color: CustomColors.cellColor(context),
//             textColor: CustomColors.textColor(context),
//             isNavigator: true,
//             onTap: () => cv.Navigate(context, _existingList(context, dmodel)),
//           ),
//         ),
//         const SizedBox(height: 16),
//         if (_selectedTeamUsers.isNotEmpty)
//           cv.Section(
//             "Selected Users",
//             child: Column(
//               children: [
//                 cv.ListView<SeasonUser>(
//                   children: _selectedTeamUsers,
//                   horizontalPadding: 0,
//                   childPadding: const EdgeInsets.all(8),
//                   isAnimated: true,
//                   allowsDelete: true,
//                   onDelete: (user) {
//                     setState(() {
//                       _selectedTeamUsers.removeWhere(
//                           (element) => element.email == user.email);
//                     });
//                   },
//                   childBuilder: (context, user) {
//                     return RosterCell(
//                       name: user.name(widget.team.showNicknames),
//                       type: RosterListType.none,
//                       color: dmodel.color,
//                       isSelected: false,
//                       padding: EdgeInsets.zero,
//                       seed: user.email,
//                     );
//                   },
//                 ),
//                 const SizedBox(height: 16),
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 16),
//                   child: cv.RoundedLabel(
//                     "Add Users",
//                     color: dmodel.color,
//                     textColor: Colors.white,
//                     onTap: () {
//                       if (!_isLoading && _selectedTeamUsers.isNotEmpty) {
//                         _addUserList(context, dmodel);
//                       }
//                     },
//                     isLoading: _isLoading,
//                   ),
//                 )
//               ],
//             ),
//           ),
//       ],
//     );
//   }

//   Widget _newUser(BuildContext context, DataModel dmodel) {
//     return RUCERoot(
//       team: widget.team,
//       season: widget.season,
//       isCreate: true,
//       onFunction: (body) async {
//         // create the season user
//         await dmodel
//             .seasonUserAdd(widget.team.teamId, widget.season.seasonId, body,
//                 (seasonUser) async {
//           // add the user to this list
//           Navigator.of(context).pop();
//           Navigator.of(context).pop();
//           setState(() {
//             dmodel.seasonUsers!.add(seasonUser);
//           });
//           // refresh the data
//           await dmodel.reloadHomePage(widget.team.teamId,
//               widget.season.seasonId, dmodel.user!.email, false);
//         });
//       },
//     );
//   }

//   Widget _existingList(BuildContext context, DataModel dmodel) {
//     return _AddTeamUsers(
//       selected: _selectedTeamUsers,
//       onSelect: (user) {
//         if (_selectedTeamUsers.any((element) => element.email == user.email)) {
//           setState(() {
//             _selectedTeamUsers
//                 .removeWhere((element) => element.email == user.email);
//           });
//         } else {
//           setState(() {
//             _selectedTeamUsers.add(user);
//           });
//         }
//       },
//       team: widget.team,
//       season: widget.season,
//     );
//   }

//   Future<void> _addUserList(BuildContext context, DataModel dmodel) async {
//     setState(() {
//       _isLoading = true;
//     });
//     Map<String, dynamic> body = {
//       "emailList": _selectedTeamUsers.map((e) => e.email).toList(),
//       "date": dateToString(DateTime.now()),
//     };
//     await dmodel.addTeamUserEmailList(
//         widget.team.teamId, widget.season.seasonId, body, () async {
//       // fetch new season roster
//       setState(() {
//         dmodel.seasonUsers = null;
//       });
//       await dmodel.getBatchSeasonRoster(
//           widget.team.teamId, widget.season.seasonId, (p0) {
//         setState(() {
//           dmodel.setSeasonUsers(p0);
//         });
//         Navigator.of(context).pop();
//       });
//       // refresh the data
//       await dmodel.reloadHomePage(widget.team.teamId, widget.season.seasonId,
//           dmodel.user!.email, false);
//     });
//     setState(() {
//       _isLoading = false;
//     });
//   }
// }

// class _AddTeamUsers extends StatefulWidget {
//   const _AddTeamUsers({
//     Key? key,
//     required this.selected,
//     required this.onSelect,
//     required this.team,
//     required this.season,
//   }) : super(key: key);
//   final List<SeasonUser> selected;
//   final Function(SeasonUser) onSelect;
//   final Team team;
//   final Season season;

//   @override
//   __AddTeamUsersState createState() => __AddTeamUsersState();
// }

// class __AddTeamUsersState extends State<_AddTeamUsers> {
//   bool _isLoading = false;
//   List<SeasonUser>? _users;

//   @override
//   void initState() {
//     super.initState();
//     _fetchUsers(context, context.read<DataModel>());
//   }

//   @override
//   void dispose() {
//     _users = null;
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     DataModel dmodel = Provider.of<DataModel>(context);
//     return cv.AppBar(
//       title: "Team Roster",
//       isLarge: true,
//       refreshable: false,
//       backgroundColor: CustomColors.backgroundColor(context),
//       color: dmodel.color,
//       itemBarPadding: const EdgeInsets.fromLTRB(8, 0, 15, 8),
//       leading: [cv.BackButton(color: dmodel.color)],
//       children: [
//         if (_isLoading)
//           const RosterLoading()
//         else if (_users != null)
//           RosterList(
//             users: _users!
//                 .where((e1) =>
//                     !dmodel.seasonUsers!.any((e2) => e1.email == e2.email))
//                 .toList(),
//             isMVP: (seasonUser) {
//               return dmodel.tus!.team.positions.mvp ==
//                   seasonUser.teamFields!.pos;
//             },
//             team: dmodel.tus!.team,
//             type: RosterListType.selector,
//             color: dmodel.color,
//             selected: widget.selected,
//             onSelect: (user) {
//               setState(() {
//                 widget.onSelect(user);
//               });
//             },
//           ),
//       ],
//     );
//   }

//   Future<void> _fetchUsers(BuildContext context, DataModel dmodel) async {
//     setState(() {
//       _isLoading = true;
//     });

//     await dmodel.getTeamRoster(widget.team.teamId, (users) {
//       setState(() {
//         _users = users;
//       });
//     });

//     setState(() {
//       _isLoading = false;
//     });
//   }
// }

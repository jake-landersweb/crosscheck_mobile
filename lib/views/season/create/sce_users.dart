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
    required this.model,
    required this.team,
  }) : super(key: key);
  final SCEModel model;
  final Team team;

  @override
  _SCEUsersState createState() => _SCEUsersState();
}

class _SCEUsersState extends State<SCEUsers> {
  @override
  void initState() {
    widget.model.index += 1;
    super.initState();
  }

  @override
  void dispose() {
    widget.model.index -= 1;
    super.dispose();
  }

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    return Stack(
      alignment: AlignmentDirectional.bottomCenter,
      children: [
        cv.AppBar(
          title: "Add Users",
          isLarge: false,
          backgroundColor: CustomColors.backgroundColor(context),
          childPadding: const EdgeInsets.fromLTRB(0, 15, 0, 45),
          itemBarPadding: const EdgeInsets.fromLTRB(8, 0, 15, 8),
          leading: [cv.BackButton(color: dmodel.color)],
          color: dmodel.color,
          children: [_body(context, dmodel)],
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 48.0),
          child: _createButton(context, dmodel),
        ),
      ],
    );
  }

  Widget _body(BuildContext context, DataModel dmodel) {
    return Column(
      children: [
        widget.model.status(context, dmodel),
        const SizedBox(height: 16),
        _selectTeamUser(context, dmodel),
        const SizedBox(height: 16),
        _teamUsers(context, dmodel),
        const SizedBox(height: 48),
      ],
    );
  }

  Widget _selectTeamUser(BuildContext context, DataModel dmodel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: cv.BasicButton(
        onTap: () {
          cv.Navigate(
            context,
            FullTeamRoster(
              team: widget.team,
              allowSelect: true,
              onSelection: (user) {
                if (widget.model.teamUsers
                    .any((element) => element.email == user.email)) {
                  setState(() {
                    widget.model.teamUsers
                        .removeWhere((element) => element.email == user.email);
                  });
                } else {
                  setState(() {
                    widget.model.teamUsers.add(user);
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
                      widget.model.teamUsers
                              .any((element) => element.email == user.email)
                          ? Icons.radio_button_checked
                          : Icons.circle,
                      color: widget.model.teamUsers
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
        child: cv.NativeList(
          children: [
            SizedBox(
              height: 40,
              child: Row(
                children: [
                  const Text(
                    "Select Team Users",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const Spacer(),
                  Icon(Icons.chevron_right_sharp,
                      color: CustomColors.textColor(context).withOpacity(0.5)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _teamUsers(BuildContext context, DataModel dmodel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: widget.model.teamUsers.isEmpty
          ? Container()
          : cv.Section(
              "Team Users",
              child: cv.NativeList(
                children: [
                  cv.AnimatedList<SeasonUser>(
                    childPadding: EdgeInsets.zero,
                    padding: EdgeInsets.zero,
                    enabled: false,
                    children: widget.model.teamUsers,
                    cellBuilder: (context, item) {
                      return cv.BasicButton(
                        onTap: () {
                          setState(() {
                            widget.model.teamUsers.removeWhere(
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

  Widget _createButton(BuildContext context, DataModel dmodel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: cv.BasicButton(
        onTap: () {
          _create(context, dmodel);
        },
        child: Material(
          shape: ContinuousRectangleBorder(
              borderRadius: BorderRadius.circular(35)),
          color: dmodel.color,
          child: SizedBox(
            height: cellHeight,
            child: Center(
              child: _isLoading
                  ? const cv.LoadingIndicator(color: Colors.white)
                  : const Text(
                      "Create Season",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _create(BuildContext context, DataModel dmodel) async {
    setState(() {
      _isLoading = true;
    });

    List<String> teamUserEmails = [];

    // create email list
    for (var i in widget.model.teamUsers) {
      teamUserEmails.add(i.email);
    }

    Map<String, dynamic> body = {
      "title": widget.model.title,
      "website": widget.model.website,
      "seasonNote": widget.model.seasonNote,
      "showNicknames": widget.model.showNicknames,
      "customFields": widget.model.customFields.map((e) => e.toJson()).toList(),
      "positions": widget.model.positions.toJson(),
      "teamUserEmails": teamUserEmails,
      "date": dateToString(DateTime.now()),
      "customUserFields":
          widget.model.customUserFields.map((e) => e.toJson()).toList(),
      "stats": widget.model.stats.toJson(),
    };

    await dmodel.createSeason(widget.team.teamId, body, () {
      // success, get out of widget
      Navigator.of(context).pop();
      Navigator.of(context).pop();
      Navigator.of(context).pop();
      Navigator.of(context).pop();
      if (widget.model.isCreate) {
        Navigator.of(context).pop();
      }
      // get tus
      dmodel.teamUserSeasonsGet(widget.team.teamId, dmodel.user!.email, (tus) {
        dmodel.setTUS(tus);
      });
    });
    setState(() {
      _isLoading = false;
    });
  }
}

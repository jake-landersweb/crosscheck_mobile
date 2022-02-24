import 'dart:developer';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:pnflutter/client/root.dart';
import 'package:pnflutter/data/root.dart';
import 'package:pnflutter/extras/root.dart';
import 'package:pnflutter/views/root.dart';
import 'package:provider/provider.dart';
import 'package:sprung/sprung.dart';
import '../../../custom_views/root.dart' as cv;

class TCERoot extends StatefulWidget {
  const TCERoot({
    Key? key,
    required this.user,
    required this.team,
    required this.isCreate,
  }) : super(key: key);
  final User user;
  final Team team;
  final bool isCreate;

  @override
  _TCERootState createState() => _TCERootState();
}

class _TCERootState extends State<TCERoot> {
  late PageController _controller;

  @override
  void initState() {
    _controller = PageController();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    return ChangeNotifierProvider<TCEModel>(
      create: (_) => widget.isCreate
          ? TCEModel.create(widget.user, widget.team, true)
          : TCEModel.update(widget.user, widget.team, false),
      // we use `builder` to obtain a new `BuildContext` that has access to the provider
      builder: (context, child) {
        // No longer throws
        return Stack(
          alignment: Alignment.bottomCenter,
          children: [
            cv.AppBar(
              canScroll: false,
              title: widget.isCreate ? "Create Team" : "Edit Team",
              children: [
                Expanded(
                  child: _body(context, dmodel),
                ),
              ],
              leading: [
                cv.BackButton(
                  title: "Cancel",
                  showIcon: false,
                  showText: true,
                  color: dmodel.color,
                ),
              ],
            ),
            _navigation(context, dmodel),
          ],
        );
      },
    );
  }

  Widget _body(BuildContext context, DataModel dmodel) {
    TCEModel tcemodel = Provider.of<TCEModel>(context);
    return Column(
      children: [
        Container(
          color: CustomColors.textColor(context).withOpacity(0.05),
          child: Column(children: [
            const SizedBox(height: 100),
            tcemodel.status(context, dmodel, _controller),
            const SizedBox(height: 16),
          ]),
        ),
        Expanded(
          child: PageView(
            controller: _controller,
            children: const [
              TCEBasic(),
              TCEPositions(),
              TCECUstom(),
              TCEStats(),
            ],
            onPageChanged: (page) {
              tcemodel.setIndex(page);
            },
          ),
        ),
      ],
    );
  }

  Widget _navigation(BuildContext context, DataModel dmodel) {
    TCEModel tcemodel = Provider.of<TCEModel>(context);
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
            16, 0, 16, MediaQuery.of(context).padding.bottom == 0 ? 10 : 0),
        child: Row(
          children: [
            AnimatedOpacity(
              opacity: tcemodel.index == 0 ? 0 : 1,
              duration: const Duration(milliseconds: 300),
              child: cv.BasicButton(
                onTap: () {
                  if (tcemodel.index != 0) {
                    _controller.previousPage(
                        duration: const Duration(milliseconds: 700),
                        curve: Sprung.overDamped);
                  }
                },
                child: cv.GlassContainer(
                  height: 50,
                  width: 50,
                  borderRadius: BorderRadius.circular(25),
                  backgroundColor:
                      CustomColors.textColor(context).withOpacity(0.1),
                  child: Icon(
                    Icons.chevron_left,
                    color: CustomColors.textColor(context).withOpacity(0.7),
                  ),
                ),
              ),
            ),
            const Spacer(),
            cv.BasicButton(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: 5,
                    sigmaY: 5,
                  ),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 700),
                    curve: Sprung.overDamped,
                    decoration: BoxDecoration(
                      color: tcemodel.isAtEnd() && !tcemodel.isValidated().v1()
                          ? Colors.red.withOpacity(0.3)
                          : dmodel.color,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    width: tcemodel.isAtEnd()
                        ? MediaQuery.of(context).size.width / 1.5
                        : 50,
                    height: 50,
                    child: tcemodel.isAtEnd()
                        ? Center(
                            child: _isLoading
                                ? const cv.LoadingIndicator(color: Colors.white)
                                : Text(
                                    tcemodel.isValidated().v2(),
                                    softWrap: false,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16,
                                      color: tcemodel.isValidated().v1()
                                          ? Colors.white
                                          : Colors.red[900],
                                    ),
                                  ),
                          )
                        : const Icon(
                            Icons.chevron_right,
                            color: Colors.white,
                          ),
                  ),
                ),
              ),
              onTap: () {
                if (tcemodel.isAtEnd()) {
                  if (tcemodel.isValidated().v1()) {
                    if (tcemodel.isCreate) {
                      _create(context, dmodel, tcemodel);
                    } else {
                      _update(context, dmodel, tcemodel);
                    }
                  }
                } else {
                  _controller.nextPage(
                      duration: const Duration(milliseconds: 700),
                      curve: Sprung.overDamped);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _update(
      BuildContext context, DataModel dmodel, TCEModel tcemodel) async {
    setState(() {
      _isLoading = true;
    });
    // first update the custom user fields
    Map<String, dynamic> body = {
      "color": tcemodel.team.color,
      "isLight": tcemodel.team.isLight,
      "teamNote": tcemodel.team.teamNote,
      "customFields":
          tcemodel.team.customFields.map((e) => e.toJson()).toList(),
      "positions": tcemodel.team.positions.toJson(),
      "showNicknames": tcemodel.team.showNicknames,
    };

    // determine whether to add customUserFields
    void addUserFields() {
      body['customUserFields'] =
          tcemodel.team.customUserFields.map((e) => e.toJson()).toList();
    }

    if (tcemodel.team.customUserFields.length ==
        widget.team.customUserFields.length) {
      for (var i in widget.team.customUserFields) {
        if (!tcemodel.team.customUserFields.any((element) => element == i)) {
          addUserFields();
        }
      }
    } else {
      addUserFields();
    }

    // determine whether to add stats
    void addStats() {
      body['stats'] = tcemodel.team.stats.toJson();
    }

    // check length
    if (tcemodel.team.stats.stats.length != widget.team.stats.stats.length) {
      addStats();
    } else {
      // check for new items
      for (var i in widget.team.stats.stats) {
        if (!tcemodel.team.stats.stats
            .any((element) => element.title == i.title)) {
          addStats();
        }
      }
    }

    print(body);

    await dmodel.updateTeam(widget.team.teamId, body, () {
      Navigator.of(context).pop();
      // get the new team data
      dmodel.teamUserSeasonsGet(widget.team.teamId, dmodel.user!.email, (tus) {
        dmodel.setTUS(tus);
        return;
      });
    });
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _create(
      BuildContext context, DataModel dmodel, TCEModel tcemodel) async {
    setState(() {
      _isLoading = true;
    });
    // create the body
    Map<String, dynamic> body = {
      "title": tcemodel.team.title,
      "color": tcemodel.team.color,
      "isLight": tcemodel.team.isLight,
      "teamNote": tcemodel.team.teamNote,
      "customFields":
          tcemodel.team.customFields.map((e) => e.toJson()).toList(),
      "positions": tcemodel.team.positions.toJson(),
      "showNicknames": tcemodel.team.showNicknames,
      "email": widget.user.email,
      "customUserFields":
          tcemodel.team.customUserFields.map((e) => e.toJson()).toList(),
      "stats": tcemodel.team.stats.toJson(),
    };

    // set the request
    await dmodel.createTeam(body, (team) {
      // get the team with the teamid
      dmodel.teamUserSeasonsGet(team.teamId, dmodel.user!.email, (tus) {
        dmodel.setTUS(tus);
        Navigator.of(context).pop();
      });
    });

    setState(() {
      _isLoading = false;
    });
  }
}

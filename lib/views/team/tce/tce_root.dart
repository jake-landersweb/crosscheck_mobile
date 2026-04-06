import 'package:crosscheck_sports/crosscheck_engine.dart';
import 'package:flutter/material.dart';
import 'package:crosscheck_sports/client/root.dart';
import 'package:crosscheck_sports/data/root.dart';
import 'package:crosscheck_sports/extras/root.dart';
import 'package:crosscheck_sports/views/root.dart';
import 'package:provider/provider.dart';
import 'package:sprung/sprung.dart';
import '../../../custom_views/root.dart' as cv;
import 'package:crosscheck_sports/components/layer/action_button.dart';
import 'package:crosscheck_sports/components/core/container.dart';
import 'package:crosscheck_sports/components/layer/header_bar.dart';
import 'package:crosscheck_sports/style/root.dart';

class TCERoot extends StatefulWidget {
  const TCERoot({
    super.key,
    required this.user,
    required this.team,
    required this.isCreate,
    this.useRoot = false,
  });
  final User user;
  final Team team;
  final bool isCreate;
  final bool useRoot;

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
        return Scaffold(
          backgroundColor: CustomColors.backgroundColor(context),
          body: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Column(
                children: [
                  Container(
                    color: CustomColors.textColor(context).withValues(alpha: 0.05),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      child: SizedBox(
                        height: XCThemeData.listItemHeight,
                        child: Stack(
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: XCActionButton.cancel(
                                onTap: () => Navigator.of(context, rootNavigator: true).pop(),
                              ),
                            ),
                            Center(
                              child: Text(
                                widget.isCreate ? "Create Team" : "Edit Team",
                                style: XCTheme.of(context).text.label,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(child: _body(context, dmodel)),
                ],
              ),
              _navigation(context, dmodel),
            ],
          ),
        );
      },
    );
  }

  Widget _body(BuildContext context, DataModel dmodel) {
    TCEModel tcemodel = Provider.of<TCEModel>(context);
    return Column(
      children: [
        Container(
          color: CustomColors.textColor(context).withValues(alpha: 0.05),
          child: Column(children: [
            const SizedBox(height: 8),
            tcemodel.status(context, dmodel, _controller),
            const SizedBox(height: 16),
          ]),
        ),
        Expanded(
          child: PageView(
            controller: _controller,
            children: [
              if (tcemodel.isCreate) const TCETemplate(),
              const TCEBasic(),
              const TCEPositions(),
              const TCECUstom(),
              // TCEStats(),
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
      top: false,
      left: false,
      right: false,
      bottom: true,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
            16, 0, 16, MediaQuery.of(context).padding.bottom == 0 ? 10 : 0),
        child: Row(
          children: [
            AnimatedOpacity(
              opacity: tcemodel.index == 0 ? 0 : 1,
              duration: const Duration(milliseconds: 300),
              child: XCContainer.custom(
                customRadius: 25,
                height: 50,
                width: 50,
                color: XCTheme.of(context).cell,
                onTap: () {
                  if (tcemodel.index != 0) {
                    _controller.previousPage(
                        duration: const Duration(milliseconds: 700),
                        curve: Sprung.overDamped);
                  }
                },
                child: Icon(
                  Icons.chevron_left,
                  color: XCTheme.of(context).foregroundMuted,
                ),
              ),
            ),
            const Spacer(),
            XCContainer.custom(
              customRadius: 25,
              height: 50,
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
              color: tcemodel.isAtEnd() && !tcemodel.isValidated().v1()
                  ? Colors.red.withValues(alpha: 0.3)
                  : dmodel.color,
              child: AnimatedSize(
                duration: const Duration(milliseconds: 700),
                curve: Sprung.overDamped,
                child: SizedBox(
                  width: tcemodel.isAtEnd()
                      ? MediaQuery.of(context).size.width / 1.5
                      : 50,
                  child: Center(
                    child: tcemodel.isAtEnd()
                        ? _isLoading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
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
                              )
                        : const Icon(
                            Icons.chevron_right,
                            color: Colors.white,
                          ),
                  ),
                ),
              ),
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
    };
    print(tcemodel.team.positions.mvp);

    // set the request
    await dmodel.createTeam(body, (team) {
      // get the team with the teamid
      dmodel.teamUserSeasonsGet(team.teamId, dmodel.user!.email, (tus) {
        dmodel.setTUS(tus);
        RestartWidget.restartApp(context);
      });
    });

    setState(() {
      _isLoading = false;
    });
  }
}

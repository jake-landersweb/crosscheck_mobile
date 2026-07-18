// ignore_for_file: use_build_context_synchronously

import 'package:crosscheck_sports/client/root.dart';
import 'package:crosscheck_sports/crosscheck_engine.dart';
import 'package:crosscheck_sports/data/root.dart';
import 'package:crosscheck_sports/extras/root.dart';
import 'package:crosscheck_sports/views/tsce/root.dart';
import 'package:flutter/material.dart';
import 'package:crosscheck_sports/components/layer/header_bar.dart';
import 'package:crosscheck_sports/components/layer/action_button.dart';
import 'package:crosscheck_sports/components/core/container.dart';
import 'package:crosscheck_sports/style/root.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:sprung/sprung.dart';
import 'package:crosscheck_sports/components/layer/snapping_sheet.dart';
import 'package:crosscheck_sports/components/layer/wide_button.dart';

class TSCERoot extends StatefulWidget {
  const TSCERoot({
    super.key,
    required this.user,
  });
  final User user;

  @override
  State<TSCERoot> createState() => _TSCERootState();
}

class _TSCERootState extends State<TSCERoot> {
  late PageController _controller;
  bool _isLoading = false;

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

  @override
  Widget build(BuildContext context) {
    var dmodel = context.read<DataModel>();
    return ChangeNotifierProvider(
      create: (context) => TSCEModel(email: widget.user.email),
      builder: (context, _) {
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
                                "Create My Team",
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
    var model = Provider.of<TSCEModel>(context);
    return Column(
      children: [
        Container(
          color: CustomColors.textColor(context).withValues(alpha: 0.05),
          child: Column(children: [
            const SizedBox(height: 8),
            model.status(context, dmodel, _controller),
            const SizedBox(height: 16),
          ]),
        ),
        Expanded(
          child: PageView(
            controller: _controller,
            children: const [
              //
              TSCETemplates(),
              TSCEBasic(),
              TSCERoster(),
              TSCEAdditional(),
            ],
            onPageChanged: (page) {
              model.setIndex(page);
            },
          ),
        ),
      ],
    );
  }

  Widget _navigation(BuildContext context, DataModel dmodel) {
    TSCEModel model = Provider.of<TSCEModel>(context);
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
              opacity: model.index == 0 ? 0 : 1,
              duration: const Duration(milliseconds: 300),
              child: XCContainer.custom(
                customRadius: 25,
                height: 50,
                width: 50,
                color: XCTheme.of(context).cell,
                onTap: () {
                  if (model.index != 0) {
                    _controller.previousPage(
                      duration: const Duration(milliseconds: 700),
                      curve: Sprung.overDamped,
                    );
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
                if (model.isAtEnd()) {
                  if (model.isValidated().v1()) {
                    _create(context, model, dmodel);
                  }
                } else {
                  _controller.nextPage(
                      duration: const Duration(milliseconds: 700),
                      curve: Sprung.overDamped);
                }
              },
              color: model.isAtEnd() && !model.isValidated().v1()
                  ? Colors.red.withValues(alpha: 0.3)
                  : dmodel.color,
              child: AnimatedSize(
                duration: const Duration(milliseconds: 700),
                curve: Sprung.overDamped,
                child: SizedBox(
                  width: model.isAtEnd()
                      ? MediaQuery.of(context).size.width / 1.5
                      : 50,
                  child: Center(
                    child: model.isAtEnd()
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
                                model.isValidated().v2(),
                                softWrap: false,
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                  color: model.isValidated().v1()
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

  Future<void> _create(
    BuildContext context,
    TSCEModel model,
    DataModel dmodel,
  ) async {
    setState(() {
      _isLoading = true;
    });

    var response = await dmodel.createTeamSeason(model.getBody());

    // everything worked
    if (response.v1() == 200) {
      // save the teamId and let the user know the app needs to restart
      var prefs = await SharedPreferences.getInstance();
      prefs.setString("teamId", response.v2()!.teamId);
      showSnappingSheet(
      context: context,
      child: Builder(builder: (context) {
          return HeaderBar.sheet(
            title: "Success!",
            child: Column(
              children: [
                Center(
                  child: Text(
                    "Horray, your team has been created! Now we need to restart the app for you, and you will be automatically loaded into your first season.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      color: CustomColors.textColor(context),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                XCWideButton.primary(
                  color: CustomColors.fromHex(model.color),
                  title: "Restart App",
                  onTap: () {
                    RestartWidget.restartApp(context);
                  },
                ),
              ],
            ),
          );
        }),
      draggable: false,
    );
      return;
    }

    // nothing was created
    if (response.v1() == 404) {
      showSnappingSheet(
      context: context,
      child: Builder(builder: (context) {
          return HeaderBar.sheet(
            title: "Uh Oh...",
            child: Column(
              children: [
                Center(
                  child: Text(
                    "There seemed to be an issue checking if your user account exists. A team member is on it, but restarting the app and trying again might work as well.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      color: CustomColors.textColor(context),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                XCWideButton.neutral(
                  title: "Restart App",
                  onTap: () {
                    RestartWidget.restartApp(context);
                  },
                ),
              ],
            ),
          );
        }),
      draggable: false,
    );
      return;
    }

    // there was an issue creating anything
    if (response.v1() == 501) {
      showSnappingSheet(
      context: context,
      child: Builder(builder: (context) {
          return HeaderBar.sheet(
            title: "Uh Oh...",
            child: Column(
              children: [
                Center(
                  child: Text(
                    "Bad news, There was an issue creating your team and season. Good news, a team member is on it and will reach out to you immediately. Feel free to restart the app and try again.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      color: CustomColors.textColor(context),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                XCWideButton.neutral(
                  title: "Restart App",
                  onTap: () {
                    RestartWidget.restartApp(context);
                  },
                ),
              ],
            ),
          );
        }),
      draggable: false,
    );
      return;
    }
    // team, season, and admin stuff was created, but user objects were not
    if (response.v1() == 502 || response.v1() == 503) {
      showSnappingSheet(
      context: context,
      child: Builder(builder: (context) {
          return HeaderBar.sheet(
            title: "Team Created! But...",
            child: Column(
              children: [
                Center(
                  child: Text(
                    "Good news, your team and season was created! Bad news, there was an issue adding your players. A team member is on it and will reach out to you within 24 hours. Though, feel free to restart your app and try to add your players again in the 'more' tab on the homepage.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      color: CustomColors.textColor(context),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                XCWideButton.primary(
                  title: "Restart App",
                  color: CustomColors.fromHex(model.color),
                  onTap: () {
                    RestartWidget.restartApp(context);
                  },
                ),
              ],
            ),
          );
        }),
      draggable: false,
    );
      return;
    }

    // stats failed
    if (response.v1() == 504) {
      showSnappingSheet(
      context: context,
      child: Builder(builder: (context) {
          return HeaderBar.sheet(
            title: "Success! But...",
            child: Column(
              children: [
                Center(
                  child: Text(
                    "Good news, your team, season, and roster was created! Bad news, it appears there was an issue creating your stats. Everything will work normally except your stats will be broken. A team member is on it and will reach out to you within 24 hours.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      color: CustomColors.textColor(context),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                XCWideButton.primary(
                  title: "Restart App",
                  color: CustomColors.fromHex(model.color),
                  onTap: () {
                    RestartWidget.restartApp(context);
                  },
                ),
              ],
            ),
          );
        }),
      draggable: false,
    );
      return;
    }

    // could not fetch team?
    if (response.v1() == 505) {
      showSnappingSheet(
      context: context,
      child: Builder(builder: (context) {
          return HeaderBar.sheet(
            title: "Success! But...",
            child: Column(
              children: [
                Center(
                  child: Text(
                    "Good news, you team, season, roster, and stats were created! But, there seemed to be a weird issue on our end fetching your new team. Restarting the app usually resolves this issue.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      color: CustomColors.textColor(context),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                XCWideButton.primary(
                  title: "Restart App",
                  color: CustomColors.fromHex(model.color),
                  onTap: () {
                    RestartWidget.restartApp(context);
                  },
                ),
              ],
            ),
          );
        }),
      draggable: false,
    );
      return;
    }

    // show generic error
    showSnappingSheet(
      context: context,
      child: Builder(builder: (context) {
        return HeaderBar.sheet(
          title: "Weird...",
          child: Column(
            children: [
              Center(
                child: Text(
                  "You have gotten an error we have not accounted for. A team member is on it and will reach out to you within a couple hours.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    color: CustomColors.textColor(context),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              XCWideButton.primary(
                title: "Restart App",
                color: dmodel.color,
                onTap: () {
                  RestartWidget.restartApp(context);
                },
              ),
            ],
          ),
        );
      }),
      draggable: false,
    );

    setState(() {
      _isLoading = false;
    });
  }
}

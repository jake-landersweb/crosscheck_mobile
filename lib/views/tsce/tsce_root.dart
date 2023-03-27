// ignore_for_file: use_build_context_synchronously

import 'dart:ui';

import 'package:crosscheck_sports/client/root.dart';
import 'package:crosscheck_sports/crosscheck_engine.dart';
import 'package:crosscheck_sports/data/root.dart';
import 'package:crosscheck_sports/extras/root.dart';
import 'package:crosscheck_sports/views/tsce/root.dart';
import 'package:crosscheck_sports/views/tsce/tsce_model.dart';
import 'package:flutter/material.dart';
import 'package:crosscheck_sports/custom_views/root.dart' as cv;
import 'package:shared_preferences/shared_preferences.dart';
import '../components/root.dart' as comp;
import 'package:provider/provider.dart';
import 'package:sprung/sprung.dart';

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
        return Container(
          color: CustomColors.backgroundColor(context),
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              cv.AppBar.sheet(
                canScroll: false,
                title: "Create My Team",
                leading: [
                  cv.BackButton(
                    color: dmodel.color,
                    showIcon: false,
                    showText: true,
                    title: "Cancel",
                  )
                ],
                children: [
                  Expanded(
                    child: _body(context, dmodel),
                  ),
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
          color: CustomColors.textColor(context).withOpacity(0.05),
          child: Column(children: [
            const SizedBox(height: 60),
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
      child: Padding(
        padding: EdgeInsets.fromLTRB(
            16, 0, 16, MediaQuery.of(context).padding.bottom == 0 ? 10 : 0),
        child: Row(
          children: [
            AnimatedOpacity(
              opacity: model.index == 0 ? 0 : 1,
              duration: const Duration(milliseconds: 300),
              child: cv.BasicButton(
                onTap: () {
                  if (model.index != 0) {
                    _controller.previousPage(
                      duration: const Duration(milliseconds: 700),
                      curve: Sprung.overDamped,
                    );
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
                      color: model.isAtEnd() && !model.isValidated().v1()
                          ? Colors.red.withOpacity(0.3)
                          : dmodel.color,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    width: model.isAtEnd()
                        ? MediaQuery.of(context).size.width / 1.5
                        : 50,
                    height: 50,
                    child: model.isAtEnd()
                        ? Center(
                            child: _isLoading
                                ? const cv.LoadingIndicator(color: Colors.white)
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
      cv.cupertinoSheet(
        context: context,
        isDismissible: false,
        enableDrag: false,
        builder: (context) {
          return cv.AppBar.sheet(
            title: "Success!",
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
              comp.ActionButton(
                color: CustomColors.fromHex(model.color),
                title: "Restart App",
                onTap: () {
                  RestartWidget.restartApp(context);
                },
              ),
            ],
          );
        },
      );
      return;
    }

    // nothing was created
    if (response.v1() == 404) {
      cv.cupertinoSheet(
        context: context,
        isDismissible: false,
        enableDrag: false,
        builder: (context) {
          return cv.AppBar.sheet(
            title: "Uh Oh...",
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
              comp.SubActionButton(
                title: "Restart App",
                onTap: () {
                  RestartWidget.restartApp(context);
                },
              ),
            ],
          );
        },
      );
      return;
    }

    // there was an issue creating anything
    if (response.v1() == 501) {
      cv.cupertinoSheet(
        context: context,
        isDismissible: false,
        enableDrag: false,
        builder: (context) {
          return cv.AppBar.sheet(
            title: "Uh Oh...",
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
              comp.SubActionButton(
                title: "Restart App",
                onTap: () {
                  RestartWidget.restartApp(context);
                },
              ),
            ],
          );
        },
      );
      return;
    }
    // team, season, and admin stuff was created, but user objects were not
    if (response.v1() == 502 || response.v1() == 503) {
      cv.cupertinoSheet(
        context: context,
        isDismissible: false,
        enableDrag: false,
        builder: (context) {
          return cv.AppBar.sheet(
            title: "Team Created! But...",
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
              comp.ActionButton(
                title: "Restart App",
                color: CustomColors.fromHex(model.color),
                onTap: () {
                  RestartWidget.restartApp(context);
                },
              ),
            ],
          );
        },
      );
      return;
    }

    // stats failed
    if (response.v1() == 504) {
      cv.cupertinoSheet(
        context: context,
        isDismissible: false,
        enableDrag: false,
        builder: (context) {
          return cv.AppBar.sheet(
            title: "Success! But...",
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
              comp.ActionButton(
                title: "Restart App",
                color: CustomColors.fromHex(model.color),
                onTap: () {
                  RestartWidget.restartApp(context);
                },
              ),
            ],
          );
        },
      );
      return;
    }

    // could not fetch team?
    if (response.v1() == 505) {
      cv.cupertinoSheet(
        context: context,
        isDismissible: false,
        enableDrag: false,
        builder: (context) {
          return cv.AppBar.sheet(
            title: "Success! But...",
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
              comp.ActionButton(
                title: "Restart App",
                color: CustomColors.fromHex(model.color),
                onTap: () {
                  RestartWidget.restartApp(context);
                },
              ),
            ],
          );
        },
      );
      return;
    }

    // show generic error
    cv.cupertinoSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      builder: (context) {
        return cv.AppBar.sheet(
          title: "Weird...",
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
            comp.ActionButton(
              title: "Restart App",
              color: dmodel.color,
              onTap: () {
                RestartWidget.restartApp(context);
              },
            ),
          ],
        );
      },
    );

    setState(() {
      _isLoading = false;
    });
  }
}

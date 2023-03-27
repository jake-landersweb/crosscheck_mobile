import 'dart:ui';

import 'package:crosscheck_sports/crosscheck_engine.dart';
import 'package:crosscheck_sports/views/season/create/sce_template.dart';
import 'package:flutter/material.dart';
import 'package:crosscheck_sports/views/season/create/root.dart';
import 'package:crosscheck_sports/views/season/create/sce_model.dart';
import 'package:crosscheck_sports/views/season/create/sce_positions.dart';
import 'package:provider/provider.dart';
import 'package:sprung/sprung.dart';
import '../../../client/root.dart';
import '../../../data/root.dart';
import '../../../extras/root.dart';
import '../../../custom_views/root.dart' as cv;
import 'package:flutter_switch/flutter_switch.dart';
import 'package:flutter_svg/svg.dart';

class SCERoot extends StatefulWidget {
  const SCERoot({
    Key? key,
    required this.team,
    required this.isCreate,
    this.season,
  }) : super(key: key);
  final Team team;
  final bool isCreate;
  final Season? season;

  @override
  _SCERootState createState() => _SCERootState();
}

class _SCERootState extends State<SCERoot> {
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
    return ChangeNotifierProvider<SCEModel>(
      create: (_) => widget.isCreate
          ? SCEModel.create(widget.team, widget.season)
          : SCEModel.update(widget.team, widget.season!),
      // we use `builder` to obtain a new `BuildContext` that has access to the provider
      builder: (context, child) {
        // No longer throws
        return Container(
          color: CustomColors.backgroundColor(context),
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              cv.AppBar.sheet(
                canScroll: false,
                title: widget.isCreate ? "Create Season" : "Edit Season",
                leading: [
                  cv.BackButton(
                    color: dmodel.color,
                    showIcon: false,
                    showText: true,
                    title: "Cancel",
                    useRoot: true,
                  ),
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
    SCEModel scemodel = Provider.of<SCEModel>(context);
    return Column(
      children: [
        Container(
          color: CustomColors.textColor(context).withOpacity(0.05),
          child: Column(children: [
            const SizedBox(height: 60),
            scemodel.status(context, dmodel, _controller),
            const SizedBox(height: 16),
          ]),
        ),
        Expanded(
          child: PageView(
            controller: _controller,
            children: [
              if (scemodel.isCreate) const SCETemplates(),
              SCEBasic(team: widget.team),
              SCEPositions(team: widget.team),
              SCECustomF(team: widget.team),
              const SCEStats(),
              // if (scemodel.isCreate) SCEUsers(team: widget.team),
            ],
            onPageChanged: (page) {
              scemodel.setIndex(page);
            },
          ),
        ),
      ],
    );
  }

  Widget _navigation(BuildContext context, DataModel dmodel) {
    SCEModel scemodel = Provider.of<SCEModel>(context);
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
              opacity: scemodel.index == 0 ? 0 : 1,
              duration: const Duration(milliseconds: 300),
              child: cv.BasicButton(
                onTap: () {
                  if (scemodel.index != 0) {
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
                      color: scemodel.isAtEnd() && !scemodel.isValidated()
                          ? Colors.red.withOpacity(0.3)
                          : dmodel.color,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    width: scemodel.isAtEnd()
                        ? MediaQuery.of(context).size.width / 1.5
                        : 50,
                    height: 50,
                    child: scemodel.isAtEnd()
                        ? Center(
                            child: _isLoading
                                ? const cv.LoadingIndicator(color: Colors.white)
                                : Text(
                                    scemodel.buttonTitle(),
                                    softWrap: false,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16,
                                      color: scemodel.isValidated()
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
                if (scemodel.isAtEnd()) {
                  if (scemodel.isValidated()) {
                    if (scemodel.isCreate) {
                      _create(context, dmodel, scemodel);
                    } else {
                      _update(context, dmodel, scemodel);
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
      BuildContext context, DataModel dmodel, SCEModel scemodel) async {
    setState(() {
      _isLoading = true;
    });

    Map<String, dynamic> body = {
      "title": scemodel.title,
      "website": scemodel.website,
      "seasonNote": scemodel.seasonNote,
      "customFields": scemodel.customFields.map((e) => e.toJson()).toList(),
      "positions": scemodel.positions.toJson(),
      "date": dateToString(DateTime.now()),
      "seasonStatus": scemodel.seasonStatus,
      "eventCustomFieldsTemplate": scemodel.eventCustomFieldsTemplate,
      "eventCustomUserFieldsTemplate": scemodel.eventCustomUserFieldsTemplate,
      "hasStats": scemodel.hasStats,
      "tz": scemodel.timezone,
    };

    void addUserFields() {
      body['customUserFields'] =
          scemodel.customUserFields.map((e) => e.toJson()).toList();
    }

    if (scemodel.customUserFields.length ==
        scemodel.oldCustomUserFields.length) {
      for (var i in scemodel.oldCustomUserFields) {
        if (!scemodel.customUserFields.any((element) => element == i)) {
          addUserFields();
          break;
        }
      }
    } else {
      addUserFields();
    }

    // determine whether to add stats
    void addStats() {
      body['stats'] = scemodel.stats.toJson();
    }

    // check length
    if (scemodel.stats.stats.length != widget.season!.stats.stats.length) {
      addStats();
    } else {
      // check for new items
      for (var i in widget.season!.stats.stats) {
        if (!scemodel.stats.stats.any((element) => element.title == i.title)) {
          addStats();
        }
      }
    }

    print(body);

    await dmodel.updateSeason(
      widget.team.teamId,
      widget.season!.seasonId,
      body,
      () async {
        // success, get out of widget
        if (widget.season!.seasonId == dmodel.currentSeason!.seasonId) {
          // reset the app
          RestartWidget.restartApp(context);
        } else {
          // success, get out of widget
          Navigator.of(context, rootNavigator: true).pop();
          Navigator.of(context, rootNavigator: true).pop();
          // get all seasons
          setState(() {
            dmodel.allSeasons = null;
          });
          await dmodel.getAllSeasons(widget.team.teamId, (p0) {
            setState(() {
              dmodel.allSeasons = p0;
            });
          });
        }
      },
      showIndicatiors: false,
    );

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _create(
      BuildContext context, DataModel dmodel, SCEModel scemodel) async {
    setState(() {
      _isLoading = true;
    });

    Map<String, dynamic> body = {
      "title": scemodel.title,
      "website": scemodel.website,
      "seasonNote": scemodel.seasonNote,
      "customFields": scemodel.customFields.map((e) => e.toJson()).toList(),
      "positions": scemodel.positions.toJson(),
      "teamUserEmails": [],
      "date": dateToString(DateTime.now()),
      "customUserFields":
          scemodel.customUserFields.map((e) => e.toJson()).toList(),
      "sportCode": scemodel.sportCode,
      "eventCustomFieldsTemplate":
          scemodel.eventCustomFieldsTemplate.map((e) => e.toJson()).toList(),
      "eventCustomUserFieldsTemplate": scemodel.eventCustomUserFieldsTemplate
          .map((e) => e.toJson())
          .toList(),
      "stats": scemodel.stats.toJson(),
      "hasStats": scemodel.hasStats,
      "tz": scemodel.timezone,
    };

    print(body);

    await dmodel.createSeason(widget.team.teamId, body, () async {
      RestartWidget.restartApp(context);
    });

    setState(() {
      _isLoading = false;
    });
  }
}

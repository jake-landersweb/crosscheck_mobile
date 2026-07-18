import 'package:crosscheck_sports/crosscheck_engine.dart';
import 'package:crosscheck_sports/views/season/create/sce_template.dart';
import 'package:flutter/material.dart';
import 'package:crosscheck_sports/views/season/create/root.dart';
import 'package:provider/provider.dart';
import 'package:sprung/sprung.dart';
import '../../../client/root.dart';
import '../../../data/root.dart';
import '../../../extras/root.dart';
import 'package:crosscheck_sports/components/layer/action_button.dart';
import 'package:crosscheck_sports/components/core/container.dart';
import 'package:crosscheck_sports/style/root.dart';

class SCERoot extends StatefulWidget {
  const SCERoot({
    super.key,
    required this.team,
    required this.isCreate,
    this.season,
  });
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
                                widget.isCreate ? "Create Season" : "Edit Season",
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
    SCEModel scemodel = Provider.of<SCEModel>(context);
    return Column(
      children: [
        Container(
          color: CustomColors.textColor(context).withValues(alpha: 0.05),
          child: Column(children: [
            const SizedBox(height: 8),
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
              child: XCContainer.custom(
                customRadius: 25,
                height: 50,
                width: 50,
                color: XCTheme.of(context).cell,
                onTap: () {
                  if (scemodel.index != 0) {
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
              color: scemodel.isAtEnd() && !scemodel.isValidated()
                  ? Colors.red.withValues(alpha: 0.3)
                  : dmodel.color,
              child: AnimatedSize(
                duration: const Duration(milliseconds: 700),
                curve: Sprung.overDamped,
                child: SizedBox(
                  width: scemodel.isAtEnd()
                      ? MediaQuery.of(context).size.width / 1.5
                      : 50,
                  child: Center(
                    child: scemodel.isAtEnd()
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
                                scemodel.buttonTitle(),
                                softWrap: false,
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                  color: scemodel.isValidated()
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

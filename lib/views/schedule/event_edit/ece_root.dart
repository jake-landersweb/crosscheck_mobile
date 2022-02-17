import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:pnflutter/extras/root.dart';
import 'package:pnflutter/views/schedule/event_edit/ece_location.dart';
import 'root.dart';
import '../../../client/root.dart';
import '../../../data/root.dart';
import 'package:provider/provider.dart';
import '../../../custom_views/root.dart' as cv;
import 'package:sprung/sprung.dart';

class ECERoot extends StatefulWidget {
  const ECERoot({
    Key? key,
    required this.isCreate,
    required this.team,
    required this.season,
    required this.teamUser,
    required this.user,
    this.eventUsers,
    this.seasonUser,
    this.event,
  }) : super(key: key);
  final bool isCreate;
  final Team team;
  final Season season;
  final Event? event;
  final List<SeasonUser>? eventUsers;
  final User user;
  final SeasonUserTeamFields teamUser;
  final SeasonUser? seasonUser;

  @override
  _ECERootState createState() => _ECERootState();
}

class _ECERootState extends State<ECERoot> {
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
    return ChangeNotifierProvider<ECEModel>(
      create: (_) => widget.isCreate
          ? ECEModel.create(widget.team, widget.season, dmodel.seasonUsers!)
          : ECEModel.update(widget.team, widget.season, widget.event!,
              dmodel.seasonUsers!, widget.eventUsers!),
      // we use `builder` to obtain a new `BuildContext` that has access to the provider
      builder: (context, child) {
        // No longer throws
        return Stack(
          alignment: Alignment.bottomCenter,
          children: [
            cv.AppBar(
              canScroll: false,
              title: widget.isCreate ? "Create Event" : "Edit Event",
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
    ECEModel scemodel = Provider.of<ECEModel>(context);
    return Column(
      children: [
        Container(
          color: CustomColors.textColor(context).withOpacity(0.05),
          child: Column(children: [
            const SizedBox(height: 100),
            scemodel.status(context, dmodel, _controller),
            const SizedBox(height: 16),
          ]),
        ),
        Expanded(
          child: PageView(
            controller: _controller,
            children: const [
              ECEBasic(),
              ECECustom(),
              ECEUsers(),
              ECELocation(),
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
    ECEModel ecemodel = Provider.of<ECEModel>(context);
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
            16, 0, 16, MediaQuery.of(context).padding.bottom == 0 ? 10 : 0),
        child: Row(
          children: [
            AnimatedOpacity(
              opacity: ecemodel.index == 0 ? 0 : 1,
              duration: const Duration(milliseconds: 300),
              child: cv.BasicButton(
                onTap: () {
                  if (ecemodel.index != 0) {
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
                      color: ecemodel.isAtEnd() && !ecemodel.isValidated()
                          ? Colors.red.withOpacity(0.3)
                          : dmodel.color,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    width: ecemodel.isAtEnd()
                        ? MediaQuery.of(context).size.width / 1.5
                        : 50,
                    height: 50,
                    child: ecemodel.isAtEnd()
                        ? Center(
                            child: _isLoading
                                ? const cv.LoadingIndicator(color: Colors.white)
                                : Text(
                                    ecemodel.buttonTitle(),
                                    softWrap: false,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16,
                                      color: ecemodel.isValidated()
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
                if (ecemodel.isAtEnd()) {
                  if (ecemodel.isValidated()) {
                    action(context, dmodel, ecemodel);
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

  Future<void> action(
      BuildContext context, DataModel dmodel, ECEModel ecemodel) async {
    setState(() {
      _isLoading = true;
    });

    EventTeam homeTeam = EventTeam.empty();
    EventTeam awayTeam = EventTeam.empty();

    if (ecemodel.event.eventType == 1) {
      if (ecemodel.isHome) {
        homeTeam = EventTeam(
            title: widget.team.title, teamId: widget.team.teamId, score: 0);
        awayTeam = EventTeam(title: ecemodel.opponentName, score: 0);
      } else {
        homeTeam = EventTeam(title: ecemodel.opponentName, score: 0);
        awayTeam = EventTeam(
            title: widget.team.title, teamId: widget.team.teamId, score: 0);
      }
    }

    Map<String, dynamic> body = ecemodel.event.toJson();
    body['eDate'] = dateToString(ecemodel.eventDate);
    body['isHome'] = ecemodel.isHome;
    body['homeTeam'] = homeTeam.toJson();
    body['awayTeam'] = awayTeam.toJson();
    body['teamId'] = widget.team.teamId;
    body['seasonId'] = widget.season.seasonId;
    body['addUsers'] = ecemodel.addUsers.map((e) => e.email).toList();

    print(body);
    // return;

    if (ecemodel.isCreate) {
      body['customUserFields'] =
          ecemodel.event.customUserFields.map((e) => e.toJson()).toList();

      print(body);

      // send the create request
      await dmodel.createEvent(widget.team.teamId, widget.season.seasonId, body,
          () {
        Navigator.of(context).pop();
        // refresh the schedule page
        dmodel.reloadHomePage(widget.team.teamId, widget.season.seasonId,
            widget.user.email, false);
      });
    } else {
      // check if custom user fields have changed
      void addUserFields() {
        body['customUserFields'] =
            ecemodel.event.customUserFields.map((e) => e.toJson()).toList();
      }

      if (ecemodel.event.customUserFields.length ==
          ecemodel.oldCustomUserFields.length) {
        for (var i in ecemodel.oldCustomUserFields) {
          if (!ecemodel.event.customUserFields.any((element) => element == i)) {
            addUserFields();
            break;
          }
        }
      } else {
        addUserFields();
      }

      print(body);

      // send the update request
      await dmodel.updateEvent(widget.team.teamId, widget.season.seasonId,
          widget.event!.eventId, body, () {
        Navigator.of(context).pop();
        Navigator.of(context).pop();
        // refresh the schedule page
        dmodel.reloadHomePage(widget.team.teamId, widget.season.seasonId,
            widget.user.email, false);
      });
    }

    setState(() {
      _isLoading = false;
    });
  }
}

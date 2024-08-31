import 'dart:convert';

import 'package:crosscheck_sports/client/root.dart';
import 'package:crosscheck_sports/custom_views/none_found.dart';
import 'package:crosscheck_sports/data/root.dart';
import 'package:crosscheck_sports/data/team/team.dart';
import 'package:crosscheck_sports/extras/root.dart';
import 'package:crosscheck_sports/views/root.dart';
import 'package:crosscheck_sports/views/season/event_duties/event_duty_user_select.dart';
import 'package:flutter/material.dart';
import 'package:crosscheck_sports/custom_views/root.dart' as cv;
import 'package:provider/provider.dart';

class EventDutyCreate extends StatefulWidget {
  const EventDutyCreate({
    super.key,
    required this.team,
    required this.season,
    required this.seasonUsers,
    required this.eventDuties,
  });
  final Team team;
  final Season season;
  final List<SeasonUser> seasonUsers;
  final List<EventDuty> eventDuties;

  @override
  State<EventDutyCreate> createState() => _EventDutyCreateState();
}

class _EventDutyCreateState extends State<EventDutyCreate> {
  bool _isLoading = false;
  bool _isSaving = false;
  bool _hasError = false;
  List<EventDuty> _eventDuties = [];

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  Widget build(BuildContext context) {
    var dmodel = Provider.of<DataModel>(context);
    return cv.AppBar.sheet(
      title: "Event Duties",
      leading: [
        cv.BasicButton(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: Text(
            "Cancel",
            style: TextStyle(
              color: CustomColors.textColor(context).withOpacity(0.5),
              fontWeight: FontWeight.w500,
              fontSize: 18,
            ),
          ),
        )
      ],
      trailing: [
        cv.BasicButton(
          onTap: () {
            var res = _isValid();
            if (res.v1()) {
              _save(context, dmodel);
            } else {
              dmodel.addIndicator(IndicatorItem.error(res.v2()));
            }
          },
          child: _isSaving
              ? cv.LoadingIndicator(color: dmodel.color)
              : Text(
                  "Save",
                  style: TextStyle(
                    color: _isValid().v1()
                        ? dmodel.color
                        : CustomColors.textColor(context).withOpacity(0.5),
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
        )
      ],
      children: [_body(context, dmodel)],
    );
  }

  Widget _body(BuildContext context, DataModel dmodel) {
    if (_hasError) {
      return Column(
        children: [
          cv.NoneFound(
            "There was an issue fetching your event duties.",
            color: dmodel.color,
          ),
          const SizedBox(height: 16),
          cv.BasicButton(
            onTap: () {
              _init();
            },
            child: Container(
              decoration: BoxDecoration(
                color: CustomColors.cellColor(context),
                borderRadius: BorderRadius.circular(10),
              ),
              height: 45,
              width: double.infinity,
              child: Center(
                child: Text(
                  "Retry",
                  style: TextStyle(
                    color: CustomColors.textColor(context),
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }
    if (_isLoading) {
      return cv.LoadingIndicator(color: dmodel.color);
    }
    return Column(
      children: [
        cv.ListView<EventDuty>(
          allowsDelete: true,
          isAnimated: true,
          backgroundColor: CustomColors.cellColor(context),
          horizontalPadding: 0,
          childPadding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
          animateOpen: false,
          equality: (item1, item2) {
            return item1.eventDutyId == item2.eventDutyId;
          },
          onDelete: (item) async {
            setState(() {
              _eventDuties.removeWhere(
                  (element) => element.eventDutyId == item.eventDutyId);
            });
          },
          children: _eventDuties,
          childBuilder: (context, item) {
            return Row(
              children: [
                Expanded(
                  child: cv.TextField2(
                    labelText: "",
                    hintText: "Title (Bottle Duty) ...",
                    value: item.title,
                    fieldPadding: EdgeInsets.zero,
                    highlightColor: dmodel.color,
                    onChanged: (v) {
                      setState(() {
                        item.title = v;
                      });
                    },
                  ),
                ),
                cv.BasicButton(
                  onTap: () {
                    cv.cupertinoSheet(
                      context: context,
                      builder: (context) => EventDutyUserSelect(
                        team: widget.team,
                        season: widget.season,
                        seasonUsers: widget.seasonUsers,
                        selectedUsers: item.users,
                        onSelect: () {
                          setState(() {});
                        },
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: dmodel.color,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    height: 30,
                    width: 30,
                    child: const Icon(Icons.people, color: Colors.white),
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 16),
        cv.BasicButton(
          onTap: () {
            setState(() {
              _eventDuties.add(
                EventDuty.empty(
                    teamId: widget.team.teamId,
                    seasonId: widget.season.seasonId),
              );
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: CustomColors.cellColor(context),
              borderRadius: BorderRadius.circular(10),
            ),
            height: 50,
            width: double.infinity,
            child: Center(
              child: Text(
                "Add New",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  color: CustomColors.textColor(context),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Tuple<bool, String> _isValid() {
    if (_eventDuties.any((element) => element.title.isEmpty)) {
      return Tuple(false, "Titles cannot be empty");
    } else if (_eventDuties.any((element) => element.users.isEmpty)) {
      return Tuple(false, "An event duty has no users");
    } else {
      return Tuple(true, "");
    }
  }

  Future<void> _init() async {
    _eventDuties = [for (var i in widget.eventDuties) i.clone()];
    setState(() {});
    // setState(() {
    //   _hasError = false;
    //   _isLoading = true;
    // });
    // try {
    //   var dmodel = context.read<DataModel>();
    //   var response = await dmodel.client.fetch(
    //       "/teams/${widget.team.teamId}/seasons/${widget.season.seasonId}/duties");
    //   if (response == null || response['status'] != 200) {
    //     throw "The response was invalid: $response";
    //   }

    //   // parse the event duties
    //   for (var i in response['body']) {
    //     _eventDuties.add(EventDuty.fromJson(i));
    //   }
    // } catch (e, s) {
    //   print(e);
    //   print(s);
    //   _hasError = true;
    // }
    // setState(() {
    //   _isLoading = false;
    // });
  }

  Future<void> _save(BuildContext context, DataModel dmodel) async {
    setState(() {
      _isSaving = true;
    });
    try {
      var body = jsonEncode({
        "eventDuties": [for (var i in _eventDuties) i.toMap()]
      });

      var response = await dmodel.client.put(
        "/teams/${widget.team.teamId}/seasons/${widget.season.seasonId}/updateAllDuties",
        {"Content-type": "application/json"},
        body,
      );

      if (response == null || response['status'] != 200) {
        throw "There was an issue sending the request: $response";
      }

      // refresh the event duties
      await dmodel.getEventDuties(widget.team.teamId, widget.season.seasonId);
      dmodel.refreshState();

      Navigator.of(context).pop();
    } catch (e, s) {
      print(e);
      print(s);
      dmodel.addIndicator(
        IndicatorItem.error("There was an issue updating your event duties"),
      );
    }
    setState(() {
      _isSaving = false;
    });
  }
}

import 'package:crosscheck_sports/client/data_model.dart';
import 'package:crosscheck_sports/client/root.dart';
import 'package:crosscheck_sports/data/event_duties/event_duty_event_user.dart';
import 'package:crosscheck_sports/data/root.dart';
import 'package:crosscheck_sports/extras/extensions.dart';
import 'package:crosscheck_sports/views/roster/basic_roster_cell.dart';
import 'package:flutter/material.dart';
import 'package:crosscheck_sports/custom_views/root.dart' as cv;
import 'package:provider/provider.dart';

class EventDutySelect extends StatefulWidget {
  const EventDutySelect({
    super.key,
    required this.team,
    required this.season,
    required this.event,
    required this.eventDuty,
    this.initialUser,
    required this.onSelect,
  });
  final Team team;
  final Season season;
  final Event event;
  final EventDuty eventDuty;
  final EventDutyEventUser? initialUser;
  final Function(EventDutyEventUser user) onSelect;

  @override
  State<EventDutySelect> createState() => _EventDutySelectState();
}

class _EventDutySelectState extends State<EventDutySelect> {
  bool _isLoading = false;
  Map<String, int> _counts = {};
  String? _selected;

  @override
  void initState() {
    if (widget.initialUser != null) {
      _selected = widget.initialUser!.email;
    }
    _init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var dmodel = Provider.of<DataModel>(context);
    return cv.AppBar.sheet(
      title: "Choose User",
      leading: [cv.CloseButton(color: dmodel.color)],
      trailing: [
        cv.BasicButton(
          onTap: () {
            if (_selected == null) {
              dmodel
                  .addIndicator(IndicatorItem.error("The user cannot be null"));
            } else {
              _save(context, dmodel);
            }
          },
          child: _isLoading
              ? cv.LoadingIndicator(color: dmodel.color)
              : Text(
                  "Save",
                  style: TextStyle(
                    color: _selected != null
                        ? dmodel.color
                        : CustomColors.textColor(context).withOpacity(0.5),
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
        )
      ],
      children: [
        cv.ListView<SeasonUser>(
          children: dmodel.seasonUsers!,
          color: dmodel.color,
          allowsSelect: true,
          selected: _selected == null
              ? []
              : [
                  dmodel.seasonUsers!
                      .firstWhere((element) => element.email == _selected)
                ],
          horizontalPadding: 0,
          childPadding: const EdgeInsets.all(8),
          // backgroundColor: CustomColors.sheetCell(context),
          onSelect: (item) {
            if (_selected == null) {
              _selected = item.email;
            } else if (_selected! == item.email) {
              _selected = null;
            } else {
              _selected = item.email;
            }
            setState(() {});
          },
          childBuilder: (context, item) {
            return Row(
              children: [
                Expanded(
                  child: BasicRosterCell(
                    user: item,
                    team: widget.team,
                  ),
                ),
                Text(
                  _counts[item.email].toString(),
                  style: TextStyle(
                    color: CustomColors.textColor(context).withOpacity(0.3),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                )
                // _trailingWidget(context, item, smodel),
              ],
            );
          },
        ),
      ],
    );
  }

  Future<void> _init() async {
    setState(() {
      _isLoading = true;
    });
    try {
      var dmodel = context.read<DataModel>();
      var response = await dmodel.getEventDutyCounts(
        widget.team.teamId,
        widget.season.seasonId,
        widget.event.eventId,
        widget.eventDuty.eventDutyId,
      );
      if (response == null) {
        throw "There was an issue getting the event duty counts";
      }
      for (var i in response['body']) {
        _counts[i['email']] = i['count'];
      }
      print(_counts);
    } catch (e, s) {
      print(e);
      print(s);
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _save(BuildContext context, DataModel dmodel) async {
    setState(() {
      _isLoading = true;
    });
    try {
      var response = await dmodel.selectEventDutyUser(
        widget.team.teamId,
        widget.season.seasonId,
        widget.event.eventId,
        widget.eventDuty.eventDutyId,
        _selected!,
      );
      if (response == null) {
        throw Exception("There was an issue choosing the event duty user");
      }
      widget.onSelect(EventDutyEventUser.fromJson(response['body']));
      Navigator.of(context).pop();
    } catch (e, s) {
      print(e);
      print(s);
      dmodel.addIndicator(
          IndicatorItem.error("There was an issue saving your selection"));
    }
    setState(() {
      _isLoading = false;
    });
  }
}

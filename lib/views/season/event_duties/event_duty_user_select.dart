import 'package:crosscheck_sports/client/root.dart';
import 'package:crosscheck_sports/data/root.dart';
import 'package:crosscheck_sports/extras/root.dart';
import 'package:crosscheck_sports/views/roster/basic_roster_cell.dart';
import 'package:flutter/material.dart';
import 'package:crosscheck_sports/components/layer/header_bar.dart';
import 'package:provider/provider.dart';
import 'package:crosscheck_sports/components/core/clickable.dart';
import 'package:crosscheck_sports/components/core/cell_list.dart';
import 'package:crosscheck_sports/components/layer/action_button.dart';

class EventDutyUserSelect extends StatefulWidget {
  const EventDutyUserSelect({
    super.key,
    required this.team,
    required this.season,
    required this.seasonUsers,
    required this.selectedUsers,
    required this.onSelect,
  });
  final Team team;
  final Season season;
  final List<SeasonUser> seasonUsers;
  final List<EventDutyUser> selectedUsers;
  final VoidCallback onSelect;

  @override
  State<EventDutyUserSelect> createState() => _EventDutyUserSelectState();
}

class _EventDutyUserSelectState extends State<EventDutyUserSelect> {
  @override
  Widget build(BuildContext context) {
    var dmodel = Provider.of<DataModel>(context);
    return HeaderBar.sheet(
      title: "Select Users",
      trailing: XCActionButton.cancel(),
      child: Column(
        children: [
        Clickable(
          onTap: () {
            widget.selectedUsers.clear();
            widget.selectedUsers.addAll(
              widget.seasonUsers.map(
                (e) => EventDutyUser.empty(
                  teamId: widget.team.teamId,
                  seasonId: widget.season.seasonId,
                  eventDutyId: 0,
                  email: e.email,
                ),
              ),
            );
            widget.onSelect();
            setState(() {});
          },
          child: Container(
            decoration: BoxDecoration(
              color: CustomColors.cellColor(context),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.green[300]!,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    height: 30,
                    width: 30,
                    child: const Icon(Icons.people, color: Colors.white),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Select All",
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 18,
                      color: CustomColors.textColor(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Clickable(
          onTap: () {
            widget.selectedUsers.clear();
            widget.onSelect();
            setState(() {});
          },
          child: Container(
            decoration: BoxDecoration(
              color: CustomColors.cellColor(context),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.blue[300]!,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    height: 30,
                    width: 30,
                    child: const Icon(Icons.people, color: Colors.white),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Remove All",
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 18,
                      color: CustomColors.textColor(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        XCCellList<String>(
          children: widget.seasonUsers.map((e) => e.email).toList(),
          color: dmodel.color,
          allowsSelect: true,
          selected: widget.selectedUsers.map((e) => e.email).toList(),
          horizontalPadding: 0,
          childPadding: const EdgeInsets.all(8),
          // backgroundColor: CustomColors.sheetCell(context),
          onSelect: (item) {
            if (widget.selectedUsers.any((element) => element.email == item)) {
              widget.selectedUsers
                  .removeWhere((element) => element.email == item);
            } else {
              widget.selectedUsers.add(EventDutyUser.empty(
                teamId: widget.team.teamId,
                seasonId: widget.season.seasonId,
                eventDutyId: 0,
                email: item,
              ));
            }
            widget.onSelect();
            setState(() {});
          },
          selectedLogic: (item) {
            return widget.selectedUsers.any((element) => element.email == item);
          },
          childBuilder: (context, item) {
            return Row(
              children: [
                Expanded(
                  child: BasicRosterCell(
                    user: widget.seasonUsers
                        .firstWhere((element) => element.email == item),
                    team: widget.team,
                  ),
                ),
                // _trailingWidget(context, item, smodel),
              ],
            );
          },
        ),
        ],
      ),
    );
  }
}

import 'package:crosscheck_sports/client/root.dart';
import 'package:crosscheck_sports/data/root.dart';
import 'package:crosscheck_sports/extras/root.dart';
import 'package:crosscheck_sports/views/root.dart';
import 'package:crosscheck_sports/views/roster/roster_groups/rg_cu.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:crosscheck_sports/components/layer/header_bar.dart';
import 'package:crosscheck_sports/components/layer/snapping_sheet.dart';
import 'package:crosscheck_sports/components/layer/action_button.dart';
import 'package:crosscheck_sports/components/core/cell_list.dart';
import 'package:crosscheck_sports/components/layer/section.dart';

class RGView extends StatefulWidget {
  const RGView({
    super.key,
    required this.team,
    required this.season,
    required this.rosterGroup,
    required this.seasonUsers,
  });
  final Team team;
  final Season season;
  final RosterGroup rosterGroup;
  final List<SeasonUser> seasonUsers;

  @override
  State<RGView> createState() => _RGViewState();
}

class _RGViewState extends State<RGView> {
  @override
  Widget build(BuildContext context) {
    RGModel rgmodel = Provider.of<RGModel>(context);
    DataModel dmodel = Provider.of<DataModel>(context);
    return HeaderBar(
      title: widget.rosterGroup.title,
      leading: XCActionButton.back(),
      backgroundColor: CustomColors.backgroundColor(context),
      trailing: XCActionButton.edit(
        onTap: () {
          showSnappingSheet(
      context: context,
      child: ListenableProvider.value(
                  value: rgmodel,
                  child: RGCU(rosterGroup: widget.rosterGroup),
                ),
    );
        },
      ),
      titleWidget: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          widget.rosterGroup.getIcon(32),
          const SizedBox(width: 8),
          Text(
            widget.rosterGroup.title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: CustomColors.textColor(context),
            ),
          ),
        ],
      ),
      child: _content(context, dmodel, rgmodel),
    );
  }

  Widget _content(BuildContext context, DataModel dmodel, RGModel rgmodel) {
    return Column(
      children: [
        // icon

        // title and desc
        if (widget.rosterGroup.description.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: XCCellList<List<String>>(
              horizontalPadding: 0,
              children: [
                // ["Title", widget.rosterGroup.title],
                ["Description", widget.rosterGroup.description]
              ],
              childPadding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              childBuilder: ((context, item) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item[0],
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        color: CustomColors.textColor(context).withOpacity(0.5),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item[1],
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 18,
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        XCSection(
          "Users",
          child: RosterList(
            team: widget.team,
            users: _getSeasonUsers(),
            type: RosterListType.none,
            color: dmodel.color,
          ),
        )
      ],
    );
  }

  List<SeasonUser> _getSeasonUsers() {
    List<SeasonUser> users = [];
    for (var i in widget.rosterGroup.ids) {
      // theoretically should never return empty, but catch incase
      final SeasonUser su = widget.seasonUsers.firstWhere(
          (element) => element.email == i,
          orElse: () => SeasonUser.empty());
      if (su.email.isNotEmpty) {
        users.add(su);
      }
    }
    return users;
  }
}

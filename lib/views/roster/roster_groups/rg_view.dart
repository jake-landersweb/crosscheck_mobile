import 'package:crosscheck_sports/client/root.dart';
import 'package:crosscheck_sports/data/root.dart';
import 'package:crosscheck_sports/data/roster/roster_group.dart';
import 'package:crosscheck_sports/extras/root.dart';
import 'package:crosscheck_sports/views/root.dart';
import 'package:crosscheck_sports/views/roster/roster_groups/rg_cu.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:crosscheck_sports/custom_views/root.dart' as cv;

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
    return cv.AppBar(
      title: widget.rosterGroup.title,
      itemBarPadding: const EdgeInsets.fromLTRB(8, 0, 16, 8),
      leading: [cv.BackButton(color: dmodel.color)],
      backgroundColor: CustomColors.backgroundColor(context),
      trailing: [
        cv.BasicButton(
          onTap: () {
            cv.cupertinoSheet(
                context: context,
                builder: (context) {
                  return ListenableProvider.value(
                    value: rgmodel,
                    child: RGCU(rosterGroup: widget.rosterGroup),
                  );
                });
          },
          child: Text(
            "Edit",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: dmodel.color,
            ),
          ),
        ),
      ],
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
      // trailing: [
      //   cv.BasicButton(
      //     onTap: () => _create(context, rgmodel),
      //     child: Icon(
      //       Icons.add,
      //       color: dmodel.color,
      //     ),
      //   ),
      // ],
      children: [_content(context, dmodel, rgmodel)],
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
            child: cv.ListView<List<String>>(
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
        cv.Section(
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

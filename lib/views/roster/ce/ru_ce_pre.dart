import 'package:crosscheck_sports/data/root.dart';
import 'package:flutter/material.dart';
import 'package:crosscheck_sports/client/root.dart';
import 'package:provider/provider.dart';
import '../root.dart';
import '../../../custom_views/root.dart' as cv;
import 'package:crosscheck_sports/components/layer/snapping_sheet.dart';
import 'package:crosscheck_sports/components/layer/header_bar.dart';
import 'package:crosscheck_sports/components/layer/action_button.dart';
import 'package:crosscheck_sports/components/layer/wide_button.dart';

class RUCEPre extends StatefulWidget {
  const RUCEPre({
    super.key,
    required this.team,
    required this.season,
  });
  final Team team;
  final Season season;

  @override
  State<RUCEPre> createState() => _RUCEPreState();
}

class _RUCEPreState extends State<RUCEPre> {
  String _selection = "Create new";
  final List<String> _selections = ["Create new", "Choose from team"];

  @override
  Widget build(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    return HeaderBar.sheet(
      title: "Select",
      trailing: XCActionButton.cancel(
        onTap: () => Navigator.of(context).pop(),
      ),
      child: Column(
        children: [
          cv.DynamicSelector<String>(
            selections: _selections,
            selectorStyle: cv.DynamicSelectorStyle.list,
            color: dmodel.color,
            selectedLogic: (context, item) {
              return item == _selection;
            },
            onSelect: (context, item) {
              setState(() {
                _selection = item;
              });
            },
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: XCWideButton.primary(
              title: "Continue",
              color: dmodel.color,
              onTap: () {
                Navigator.of(context).pop();
                if (_selection == "Create new") {
                  showSnappingSheet(
      context: context,
      child: Builder(builder: (context) {
                        return RUCERoot(
                          team: widget.team,
                          season: widget.season,
                          isSheet: true,
                          isCreate: true,
                          useRoot: true,
                          onFunction: (body) async {
                            // create the season user
                            await dmodel.seasonUserAdd(
                              widget.team.teamId,
                              widget.season.seasonId,
                              body,
                              (seasonUser) async {
                                // add the user to this list
                                Navigator.of(context).pop();
                                // refresh the data
                                await dmodel.refreshData(dmodel.user!.email);
                              },
                            );
                          },
                        );
                      }),
    );
                } else {
                  showSnappingSheet(
      context: context,
      child: Builder(builder: (context) {
                        return FTRoot(
                          team: widget.team,
                          season: widget.season,
                          onCompletion: (teamId, seasonId, body) async {
                            await dmodel.seasonUserAddFromList(
                              teamId,
                              seasonId,
                              body,
                              () async {
                                Navigator.of(context).pop();
                                // refresh the data
                                await dmodel.refreshData(dmodel.user!.email);
                              },
                            );
                            // add the user to this list
                          },
                        );
                      }),
    );
                }
              },
            ),
          )
        ],
      ),
    );
  }
}

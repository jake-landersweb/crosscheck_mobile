import 'package:crosscheck_sports/data/root.dart';
import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:crosscheck_sports/client/root.dart';
import 'package:crosscheck_sports/extras/root.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import '../root.dart';
import '../../../custom_views/root.dart' as cv;
import 'root.dart';
import '../../components/root.dart' as comp;

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
    return cv.Sheet(
      title: "Select",
      color: dmodel.color,
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
            child: comp.ActionButton(
              title: "Continue",
              color: dmodel.color,
              onTap: () {
                Navigator.of(context).pop();
                if (_selection == "Create new") {
                  cv.cupertinoSheet(
                      context: context,
                      builder: (context) {
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
                      });
                } else {
                  cv.cupertinoSheet(
                      context: context,
                      builder: (context) {
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
                      });
                }
              },
            ),
          )
        ],
      ),
    );
  }
}

import 'package:crosscheck_sports/crosscheck_engine.dart';
import 'package:flutter/material.dart';
import 'package:crosscheck_sports/views/season/create/sce_model.dart';
import 'package:provider/provider.dart';
import '../../../client/root.dart';
import '../../../data/root.dart';
import '../../../extras/root.dart';
import '../../../custom_views/root.dart' as cv;
import 'package:crosscheck_sports/components/layer/snapping_sheet.dart';
import 'package:crosscheck_sports/components/core/clickable.dart';
import 'package:crosscheck_sports/components/layer/field.dart';
import 'package:crosscheck_sports/components/core/cell_list.dart';
import 'package:crosscheck_sports/components/layer/section.dart';
import 'package:crosscheck_sports/components/adaptive/confirm_dialog/adaptive_confirm_dialog.dart';
import 'package:crosscheck_sports/components/layer/wide_button.dart';

class SCEBasic extends StatefulWidget {
  const SCEBasic({
    super.key,
    required this.team,
  });
  final Team team;

  @override
  _SCEBasicState createState() => _SCEBasicState();
}

class _SCEBasicState extends State<SCEBasic> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    SCEModel scemodel = Provider.of<SCEModel>(context);
    return ListView(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      children: [
        _required(context, dmodel, scemodel),
        _basicInfo(context, dmodel, scemodel),
        if (!scemodel.isCreate)
          //   _templates(context, dmodel, scemodel)
          // else
          Column(
            children: [
              _status(context, dmodel, scemodel),
              Padding(
                padding: const EdgeInsets.all(32),
                child: _delete(context, dmodel, scemodel),
              ),
            ],
          ),
      ],
    );
  }

  Widget _required(BuildContext context, DataModel dmodel, SCEModel scemodel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: XCSection(
        "Required",
        child: XCCellList<Widget>(
          childPadding: const EdgeInsets.symmetric(horizontal: 16),
          horizontalPadding: 0,
          children: [
            SizedBox(
              height: 50,
              child: XCField(
              labelText: "Title",
              value: scemodel.title,
              isLabeled: true,
              onChanged: (value) {
                  setState(() {
                    scemodel.title = value;
                  });
                },
            ),
            )
          ],
        ),
      ),
    );
  }

  Widget _basicInfo(BuildContext context, DataModel dmodel, SCEModel scemodel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          XCSection(
            "Basic Info",
            child: XCCellList<Widget>(
              horizontalPadding: 0,
              childPadding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                SizedBox(
                  height: 50,
                  child: XCField(
              value: scemodel.website,
              labelText: "Website (url)",
              isLabeled: true,
              onChanged: (value) {
                      setState(() {
                        scemodel.website = value;
                      });
                    },
            ),
                ),
                SizedBox(
                  height: 50,
                  child: XCField(
              value: scemodel.seasonNote,
              labelText: "Season Note",
              isLabeled: true,
              onChanged: (value) {
                      setState(() {
                        scemodel.seasonNote = value;
                      });
                    },
            ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Clickable(
            onTap: () {
              showSnappingSheet(
      context: context,
      child: cv.TimezoneSelector(
                  initTimezone: scemodel.timezone,
                  onSelect: (tz) {
                    setState(() {
                      scemodel.timezone = tz;
                    });
                  },
                ),
    );
            },
            child: Container(
              constraints: const BoxConstraints(
                minHeight: 50,
              ),
              decoration: BoxDecoration(
                color: CustomColors.cellColor(context),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Center(
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          "Timezone: ${scemodel.timezone}",
                          style: TextStyle(
                            color: CustomColors.textColor(context),
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _status(BuildContext context, DataModel dmodel, SCEModel scemodel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: XCSection(
        "Status",
        child: cv.SegmentedPicker(
          titles: const ["Past", "Active", "Future"],
          selections: const [-1, 1, 2],
          selection: scemodel.seasonStatus,
          onSelection: (value) {
            setState(() {
              scemodel.seasonStatus = value;
            });
          },
        ),
      ),
    );
  }

  Widget _delete(BuildContext context, DataModel dmodel, SCEModel scemodel) {
    return XCWideButton.destructive(
      title: "Delete",
      isLoading: _isLoading,
      onTap: () {
        AdaptiveConfirmDialog.show(
          context,
          title: "Are you sure?",
          message:
              "Are you sure you want to delete this season? All events, users, and stats will be deleted. This is not advised, it is recommended to set this season to innactive rather than delete.",
          cancelLabel: "Cancel",
          confirmLabel: "Delete",
          isDestructive: true,
        ).then((confirmed) {
          if (confirmed) {
            _deleteAction(context, dmodel, scemodel);
          }
        });
      },
    );
  }

  Future<void> _deleteAction(
      BuildContext context, DataModel dmodel, SCEModel scemodel) async {
    setState(() {
      _isLoading = true;
    });
    await dmodel.deleteSeason(scemodel.team.teamId, scemodel.season!.seasonId,
        () {
      RestartWidget.restartApp(context);
    });
    setState(() {
      _isLoading = false;
    });
  }
}

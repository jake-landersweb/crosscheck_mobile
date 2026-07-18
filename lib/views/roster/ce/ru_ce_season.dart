import 'package:crosscheck_sports/data/root.dart';
import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:crosscheck_sports/client/root.dart';
import 'package:crosscheck_sports/extras/root.dart';
import 'package:provider/provider.dart';
import '../root.dart';
import '../../../custom_views/root.dart' as cv;
import 'root.dart';
import 'package:crosscheck_sports/components/layer/snapping_sheet.dart';
import 'package:crosscheck_sports/components/core/clickable.dart';
import 'package:crosscheck_sports/components/layer/field.dart';
import 'package:crosscheck_sports/components/core/cell_list.dart';
import 'package:crosscheck_sports/components/layer/section.dart';
import 'package:crosscheck_sports/components/core/labeled_row.dart';

class RUCESeason extends StatefulWidget {
  const RUCESeason({super.key});

  @override
  _RUCESeasonState createState() => _RUCESeasonState();
}

class _RUCESeasonState extends State<RUCESeason> {
  @override
  Widget build(BuildContext context) {
    RUCEModel rmodel = Provider.of<RUCEModel>(context);
    DataModel dmodel = Provider.of<DataModel>(context);
    return Column(
      children: [
        // normal fields
        XCSection(
          "PLayer Fields",
          child: Column(
            children: [
              XCCellList<Widget>(
                horizontalPadding: 0,
                childPadding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                children: [
                  _pos(context, dmodel, rmodel),
                  _note(context, rmodel),
                  _jerseySize(context, rmodel),
                  _jerseyNumber(context, rmodel),
                  _isManager(context, dmodel, rmodel),
                  _status(context, rmodel, dmodel),
                  if (rmodel.isCreate) _isSub(context, dmodel, rmodel),
                ],
              ),
              if (rmodel.seasonFields!.customFields.isNotEmpty)
                _customFields(context, dmodel, rmodel),
            ],
          ),
        ),
      ],
    );
  }

  Widget _note(BuildContext context, RUCEModel rmodel) {
    return XCField(
              labelText: "Note",
              isLabeled: true,
              value: rmodel.seasonFields!.seasonUserNote,
              onChanged: (value) {
        rmodel.seasonFields!.seasonUserNote = value;
      },
            );
  }

  Widget _isManager(BuildContext context, DataModel dmodel, RUCEModel rmodel) {
    return XCLabeledWidget(
      "Is Manager",
      child: SizedBox(
        height: 25,
        child: Row(
          children: [
            FlutterSwitch(
              value: rmodel.seasonFields!.isManager,
              height: 25,
              width: 50,
              toggleSize: 18,
              activeColor: dmodel.color,
              onToggle: (value) {
                setState(() {
                  rmodel.seasonFields!.isManager = value;
                });
              },
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _isSub(BuildContext context, DataModel dmodel, RUCEModel rmodel) {
    return XCLabeledWidget(
      "Is Sub",
      child: SizedBox(
        height: 25,
        child: Row(
          children: [
            FlutterSwitch(
              value: rmodel.seasonFields!.isSub,
              height: 25,
              width: 50,
              toggleSize: 18,
              activeColor: dmodel.color,
              onToggle: (value) {
                setState(() {
                  rmodel.seasonFields!.isSub = value;
                });
              },
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _jerseySize(BuildContext context, RUCEModel rmodel) {
    return XCField(
              labelText: "Jersey Size",
              isLabeled: true,
              value: rmodel.seasonFields!.jerseySize,
              onChanged: (value) {
        rmodel.seasonFields!.jerseySize = value;
      },
            );
  }

  Widget _jerseyNumber(BuildContext context, RUCEModel rmodel) {
    return XCField(
              labelText: "Jersey Number",
              keyboardType: TextInputType.number,
              isLabeled: true,
              value: rmodel.seasonFields!.jerseyNumber,
              onChanged: (value) {
        rmodel.seasonFields!.jerseyNumber = value;
      },
            );
  }

  Widget _pos(BuildContext context, DataModel dmodel, RUCEModel rmodel) {
    return XCLabeledWidget(
      "Position",
      isExpanded: false,
      child: Clickable(
        onTap: () {
          showSnappingSheet(
      context: context,
      child: PositionSelect(
                positions: rmodel.season!.positions.available,
                selection: rmodel.seasonFields!.pos,
                onSelect: (pos) {
                  setState(() {
                    rmodel.seasonFields!.pos = pos;
                  });
                },
              ),
    );
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: dmodel.color.withOpacity(0.3),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
            child: Text(
              rmodel.seasonFields!.pos == ""
                  ? "None"
                  : rmodel.seasonFields!.pos.capitalize(),
              style: TextStyle(
                color: dmodel.color,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }

  Widget _status(BuildContext context, RUCEModel rmodel, DataModel dmodel) {
    return XCLabeledWidget(
      "Status",
      isExpanded: false,
      child: Clickable(
        onTap: () {
          showSnappingSheet(
      context: context,
      child: cv.ModelSelector<int>(
                title: "Select Status",
                initialSelection: rmodel.seasonFields!.seasonUserStatus,
                selections: const [1, -1],
                titles: const ["Active", "Inactive"],
                color: dmodel.color,
                onSelection: (int val) {
                  setState(() {
                    rmodel.seasonFields!.seasonUserStatus = val;
                  });
                },
              ),
    );
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: dmodel.color.withOpacity(0.3),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
            child: Text(
              rmodel.seasonFields!.getStatus(),
              style: TextStyle(
                color: dmodel.color,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _customFields(
      BuildContext context, DataModel dmodel, RUCEModel rmodel) {
    return Column(
      children: [
        const SizedBox(height: 8),
        XCCellList<CustomField>(
          horizontalPadding: 0,
          childPadding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
          childBuilder: (context, i) {
            return CustomFieldEdit(field: i, color: dmodel.color);
          },
          children: rmodel.seasonFields!.customFields,
        ),
      ],
    );
  }
}

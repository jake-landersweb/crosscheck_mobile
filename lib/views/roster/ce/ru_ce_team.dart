import 'package:crosscheck_sports/client/root.dart';
import 'package:crosscheck_sports/data/root.dart';
import 'package:flutter/material.dart';
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

class RUCETeam extends StatefulWidget {
  const RUCETeam({super.key});

  @override
  _RUCETeamState createState() => _RUCETeamState();
}

class _RUCETeamState extends State<RUCETeam> {
  @override
  Widget build(BuildContext context) {
    RUCEModel rmodel = Provider.of<RUCEModel>(context);
    DataModel dmodel = Provider.of<DataModel>(context);
    return Column(
      children: [
        // normal fields
        XCSection(
          "Player Fields",
          child: Column(
            children: [
              XCCellList<Widget>(
                childPadding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                horizontalPadding: 0,
                children: [
                  _pos(context, dmodel, rmodel),
                  _note(context, rmodel),
                  _jerseySize(context, rmodel),
                  _jerseyNumber(context, rmodel),
                  if (dmodel.user!.email != rmodel.email)
                    _userType(context, dmodel, rmodel),
                ],
              ),
              if (rmodel.teamFields.customFields.isNotEmpty)
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
              value: rmodel.teamFields.teamUserNote,
              onChanged: (value) {
        rmodel.teamFields.teamUserNote = value;
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
                positions: rmodel.team.positions.available,
                selection: rmodel.teamFields.pos,
                onSelect: (pos) {
                  setState(() {
                    rmodel.teamFields.pos = pos;
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
              rmodel.teamFields.pos == ""
                  ? "None"
                  : rmodel.teamFields.pos.capitalize(),
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

  Widget _jerseySize(BuildContext context, RUCEModel rmodel) {
    return XCField(
              labelText: "Jersey Size",
              isLabeled: true,
              value: rmodel.teamFields.jerseySize,
              onChanged: (value) {
        rmodel.teamFields.jerseySize = value;
      },
            );
  }

  Widget _jerseyNumber(BuildContext context, RUCEModel rmodel) {
    return XCField(
              labelText: "Jersey Number",
              keyboardType: TextInputType.number,
              isLabeled: true,
              value: rmodel.teamFields.jerseyNumber,
              onChanged: (value) {
        rmodel.teamFields.jerseyNumber = value;
      },
            );
  }

  Widget _userType(BuildContext context, DataModel dmodel, RUCEModel rmodel) {
    return XCLabeledWidget(
      "User Type",
      isExpanded: false,
      child: Clickable(
        onTap: () {
          showSnappingSheet(
      context: context,
      child: cv.ModelSelector<int>(
                title: "User Type",
                selections: const [1, 2, 3],
                titles: const ["Player", "Manager", "Owner"],
                onSelection: ((p0) {
                  setState(() {
                    rmodel.teamFields.teamUserType = p0;
                  });
                }),
                initialSelection: rmodel.teamFields.teamUserType,
                color: dmodel.color,
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
              rmodel.teamFields.getTeamUserTypeName(),
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
            children: rmodel.teamFields.customFields),
      ],
    );
  }
}

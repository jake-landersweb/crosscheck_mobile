import 'package:flutter/material.dart';
import 'package:pnflutter/extras/root.dart';
import 'package:provider/provider.dart';
import '../root.dart';
import '../../../custom_views/root.dart' as cv;
import 'root.dart';

class RUCETeam extends StatefulWidget {
  const RUCETeam({Key? key}) : super(key: key);

  @override
  _RUCETeamState createState() => _RUCETeamState();
}

class _RUCETeamState extends State<RUCETeam> {
  @override
  Widget build(BuildContext context) {
    RUCEModel rmodel = Provider.of<RUCEModel>(context);
    return Column(
      children: [
        // normal fields
        cv.Section(
          "Team Fields",
          child: Column(
            children: [
              cv.NativeList(
                itemPadding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                children: [
                  _pos(context, rmodel),
                  _note(context, rmodel),
                  _jerseySize(context, rmodel),
                  _jerseyNumber(context, rmodel),
                  _nickname(context, rmodel),
                ],
              ),
              if (rmodel.teamFields.customFields.isNotEmpty)
                _customFields(context, rmodel),
            ],
          ),
        ),
      ],
    );
  }

  Widget _note(BuildContext context, RUCEModel rmodel) {
    return cv.TextField(
      labelText: "Note",
      isLabeled: true,
      showBackground: false,
      value: rmodel.teamFields.teamUserNote,
      onChanged: (value) {
        rmodel.teamFields.teamUserNote = value;
      },
      validator: (value) => null,
    );
  }

  Widget _pos(BuildContext context, RUCEModel rmodel) {
    return cv.BasicButton(
      onTap: () {
        cv.showFloatingSheet(
          context: context,
          builder: (context) {
            return PositionSelect(
              positions: rmodel.team.positions.available,
              selection: rmodel.teamFields.pos,
              onSelect: (pos) {
                setState(() {
                  rmodel.teamFields.pos = pos;
                });
              },
            );
          },
        );
      },
      child: cv.LabeledWidget(
        "Position",
        child: Text(
          rmodel.teamFields.pos == "" ? "None" : rmodel.teamFields.pos,
          style: TextStyle(
            color: CustomColors.textColor(context).withOpacity(0.5),
            fontSize: 18,
            fontWeight: FontWeight.w600,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }

  Widget _jerseySize(BuildContext context, RUCEModel rmodel) {
    return cv.TextField(
      labelText: "Jersey Size",
      isLabeled: true,
      showBackground: false,
      value: rmodel.teamFields.jerseySize,
      onChanged: (value) {
        rmodel.teamFields.jerseySize = value;
      },
      validator: (value) => null,
    );
  }

  Widget _jerseyNumber(BuildContext context, RUCEModel rmodel) {
    return cv.TextField(
      labelText: "Jersey Number",
      keyboardType: TextInputType.number,
      isLabeled: true,
      showBackground: false,
      value: rmodel.teamFields.jerseyNumber,
      onChanged: (value) {
        rmodel.teamFields.jerseyNumber = value;
      },
      validator: (value) => null,
    );
  }

  Widget _nickname(BuildContext context, RUCEModel rmodel) {
    return cv.TextField(
      labelText: "Nickname",
      isLabeled: true,
      showBackground: false,
      value: rmodel.teamFields.nickname,
      onChanged: (value) {
        rmodel.teamFields.nickname = value;
      },
      validator: (value) => null,
    );
  }

  Widget _customFields(BuildContext context, RUCEModel rmodel) {
    return Column(
      children: [
        const SizedBox(height: 8),
        cv.NativeList(
          itemPadding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
          children: [
            for (var i in rmodel.teamFields.customFields)
              CustomFieldEdit(field: i),
          ],
        ),
      ],
    );
  }
}

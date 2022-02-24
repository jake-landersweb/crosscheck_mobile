import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:pnflutter/client/root.dart';
import 'package:pnflutter/extras/root.dart';
import 'package:provider/provider.dart';
import '../root.dart';
import '../../../custom_views/root.dart' as cv;
import 'root.dart';

class RUCESeason extends StatefulWidget {
  const RUCESeason({Key? key}) : super(key: key);

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
        cv.Section(
          "Season Fields",
          child: Column(
            children: [
              cv.NativeList(
                itemPadding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                children: [
                  _pos(context, rmodel),
                  _note(context, rmodel),
                  _jerseySize(context, rmodel),
                  _jerseyNumber(context, rmodel),
                  _isManager(context, dmodel, rmodel),
                  if (rmodel.isCreate) _isSub(context, dmodel, rmodel),
                ],
              ),
              if (rmodel.seasonFields!.customFields.isNotEmpty)
                _customFields(context, rmodel),
            ],
          ),
        ),
      ],
    );
  }

  Widget _note(BuildContext context, RUCEModel rmodel) {
    return cv.TextField2(
      labelText: "Note",
      isLabeled: true,
      showBackground: false,
      value: rmodel.seasonFields!.seasonUserNote,
      onChanged: (value) {
        rmodel.seasonFields!.seasonUserNote = value;
      },
      validator: (value) => null,
    );
  }

  Widget _isManager(BuildContext context, DataModel dmodel, RUCEModel rmodel) {
    return cv.LabeledWidget(
      "Is Manager",
      child: SizedBox(
        height: 25,
        child: FlutterSwitch(
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
      ),
    );
  }

  Widget _isSub(BuildContext context, DataModel dmodel, RUCEModel rmodel) {
    return cv.LabeledWidget(
      "Is Sub",
      child: SizedBox(
        height: 25,
        child: FlutterSwitch(
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
      ),
    );
  }

  Widget _jerseySize(BuildContext context, RUCEModel rmodel) {
    return cv.TextField2(
      labelText: "Jersey Size",
      isLabeled: true,
      showBackground: false,
      value: rmodel.seasonFields!.jerseySize,
      onChanged: (value) {
        rmodel.seasonFields!.jerseySize = value;
      },
      validator: (value) => null,
    );
  }

  Widget _jerseyNumber(BuildContext context, RUCEModel rmodel) {
    return cv.TextField2(
      labelText: "Jersey Number",
      keyboardType: TextInputType.number,
      isLabeled: true,
      showBackground: false,
      value: rmodel.seasonFields!.jerseyNumber,
      onChanged: (value) {
        rmodel.seasonFields!.jerseyNumber = value;
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
              positions: rmodel.season!.positions.available,
              selection: rmodel.seasonFields!.pos,
              onSelect: (pos) {
                setState(() {
                  rmodel.seasonFields!.pos = pos;
                });
              },
            );
          },
        );
      },
      child: cv.LabeledWidget(
        "Position",
        child: Text(
          rmodel.seasonFields!.pos == "" ? "None" : rmodel.seasonFields!.pos,
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

  Widget _customFields(BuildContext context, RUCEModel rmodel) {
    return Column(
      children: [
        const SizedBox(height: 8),
        cv.NativeList(
          itemPadding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
          children: [
            for (var i in rmodel.seasonFields!.customFields)
              CustomFieldEdit(field: i),
          ],
        ),
      ],
    );
  }
}

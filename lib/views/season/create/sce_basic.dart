import 'package:flutter/material.dart';
import 'package:pnflutter/client/api_helpers.dart';
import 'package:pnflutter/views/season/create/sce_model.dart';
import 'package:pnflutter/views/season/create/sce_customf.dart';
import 'package:pnflutter/views/shared/positions_create.dart';
import 'package:provider/provider.dart';
import '../../../client/root.dart';
import '../../../data/root.dart';
import '../../../extras/root.dart';
import '../../menu/root.dart';
import '../../../custom_views/root.dart' as cv;
import 'package:flutter_switch/flutter_switch.dart';
import '../../shared/root.dart';

class SCEBasic extends StatefulWidget {
  const SCEBasic({
    Key? key,
    required this.team,
  }) : super(key: key);
  final Team team;

  @override
  _SCEBasicState createState() => _SCEBasicState();
}

class _SCEBasicState extends State<SCEBasic> {
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
        if (!scemodel.isCreate) _status(context, dmodel, scemodel),
      ],
    );
  }

  Widget _required(BuildContext context, DataModel dmodel, SCEModel scemodel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: cv.Section(
        "Required",
        child: cv.NativeList(
          children: [
            SizedBox(
              height: cellHeight,
              child: cv.TextField(
                labelText: "Title",
                initialvalue: scemodel.title,
                showBackground: false,
                fieldPadding: EdgeInsets.zero,
                isLabeled: true,
                onChanged: (value) {
                  setState(() {
                    scemodel.title = value;
                  });
                },
                validator: (value) {},
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
      child: cv.Section(
        "Basic Info",
        child: cv.NativeList(
          children: [
            SizedBox(
              height: cellHeight,
              child: cv.TextField(
                initialvalue: scemodel.website,
                labelText: "Website (url)",
                showBackground: false,
                fieldPadding: EdgeInsets.zero,
                isLabeled: true,
                onChanged: (value) {
                  setState(() {
                    scemodel.website = value;
                  });
                },
                validator: (value) {},
              ),
            ),
            SizedBox(
              height: cellHeight,
              child: cv.TextField(
                initialvalue: scemodel.seasonNote,
                labelText: "Season Note",
                showBackground: false,
                fieldPadding: EdgeInsets.zero,
                isLabeled: true,
                onChanged: (value) {
                  setState(() {
                    scemodel.seasonNote = value;
                  });
                },
                validator: (value) {},
              ),
            ),
            cv.LabeledWidget(
              "Show Nicknames",
              height: cellHeight,
              child: FlutterSwitch(
                value: scemodel.showNicknames,
                height: 25,
                width: 50,
                toggleSize: 18,
                activeColor: dmodel.color,
                onToggle: (value) {
                  setState(() {
                    scemodel.showNicknames = value;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _status(BuildContext context, DataModel dmodel, SCEModel scemodel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: cv.Section(
        "Status",
        child: cv.NativeList(
          children: [
            cv.SegmentedPicker(
              titles: const ["Past", "Active", "Future"],
              selections: const [-1, 1, 2],
              initialSelection: scemodel.seasonStatus,
              onSelection: (value) {
                setState(() {
                  scemodel.seasonStatus = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}

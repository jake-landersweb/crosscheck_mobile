import 'package:flutter/material.dart';
import 'package:pnflutter/client/root.dart';
import 'package:pnflutter/views/root.dart';
import 'package:pnflutter/views/shared/positions_create.dart';
import 'package:provider/provider.dart';
import '../../../custom_views/root.dart' as cv;

class TCEPositions extends StatefulWidget {
  const TCEPositions({Key? key}) : super(key: key);

  @override
  _TCEPositionsState createState() => _TCEPositionsState();
}

class _TCEPositionsState extends State<TCEPositions> {
  @override
  Widget build(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    TCEModel tcemodel = Provider.of<TCEModel>(context);
    return ListView(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      children: [
        _body(context, tcemodel, dmodel),
      ],
    );
  }

  Widget _body(BuildContext context, TCEModel tcemodel, DataModel dmodel) {
    return cv.Section(
      "Positions",
      headerPadding: const EdgeInsets.fromLTRB(32, 8, 16, 4),
      child: PositionsCreate(positions: tcemodel.team.positions),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:crosscheck_sports/client/root.dart';
import 'package:crosscheck_sports/views/root.dart';
import 'package:crosscheck_sports/views/shared/positions_create.dart';
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
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _body(BuildContext context, TCEModel tcemodel, DataModel dmodel) {
    return cv.Section(
      "Positions",
      color: dmodel.color,
      helperView: (context) {
        return Column(
          children: const [
            cv.Section(
              "Positions",
              child: Text(
                  "Positions can be created and removed at ease, and give you a way to keep track of your users positions. Select a position to choose a default, and your rosters can be sorted later based on these positions."),
            )
          ],
        );
      },
      headerPadding: const EdgeInsets.fromLTRB(32, 8, 16, 4),
      child: PositionsCreate(positions: tcemodel.team.positions),
    );
  }
}

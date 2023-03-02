import 'package:flutter/material.dart';
import 'package:crosscheck_sports/views/season/create/sce_model.dart';
import 'package:crosscheck_sports/views/season/create/sce_customf.dart';
import 'package:crosscheck_sports/views/shared/positions_create.dart';
import 'package:provider/provider.dart';
import '../../../client/root.dart';
import '../../../data/root.dart';
import '../../../extras/root.dart';
import '../../menu/root.dart';
import '../../../custom_views/root.dart' as cv;
import 'package:flutter_switch/flutter_switch.dart';
import '../../shared/root.dart';

class SCEPositions extends StatefulWidget {
  const SCEPositions({
    Key? key,
    required this.team,
  }) : super(key: key);
  final Team team;

  @override
  _SCEPositionsState createState() => _SCEPositionsState();
}

class _SCEPositionsState extends State<SCEPositions> {
  @override
  Widget build(BuildContext context) {
    SCEModel scemodel = Provider.of<SCEModel>(context);
    DataModel dmodel = Provider.of<DataModel>(context);
    return ListView(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      children: [
        cv.Section(
          "Positions",
          headerPadding: const EdgeInsets.fromLTRB(32, 8, 0, 4),
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
          child: PositionsCreate(positions: scemodel.positions),
        ),
        const SizedBox(height: 100),
      ],
    );
  }
}

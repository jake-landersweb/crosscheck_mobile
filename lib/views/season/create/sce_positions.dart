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
    return ListView(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      children: [
        cv.Section(
          "Positions",
          headerPadding: const EdgeInsets.fromLTRB(32, 8, 0, 4),
          child: PositionsCreate(positions: scemodel.positions),
        ),
        const SizedBox(height: 100),
      ],
    );
  }
}

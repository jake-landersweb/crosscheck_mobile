import 'package:flutter/material.dart';
import 'package:pnflutter/client/root.dart';
import 'package:pnflutter/data/root.dart';
import 'package:pnflutter/views/root.dart';
import 'package:provider/provider.dart';
import '../../../custom_views/root.dart' as cv;

class TCEStats extends StatefulWidget {
  const TCEStats({Key? key}) : super(key: key);

  @override
  _TCEStatsState createState() => _TCEStatsState();
}

class _TCEStatsState extends State<TCEStats> {
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
      "Stats",
      headerPadding: const EdgeInsets.fromLTRB(32, 8, 16, 4),
      child: StatCEList(
        color: dmodel.color,
        team: tcemodel.team,
        stats: tcemodel.team.stats,
      ),
    );
  }
}

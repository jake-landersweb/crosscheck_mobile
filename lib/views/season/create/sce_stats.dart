import 'package:flutter/material.dart';
import 'package:crosscheck_sports/views/root.dart';
import 'package:crosscheck_sports/views/season/create/sce_model.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:provider/provider.dart';
import '../../../client/root.dart';
import 'root.dart';
import 'package:crosscheck_sports/components/core/cell_list.dart';
import 'package:crosscheck_sports/components/layer/section.dart';
import 'package:crosscheck_sports/components/core/labeled_row.dart';

class SCEStats extends StatefulWidget {
  const SCEStats({super.key});

  @override
  State<SCEStats> createState() => _SCEStatsState();
}

class _SCEStatsState extends State<SCEStats> {
  @override
  Widget build(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    SCEModel scemodel = Provider.of<SCEModel>(context);
    return ListView(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      children: [
        _body(context, scemodel, dmodel),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _body(BuildContext context, SCEModel scemodel, DataModel dmodel) {
    return Column(
      children: [
        const SizedBox(height: 16),
        XCCellList<Widget>(
          childPadding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            XCLabeledWidget(
              "Allow Stats",
              child: Row(
                children: [
                  FlutterSwitch(
                    value: scemodel.hasStats,
                    height: 25,
                    width: 50,
                    toggleSize: 18,
                    activeColor: dmodel.color,
                    onToggle: (value) {
                      setState(() {
                        scemodel.hasStats = value;
                      });
                    },
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ],
        ),
        XCSection(
          "Stats",
          headerPadding: const EdgeInsets.fromLTRB(32, 8, 16, 4),
          color: dmodel.color,
          helperView: (context) {
            return Column(
              children: const [
                XCSection(
                  "Stats",
                  child: Text(
                      "Stats can be added and removed at will, and these stats will be tracked for every game you create. But, if you remove a stat from this list later, every user will lose this stat field forever, and the information cannot be re-attained."),
                )
              ],
            );
          },
          child: StatCEList(
            color: dmodel.color,
            stats: scemodel.stats,
          ),
        ),
      ],
    );
  }
}

import 'package:crosscheck_sports/client/root.dart';
import 'package:crosscheck_sports/custom_views/timezone_select.dart';
import 'package:crosscheck_sports/extras/root.dart';
import 'package:crosscheck_sports/views/shared/positions_create.dart';
import 'package:crosscheck_sports/views/tsce/tsce_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:provider/provider.dart';
import '../../../custom_views/root.dart' as cv;
import '../components/root.dart' as comp;

class TSCEAdditional extends StatefulWidget {
  const TSCEAdditional({super.key});

  @override
  State<TSCEAdditional> createState() => _TSCEAdditionalState();
}

class _TSCEAdditionalState extends State<TSCEAdditional> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      children: [
        _body(context),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _body(BuildContext context) {
    var dmodel = Provider.of<DataModel>(context);
    var model = Provider.of<TSCEModel>(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          cv.Section(
            "Positions",
            allowsCollapse: true,
            initOpen: !model.autoPositions,
            child: Column(
              children: [
                comp.ListWrapper(
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          "Source From Roster",
                          style: TextStyle(
                            fontSize: 16,
                            color: CustomColors.textColor(context)
                                .withOpacity(0.7),
                          ),
                        ),
                      ),
                      FlutterSwitch(
                        value: model.autoPositions,
                        height: 25,
                        width: 50,
                        toggleSize: 18,
                        activeColor: dmodel.color,
                        onToggle: (value) {
                          setState(() {
                            model.autoPositions = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                IgnorePointer(
                  ignoring: model.autoPositions,
                  child: Opacity(
                    opacity: model.autoPositions ? 0.5 : 1,
                    child: PositionsCreate(
                      positions: model.positions,
                      horizontalPadding: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

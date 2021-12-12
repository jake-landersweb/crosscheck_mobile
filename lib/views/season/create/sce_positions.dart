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
    required this.model,
    required this.team,
  }) : super(key: key);
  final SCEModel model;
  final Team team;

  @override
  _SCEPositionsState createState() => _SCEPositionsState();
}

class _SCEPositionsState extends State<SCEPositions> {
  @override
  void initState() {
    widget.model.index += 1;
    super.initState();
  }

  @override
  void dispose() {
    widget.model.index -= 1;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    return Stack(
      alignment: AlignmentDirectional.bottomCenter,
      children: [
        cv.AppBar(
          title: "Positions",
          isLarge: false,
          backgroundColor: CustomColors.backgroundColor(context),
          childPadding: const EdgeInsets.fromLTRB(0, 15, 0, 45),
          itemBarPadding: const EdgeInsets.fromLTRB(8, 0, 15, 8),
          leading: [
            cv.BackButton(
              color: dmodel.color,
            )
          ],
          color: dmodel.color,
          children: [_body(context, dmodel)],
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 48.0),
          child: _next(context, dmodel),
        ),
      ],
    );
  }

  Widget _body(BuildContext context, DataModel dmodel) {
    return Column(
      children: [
        widget.model.status(context, dmodel),
        const SizedBox(height: 16),
        _pos(context, dmodel),
        const SizedBox(height: 48),
      ],
    );
  }

  Widget _pos(BuildContext context, DataModel dmodel) {
    return cv.Section(
      "Positions",
      headerPadding: const EdgeInsets.fromLTRB(32, 8, 8, 4),
      child: PositionsCreate(positions: widget.model.positions),
    );
  }

  Widget _next(BuildContext context, DataModel dmodel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: cv.BasicButton(
        onTap: () {
          cv.Navigate(
              context, SCECustomF(model: widget.model, team: widget.team));
        },
        child: Material(
          shape: ContinuousRectangleBorder(
              borderRadius: BorderRadius.circular(35)),
          color: CustomColors.cellColor(context),
          child: const SizedBox(
            height: cellHeight,
            child: Center(
              child: Text(
                "Next",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

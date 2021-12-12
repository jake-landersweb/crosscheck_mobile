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
import 'root.dart';

class SCEStats extends StatefulWidget {
  const SCEStats({
    Key? key,
    required this.team,
    required this.model,
  }) : super(key: key);
  final Team team;
  final SCEModel model;

  @override
  _SCEStatsState createState() => _SCEStatsState();
}

class _SCEStatsState extends State<SCEStats> {
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
        _isActive(context, dmodel),
        const SizedBox(height: 16),
        _statList(context, dmodel),
      ],
    );
  }

  Widget _isActive(BuildContext context, DataModel dmodel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: cv.NativeList(
        children: [
          cv.LabeledWidget(
            "Is Active",
            height: cellHeight,
            child: FlutterSwitch(
              value: widget.model.stats.isActive,
              height: 25,
              width: 50,
              toggleSize: 18,
              activeColor: dmodel.color,
              onToggle: (value) {
                setState(() {
                  widget.model.stats.isActive = value;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _statList(BuildContext context, DataModel dmodel) {
    return Column(
      children: [
        cv.AnimatedList<StatItem>(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          buttonPadding: 20,
          children: widget.model.stats.stats,
          cellBuilder: (BuildContext context, StatItem item) {
            // return CustomFieldField(item: item);
            return StatCell(item: item, model: widget.model);
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: cv.BasicButton(
            onTap: () {
              setState(() {
                widget.model.stats.stats.add(StatItem.empty());
              });
            },
            child: const cv.NativeList(
              children: [
                SizedBox(
                  height: 40,
                  child: Center(
                    child: Text(
                      "Add new",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _next(BuildContext context, DataModel dmodel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: cv.BasicButton(
        onTap: () {
          cv.Navigate(
              context, SCEUsers(model: widget.model, team: widget.team));
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

class StatCell extends StatefulWidget {
  const StatCell({
    Key? key,
    required this.item,
    required this.model,
  }) : super(key: key);
  final StatItem item;
  final SCEModel model;

  @override
  _StatCellState createState() => _StatCellState();
}

class _StatCellState extends State<StatCell> {
  @override
  Widget build(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    return Column(
      children: [
        cv.TextField(
          fieldPadding: EdgeInsets.zero,
          labelText: "Title",
          onChanged: (value) {
            setState(() {
              widget.item.setTitle(value);
            });
          },
          validator: (value) {},
          isLabeled: true,
        ),
        const Divider(height: 0.5, indent: 15),
        cv.LabeledWidget(
          "Default Value",
          child: Row(
            children: [
              SizedBox(
                width: 50,
                child: Center(
                  child: Text(
                    widget.item.getValue(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              cv.NumberPicker(
                minValue: -100,
                maxValue: 100,
                onMinusClick: (value) {
                  setState(() {
                    widget.item.setValue(value);
                  });
                },
                onPlusClick: (value) {
                  setState(() {
                    widget.item.setValue(value);
                  });
                },
              ),
            ],
          ),
        ),
        const Divider(height: 0.5, indent: 15),
        cv.LabeledWidget(
          "Is Active",
          height: cellHeight,
          child: FlutterSwitch(
            value: widget.item.isActive,
            height: 25,
            width: 50,
            toggleSize: 18,
            activeColor: dmodel.color,
            onToggle: (value) {
              setState(() {
                widget.item.isActive = value;
              });
            },
          ),
        ),
      ],
    );
  }
}

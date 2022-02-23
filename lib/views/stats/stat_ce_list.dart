import 'package:flutter/material.dart';
import 'package:pnflutter/client/root.dart';
import 'package:pnflutter/data/root.dart';
import 'package:pnflutter/extras/root.dart';
import 'package:pnflutter/views/root.dart';
import 'package:provider/provider.dart';
import '../../custom_views/root.dart' as cv;

class StatCEList extends StatefulWidget {
  const StatCEList({
    Key? key,
    required this.team,
    required this.stats,
    this.color = Colors.blue,
  }) : super(key: key);
  final Team team;
  final TeamStat stats;
  final Color color;

  @override
  _StatCEListState createState() => _StatCEListState();
}

class _StatCEListState extends State<StatCEList> {
  @override
  Widget build(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    return Column(
      children: [
        cv.ListView(
          isAnimated: true,
          allowsDelete: true,
          onDelete: (StatItem stat) {
            setState(() {
              widget.stats.stats
                  .removeWhere((element) => element.title == stat.title);
            });
          },
          childBuilder: (context, StatItem stat) {
            return cv.LabeledCell(
                padding: EdgeInsets.zero,
                value:
                    "${stat.title[0].toUpperCase()}${stat.title.substring(1)}",
                label: "Title");
          },
          children: widget.stats.stats,
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: cv.AddField(
            labelText: "New Stat ...",
            iconColor: dmodel.color,
            validator: (value) {
              if (value == "") {
                dmodel
                    .addIndicator(IndicatorItem.error("Stat cannot be empty"));
                return false;
              } else if (widget.stats.stats.any((element) =>
                  element.title.toLowerCase() == value.toLowerCase())) {
                dmodel.addIndicator(
                    IndicatorItem.error("This stat already exists"));
                return false;
              } else {
                return true;
              }
            },
            onCommit: (value) {
              setState(() {
                widget.stats.addStat(value);
              });
            },
          ),
        ),
      ],
    );
  }
}

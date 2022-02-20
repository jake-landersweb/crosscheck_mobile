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
  late TextEditingController _controller;

  @override
  void initState() {
    _controller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    return Column(
      children: [
        cv.AnimatedList<StatItem>(
          padding: EdgeInsets.zero,
          cellBuilder: (context, stat) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(0, 4, 0, 4),
              child: cv.LabeledCell(
                  value:
                      "${stat.title[0].toUpperCase()}${stat.title.substring(1)}",
                  label: "Title"),
            );
          },
          children: widget.stats.stats,
        ),
        const SizedBox(height: 16),
        ClipRRect(
          borderRadius: BorderRadius.circular(25),
          child: Container(
            color: CustomColors.cellColor(context),
            child: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Row(
                children: [
                  Expanded(
                    child: cv.TextField(
                      labelText: "New Stat Title",
                      controller: _controller,
                      showBackground: false,
                      onChanged: (value) {},
                      validator: (value) => null,
                    ),
                  ),
                  cv.BasicButton(
                    onTap: () {
                      if (_controller.text.isNotEmpty &&
                          !widget.stats.stats.any((element) =>
                              element.title ==
                              _controller.text.toLowerCase())) {
                        setState(() {
                          widget.stats.addStat(_controller.text.toLowerCase());
                          _controller.text = "";
                        });
                      } else {
                        dmodel.addIndicator(
                            IndicatorItem.error("Invalid Stat Title"));
                      }
                    },
                    child: Container(
                      color: widget.color,
                      height: 50,
                      child: const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            "Add",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

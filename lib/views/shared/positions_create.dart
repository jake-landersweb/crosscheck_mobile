import 'package:flutter/material.dart';
import '../../data/root.dart';
import '../../custom_views/root.dart' as cv;
import 'package:flutter_switch/flutter_switch.dart';
import '../../client/root.dart';
import 'package:provider/provider.dart';
import '../../extras/root.dart';

class PositionsCreate extends StatefulWidget {
  const PositionsCreate({
    Key? key,
    required this.positions,
  }) : super(key: key);
  final TeamPositions positions;

  @override
  _PositionsCreateState createState() => _PositionsCreateState();
}

class _PositionsCreateState extends State<PositionsCreate> {
  String _newPos = "";

  @override
  Widget build(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    return Column(
      children: [
        cv.NativeList(
          children: [
            cv.LabeledWidget(
              "Is Active",
              height: cellHeight,
              child: FlutterSwitch(
                value: widget.positions.isActive,
                height: 25,
                width: 50,
                toggleSize: 18,
                activeColor: dmodel.color,
                onToggle: (value) {
                  setState(() {
                    widget.positions.isActive = value;
                  });
                },
              ),
            ),
          ],
        ),
        cv.Section(
          "Available Positions",
          child: cv.AnimatedList<String>(
            padding: EdgeInsets.zero,
            childPadding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
            children: widget.positions.available,
            allowTap: true,
            onTap: (item) {
              setState(() {
                widget.positions.defaultPosition = item;
              });
            },
            cellBuilder: (context, item) {
              return SizedBox(
                height: cellHeight,
                child: Center(
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          item,
                          style: const TextStyle(
                              fontWeight: FontWeight.w500, fontSize: 16),
                        ),
                      ),
                      if (widget.positions.defaultPosition == item)
                        Text(
                          "Default",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: MediaQuery.of(context).platformBrightness ==
                                    Brightness.light
                                ? Colors.black.withOpacity(0.5)
                                : Colors.white.withOpacity(0.5),
                          ),
                        ),
                      const SizedBox(width: 8),
                      Icon(
                        widget.positions.defaultPosition == item
                            ? Icons.radio_button_checked
                            : Icons.circle,
                        color: widget.positions.defaultPosition == item
                            ? dmodel.color
                            : CustomColors.textColor(context).withOpacity(0.5),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              cv.TextField(
                labelText: "Position",
                onChanged: (value) {
                  setState(() {
                    _newPos = value;
                  });
                },
                validator: (value) {},
              ),
              const SizedBox(height: 16),
              cv.RoundedLabel(
                "Add New",
                color: CustomColors.cellColor(context),
                textColor: CustomColors.textColor(context),
                onTap: () {
                  if (_newPos.isEmpty) {
                    dmodel.addIndicator(IndicatorItem.error(
                        "New position title cannot be empty"));
                  } else if (widget.positions.available.contains(_newPos)) {
                    dmodel.addIndicator(
                        IndicatorItem.error("This position already exists"));
                  } else if (widget.positions.available.length > 20) {
                    dmodel.addIndicator(
                        IndicatorItem.error("Max of 20 positions"));
                  } else {
                    setState(() {
                      widget.positions.available.add(_newPos);
                    });
                    if (widget.positions.available.length == 1) {
                      setState(() {
                        widget.positions.defaultPosition = _newPos;
                      });
                    }
                  }
                },
              )
            ],
          ),
        )
      ],
    );
  }
}

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
  @override
  Widget build(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    return Column(
      children: [
        cv.ListView(
          children: widget.positions.available,
          isAnimated: true,
          allowsDelete: true,
          onDelete: (String value) {
            setState(() {
              widget.positions.removePosition(value);
            });
          },
          onChildTap: (context, String item) {
            setState(() {
              widget.positions.defaultPosition = item;
            });
          },
          childBuilder: (context, String item) {
            return Row(
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
                      color: Theme.of(context).brightness == Brightness.light
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
            );
          },
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: cv.AddField(
            labelText: "New Position ...",
            iconColor: dmodel.color,
            validator: (value) {
              if (value == "") {
                dmodel.addIndicator(
                    IndicatorItem.error("Position cannot be empty"));
                return false;
              } else if (widget.positions.available.any(
                  (element) => element.toLowerCase() == value.toLowerCase())) {
                dmodel.addIndicator(
                    IndicatorItem.error("This position already exists"));
                return false;
              } else {
                return true;
              }
            },
            onCommit: (value) {
              setState(() {
                widget.positions.available.add(value);
              });
            },
          ),
        )
      ],
    );
  }
}

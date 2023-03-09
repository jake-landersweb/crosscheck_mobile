import 'package:flutter/material.dart';
import '../../data/root.dart';
import '../../custom_views/root.dart' as cv;
import 'package:flutter_switch/flutter_switch.dart';
import '../../client/root.dart';
import 'package:provider/provider.dart';
import '../../extras/root.dart';
import 'package:crosscheck_sports/extras/root.dart';

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
          animateOpen: false,
          onDelete: (String value) async {
            setState(() {
              widget.positions.removePosition(value);
            });
            if (!widget.positions.available
                    .contains(widget.positions.defaultPosition) &&
                widget.positions.available.isNotEmpty) {
              setState(() {
                widget.positions.setDefault(widget.positions.available.first);
              });
            }
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
                    item.capitalize(),
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      color: CustomColors.textColor(context),
                    ),
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
                      : Icons.circle_outlined,
                  color: widget.positions.defaultPosition == item
                      ? dmodel.color
                      : CustomColors.textColor(context).withOpacity(0.3),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: cv.AddField(
            labelText: "New Position",
            iconColor: dmodel.color,
            limit: 30,
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
              if (widget.positions.available.length == 1) {
                setState(() {
                  widget.positions.setDefault(value);
                });
              }
            },
          ),
        ),
        const SizedBox(height: 16),
        if (widget.positions.available.isNotEmpty)
          cv.Section(
            "Most Valuable Position",
            headerPadding: const EdgeInsets.fromLTRB(32, 8, 0, 4),
            color: dmodel.color,
            helperView: (context) {
              return Column(
                children: const [
                  cv.Section(
                    "Most Valuable Position",
                    child: Text(
                        "Sometimes you have a position on your team that events just cannot work without. This is where you define that. A small icon will show next to users who are this position, along with extra event functionality when a user with this position is checked in."),
                  )
                ],
              );
            },
            child: cv.BasicButton(
              onTap: () {
                cv.showFloatingSheet(
                    context: context,
                    builder: (context) {
                      return cv.ModelSelector<String>(
                        title: "Select Position",
                        color: dmodel.color,
                        initialSelection: widget.positions.mvp,
                        selections: widget.positions.available + [""],
                        titles: widget.positions.available + ["None"],
                        onSelection: (val) {
                          setState(() {
                            widget.positions.setMVP(val);
                          });
                        },
                      );
                    });
              },
              child: cv.ListView<Widget>(
                horizontalPadding: 16,
                children: [
                  Center(
                    child: Text(
                      widget.positions.mvp.isEmpty
                          ? "None"
                          : widget.positions.mvp,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 18,
                        color: CustomColors.textColor(context).withOpacity(0.5),
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
}

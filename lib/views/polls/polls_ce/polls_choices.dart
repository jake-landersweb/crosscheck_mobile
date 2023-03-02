import 'package:crosscheck_sports/client/root.dart';
import 'package:crosscheck_sports/data/indicator_item.dart';
import 'package:crosscheck_sports/extras/root.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:provider/provider.dart';
import 'package:sprung/sprung.dart';
import 'root.dart';
import 'package:crosscheck_sports/custom_views/root.dart' as cv;
import '../../components/root.dart' as comp;

class PollsChoices extends StatefulWidget {
  const PollsChoices({Key? key}) : super(key: key);

  @override
  State<PollsChoices> createState() => _PollsChoicesState();
}

class _PollsChoicesState extends State<PollsChoices> {
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
    PollsModel pmodel = Provider.of<PollsModel>(context);
    DataModel dmodel = Provider.of<DataModel>(context);
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      shrinkWrap: true,
      children: [
        Column(
          children: [
            const SizedBox(height: 16),
            if (pmodel.isCreate)
              cv.SegmentedPicker(
                titles: const ["True / False", "Selection"],
                selections: const [1, 2],
                selection: pmodel.poll.pollType,
                style: comp.segmentedPickerStyle(context, dmodel),
                onSelection: (val) {
                  setState(() {
                    pmodel.poll.pollType = val;
                    if (val == 1) {
                      pmodel.poll.choices = ["True", "False"];
                    } else {
                      pmodel.poll.choices = [];
                    }
                  });
                },
              ),
            if (pmodel.isCreate)
              cv.Section(
                "Choices",
                child: _selection(context, pmodel),
              ),
            const SizedBox(height: 8),
            cv.ListView<Widget>(
              horizontalPadding: 0,
              childPadding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                cv.LabeledWidget(
                  "Show Responses",
                  child: Row(
                    children: [
                      FlutterSwitch(
                        value: pmodel.poll.showResponses,
                        height: 25,
                        width: 50,
                        toggleSize: 18,
                        activeColor: dmodel.color,
                        onToggle: (value) {
                          setState(() {
                            pmodel.poll.showResponses = value;
                          });
                        },
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
                cv.LabeledWidget(
                  "Show Results",
                  child: Row(
                    children: [
                      FlutterSwitch(
                        value: pmodel.poll.showResults,
                        height: 25,
                        width: 50,
                        toggleSize: 18,
                        activeColor: dmodel.color,
                        onToggle: (value) {
                          setState(() {
                            pmodel.poll.showResults = value;
                          });
                        },
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _selection(BuildContext context, PollsModel pmodel) {
    DataModel dmodel = Provider.of<DataModel>(context);
    return Column(
      children: [
        cv.ListView<String>(
          children: pmodel.poll.choices,
          horizontalPadding: 0,
          isAnimated: true,
          animateOpen: false,
          allowsDelete: pmodel.poll.pollType != 1,
          onDelete: ((p0) async {
            setState(() {
              pmodel.poll.choices.removeWhere((element) => element == p0);
            });
          }),
          childBuilder: (context, val) {
            return Text(
              val,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        if (pmodel.poll.pollType != 1)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: cv.AddField(
              labelText: "New Choice",
              iconColor: dmodel.color,
              validator: (value) {
                if (value == "") {
                  dmodel.addIndicator(
                      IndicatorItem.error("Poll item cannot be empty"));
                  return false;
                } else if (pmodel.poll.choices.any((element) =>
                    element.toLowerCase() == value.toLowerCase())) {
                  dmodel.addIndicator(
                      IndicatorItem.error("This poll item already exists"));
                  return false;
                } else {
                  return true;
                }
              },
              onCommit: (value) {
                setState(() {
                  pmodel.poll.choices.add(value);
                });
              },
            ),
          ),
      ],
    );
  }
}

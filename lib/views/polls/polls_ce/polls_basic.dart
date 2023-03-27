import 'package:crosscheck_sports/client/root.dart';
import 'package:crosscheck_sports/data/indicator_item.dart';
import 'package:crosscheck_sports/extras/root.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'root.dart';
import 'package:crosscheck_sports/custom_views/root.dart' as cv;

class PollsBasic extends StatefulWidget {
  const PollsBasic({
    Key? key,
    required this.onAction,
  }) : super(key: key);
  final VoidCallback onAction;

  @override
  State<PollsBasic> createState() => _PollsBasicState();
}

class _PollsBasicState extends State<PollsBasic> {
  bool _isloading = false;
  @override
  Widget build(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    PollsModel pmodel = Provider.of<PollsModel>(context);
    return ListView(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      children: [
        Column(
          children: [
            cv.Section(
              "Date",
              headerPadding: const EdgeInsets.fromLTRB(32, 8, 0, 4),
              child: cv.ListView<Widget>(
                childPadding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _pollDate(context, dmodel, pmodel),
                ],
              ),
            ),
            cv.Section(
              "Title - Required",
              headerPadding: const EdgeInsets.fromLTRB(32, 8, 0, 4),
              child: cv.ListView<Widget>(
                childPadding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  cv.TextField2(
                    labelText: "Title",
                    hintText: "Where for dinner tonight?",
                    highlightColor: dmodel.color,
                    onChanged: (value) {
                      setState(() {
                        pmodel.poll.title = value;
                      });
                    },
                    showBackground: false,
                    value: pmodel.poll.title,
                    isLabeled: false,
                  ),
                ],
              ),
            ),
            cv.Section(
              "Description",
              headerPadding: const EdgeInsets.fromLTRB(32, 8, 0, 4),
              child: cv.ListView<Widget>(
                childPadding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  cv.TextField2(
                    labelText: "Please select your favorite place!",
                    isLabeled: false,
                    maxLines: 5,
                    highlightColor: dmodel.color,
                    onChanged: (value) {
                      setState(() {
                        pmodel.poll.description = value;
                      });
                    },
                    showBackground: false,
                    value: pmodel.poll.description,
                  ),
                ],
              ),
            ),
            // delete
            const SizedBox(height: 16),
            if (!pmodel.isCreate)
              Padding(
                padding: const EdgeInsets.all(32.0),
                child: cv.RoundedLabel(
                  "Delete",
                  color: Colors.red.withOpacity(0.5),
                  textColor: Colors.white,
                  isLoading: _isloading,
                  onTap: () {
                    cv.showAlert(
                        context: context,
                        title: "Are You Sure",
                        body: const Text(
                            "Are you sure you want to delete this poll? This action cannot be reversed"),
                        cancelText: "Cancel",
                        onCancel: () {},
                        submitText: "Delete",
                        submitBolded: true,
                        submitColor: Colors.red,
                        onSubmit: () => _deletePoll(context, pmodel, dmodel));
                  },
                ),
              )
          ],
        ),
      ],
    );
  }

  Widget _pollDate(BuildContext context, DataModel dmodel, PollsModel pmodel) {
    return cv.LabeledWidget(
      "Poll Date",
      child: Row(
        children: [
          cv.BasicButton(
            onTap: () {
              cv.showFloatingSheet(
                context: context,
                builder: (context) => _datePicker(context, dmodel, pmodel),
              );
            },
            child: Material(
              color: CustomColors.textColor(context).withOpacity(0.2),
              shape: ContinuousRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  dateToString(pmodel.time).getDate(),
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ),
          const SizedBox(width: 7),
          cv.BasicButton(
            onTap: () {
              cv.showFloatingSheet(
                context: context,
                builder: (context) => _timePicker(context, dmodel, pmodel),
              );
            },
            child: Material(
              color: CustomColors.textColor(context).withOpacity(0.2),
              shape: ContinuousRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  dateToString(pmodel.time).getTime()[0] == "0"
                      ? dateToString(pmodel.time).getTime().substring(1)
                      : dateToString(pmodel.time).getTime(),
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _datePicker(
      BuildContext context, DataModel dmodel, PollsModel pmodel) {
    return cv.Sheet(
      title: "Event Date",
      color: dmodel.color,
      child: SfDateRangePicker(
        todayHighlightColor: dmodel.color,
        selectionColor: dmodel.color,
        selectionMode: DateRangePickerSelectionMode.single,
        initialDisplayDate: pmodel.time,
        initialSelectedDate: pmodel.time,
        selectionTextStyle: const TextStyle(color: Colors.white),
        onSelectionChanged: (args) {
          // set the date
          if (args.value is DateTime) {
            setState(() {
              DateTime d = args.value;
              pmodel.time = DateTime(d.year, d.month, d.day, pmodel.time.hour,
                  pmodel.time.minute, 0);
            });
          } else {
            dmodel.addIndicator(
                IndicatorItem.error("There was an issue selecting this date"));
          }
          // close the menu
          Navigator.of(context).pop();
        },
      ),
    );
  }

  Widget _timePicker(
      BuildContext context, DataModel dmodel, PollsModel pmodel) {
    return cv.Sheet(
      title: "Event Time",
      color: dmodel.color,
      child: cv.TimePicker(
        initialDate: pmodel.time,
        timePickerMode: cv.TimePickerMode.text,
        padding: const EdgeInsets.only(top: 16),
        accentColor: dmodel.color,
        onSelection: (date) {
          print(date);
          setState(() {
            pmodel.time = date;
          });
          Navigator.of(context).pop();
        },
        onCancel: () {
          Navigator.of(context).pop();
        },
      ),
    );
  }

  Future<void> _deletePoll(
      BuildContext context, PollsModel pmodel, DataModel dmodel) async {
    setState(() {
      _isloading = true;
    });

    await dmodel.deletePoll(
      pmodel.team.teamId,
      pmodel.season.seasonId,
      pmodel.poll.sortKey,
      () async {
        // reload the homescreen
        Navigator.of(context, rootNavigator: true).pop();
        Navigator.of(context, rootNavigator: true).pop();
        setState(() {
          dmodel.isScaled = false;
        });
        widget.onAction();
      },
    );

    setState(() {
      _isloading = false;
    });
  }
}

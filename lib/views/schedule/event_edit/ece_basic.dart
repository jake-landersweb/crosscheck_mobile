import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:pnflutter/extras/root.dart';
import 'root.dart';
import '../../../client/root.dart';
import 'package:provider/provider.dart';
import '../../../custom_views/root.dart' as cv;
import 'package:sprung/sprung.dart';

class ECEBasic extends StatefulWidget {
  const ECEBasic({Key? key}) : super(key: key);

  @override
  _ECEBasicState createState() => _ECEBasicState();
}

class _ECEBasicState extends State<ECEBasic> {
  @override
  Widget build(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    ECEModel ecemodel = Provider.of<ECEModel>(context);
    return ListView(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      children: [
        _required(context, dmodel, ecemodel),
        _config(context, dmodel, ecemodel),
      ],
    );
  }

  Widget _required(BuildContext context, DataModel dmodel, ECEModel ecemodel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          if (ecemodel.isCreate)
            cv.Section(
              "Type",
              child: cv.SegmentedPicker<int>(
                initialSelection: ecemodel.event.eventType,
                titles: const ["Game", "Practice", "Other"],
                selections: const [1, 2, 0],
                onSelection: (value) {
                  setState(() {
                    ecemodel.event.eventType = value;
                  });
                },
              ),
            ),
          cv.Section(
            "Required",
            child: Column(
              children: [
                cv.NativeList(
                  itemPadding: EdgeInsets.zero,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: _eventDate(context, dmodel, ecemodel),
                    ),
                    _title(context, dmodel, ecemodel),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _eventDate(BuildContext context, DataModel dmodel, ECEModel ecemodel) {
    return cv.LabeledWidget(
      "Event Date",
      child: Row(
        children: [
          cv.BasicButton(
            onTap: () {
              DatePicker.showDatePicker(
                context,
                showTitleActions: true,
                minTime: DateTime(2018, 3, 5),
                maxTime: DateTime(2023, 6, 7),
                theme: DatePickerTheme(
                  backgroundColor: CustomColors.cellColor(context),
                  doneStyle: TextStyle(color: dmodel.color, fontSize: 18),
                  cancelStyle: TextStyle(
                      color: CustomColors.textColor(context).withOpacity(0.5),
                      fontSize: 14),
                  itemStyle: TextStyle(
                    color: CustomColors.textColor(context),
                  ),
                ),
                onChanged: (date) {
                  print('change $date');
                },
                onConfirm: (date) {
                  print('confirm $date');
                  setState(() {
                    ecemodel.eventDate = DateTime(
                        date.year,
                        date.month,
                        date.day,
                        ecemodel.eventDate.hour,
                        ecemodel.eventDate.minute);
                  });
                },
                currentTime: ecemodel.eventDate,
                locale: LocaleType.en,
              );
            },
            child: Material(
              color: CustomColors.textColor(context).withOpacity(0.2),
              shape: ContinuousRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  dateToString(ecemodel.eventDate).getDate(),
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ),
          const SizedBox(width: 7),
          cv.BasicButton(
            onTap: () {
              DatePicker.showTimePicker(
                context,
                showSecondsColumn: false,
                showTitleActions: true,
                theme: DatePickerTheme(
                  backgroundColor: CustomColors.cellColor(context),
                  doneStyle: TextStyle(color: dmodel.color, fontSize: 18),
                  cancelStyle: TextStyle(
                      color: CustomColors.textColor(context).withOpacity(0.5),
                      fontSize: 14),
                  itemStyle: TextStyle(
                    color: CustomColors.textColor(context),
                  ),
                ),
                onChanged: (date) {
                  print('change $date');
                },
                onConfirm: (date) {
                  print('confirm $date');
                  setState(() {
                    ecemodel.eventDate = date;
                  });
                },
                currentTime: ecemodel.eventDate,
                locale: LocaleType.en,
              );
            },
            child: Material(
              color: CustomColors.textColor(context).withOpacity(0.2),
              shape: ContinuousRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  dateToString(ecemodel.eventDate).getTime()[0] == "0"
                      ? dateToString(ecemodel.eventDate).getTime().substring(1)
                      : dateToString(ecemodel.eventDate).getTime(),
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _title(BuildContext context, DataModel dmodel, ECEModel ecemodel) {
    return cv.NativeList(
      itemPadding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        (ecemodel.event.eventType == 1)
            ? cv.TextField(
                labelText: "Opponent",
                showBackground: false,
                fieldPadding: EdgeInsets.zero,
                value: ecemodel.opponentName,
                isLabeled: true,
                onChanged: (value) {
                  setState(() {
                    ecemodel.opponentName = value;
                  });
                },
                validator: (value) {},
              )
            : cv.TextField(
                labelText: "Title",
                showBackground: false,
                fieldPadding: EdgeInsets.zero,
                isLabeled: true,
                value: ecemodel.event.eTitle,
                onChanged: (value) {
                  setState(() {
                    ecemodel.event.eTitle = value;
                  });
                },
                validator: (value) {},
              ),
      ],
    );
  }

  Widget _config(BuildContext context, DataModel dmodel, ECEModel ecemodel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: cv.Section(
        "Config",
        child: cv.NativeList(
          itemPadding: EdgeInsets.zero,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: cv.TextField(
                labelText: "Description",
                onChanged: (value) {
                  setState(() {
                    ecemodel.event.eDescription = value;
                  });
                },
                validator: (value) {},
                showBackground: false,
                value: ecemodel.event.eDescription,
                isLabeled: true,
              ),
            ),
            if (ecemodel.isCreate)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: cv.LabeledWidget(
                  "Track Attendance",
                  child: FlutterSwitch(
                    value: ecemodel.event.hasAttendance,
                    height: 25,
                    width: 50,
                    toggleSize: 18,
                    activeColor: dmodel.color,
                    onToggle: (value) {
                      setState(() {
                        ecemodel.event.hasAttendance = value;
                      });
                    },
                  ),
                ),
              ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 700),
              height: ecemodel.event.hasAttendance ? 50 : 0,
              curve: Sprung.overDamped,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: cv.LabeledWidget(
                  "Show Attendance",
                  child: FlutterSwitch(
                    value: ecemodel.event.showAttendance,
                    height: 25,
                    width: 50,
                    toggleSize: 18,
                    activeColor: dmodel.color,
                    onToggle: (value) {
                      setState(() {
                        ecemodel.event.showAttendance = value;
                      });
                    },
                  ),
                ),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 700),
              height: ecemodel.event.isHome() ? 50 : 0,
              curve: Sprung.overDamped,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: cv.LabeledWidget(
                  "Home Team",
                  child: FlutterSwitch(
                    value: ecemodel.isHome,
                    height: 25,
                    width: 50,
                    toggleSize: 18,
                    activeColor: dmodel.color,
                    onToggle: (value) {
                      setState(() {
                        ecemodel.isHome = value;
                      });
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:ui';
import 'package:crosscheck_sports/data/indicator_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:crosscheck_sports/extras/root.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'root.dart';
import '../../../client/root.dart';
import 'package:provider/provider.dart';
import '../../../custom_views/root.dart' as cv;
import 'package:sprung/sprung.dart';
import '../../components/root.dart' as comp;

class ECEBasic extends StatefulWidget {
  const ECEBasic({Key? key}) : super(key: key);

  @override
  _ECEBasicState createState() => _ECEBasicState();
}

class _ECEBasicState extends State<ECEBasic> {
  bool _isLoading = false;

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
        if (!ecemodel.isCreate) _delete(context, dmodel, ecemodel),
        const SizedBox(height: 100),
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
              color: dmodel.color,
              helperView: (context) {
                return Column(
                  children: const [
                    cv.Section(
                      "Type",
                      child: Text(
                          "Games will store extra information like opponent name, score, and stats for all users. The other types will be more basic of a shape."),
                    )
                  ],
                );
              },
              child: cv.SegmentedPicker<int>(
                selection: ecemodel.event.eventType,
                titles: const ["Game", "Practice", "Other"],
                selections: const [1, 2, 0],
                style: comp.segmentedPickerStyle(context, dmodel),
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
                if (ecemodel.event.isCalendarEvent)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: CustomColors.cellColor(context),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: cv.LabeledWidget(
                          "Auto-Sync",
                          child: Row(
                            children: [
                              FlutterSwitch(
                                value: ecemodel.event.autoUpdateFromSync,
                                height: 25,
                                width: 50,
                                toggleSize: 18,
                                activeColor: dmodel.color,
                                onToggle: (value) async {
                                  setState(() {
                                    ecemodel.event.autoUpdateFromSync = value;
                                  });
                                },
                              ),
                              const Spacer(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                AbsorbPointer(
                  absorbing: ecemodel.event.autoUpdateFromSync,
                  child: Opacity(
                    opacity: ecemodel.event.autoUpdateFromSync ? 0.5 : 1,
                    child: _title(context, dmodel, ecemodel),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: AbsorbPointer(
                    absorbing: ecemodel.event.autoUpdateFromSync,
                    child: Opacity(
                      opacity: ecemodel.event.autoUpdateFromSync ? 0.5 : 1,
                      child: _eventDate(context, dmodel, ecemodel),
                    ),
                  ),
                ),
                if (ecemodel.event.eventType == 1 &&
                    !ecemodel.event.autoUpdateFromSync)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: cv.Section(
                      "Previous Opponents",
                      allowsCollapse: true,
                      initOpen: false,
                      child: cv.ListView<String>(
                        animateOpen: true,
                        isAnimated: true,
                        childPadding: EdgeInsets.zero,
                        horizontalPadding: 0,
                        children: ecemodel.season.opponents,
                        showStyling: false,
                        hasDividers: false,
                        childBuilder: ((context, item) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: cv.BasicButton(
                                    onTap: () {
                                      setState(() {
                                        ecemodel.event.overrideTitle = false;
                                        print("SWITCHING TO OPPONENT NAME NOW");
                                        ecemodel.titleController.text = item;
                                      });
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: CustomColors.cellColor(context),
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(10),
                                          bottomLeft: Radius.circular(10),
                                        ),
                                      ),
                                      width: double.infinity,
                                      child: ConstrainedBox(
                                        constraints:
                                            const BoxConstraints(minHeight: 50),
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(left: 16.0),
                                          child: Center(
                                            child: Text(
                                              item,
                                              style: TextStyle(
                                                color: CustomColors.textColor(
                                                    context),
                                                fontWeight: FontWeight.w500,
                                                fontSize: 18,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                cv.BasicButton(
                                  onTap: () async {
                                    await ecemodel.removeOpponentTitle(
                                      dmodel,
                                      item,
                                    );
                                  },
                                  child: Container(
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: dmodel.color.withOpacity(0.3),
                                      borderRadius: const BorderRadius.only(
                                        topRight: Radius.circular(10),
                                        bottomRight: Radius.circular(10),
                                      ),
                                    ),
                                    child: AspectRatio(
                                      aspectRatio: 1,
                                      child: ecemodel.loadingOpponent == item
                                          ? cv.LoadingIndicator(
                                              color: dmodel.color)
                                          : Icon(
                                              Icons.close,
                                              color: dmodel.color,
                                            ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _eventDate(BuildContext context, DataModel dmodel, ECEModel ecemodel) {
    return Row(
      children: [
        Expanded(
          child: cv.BasicButton(
            onTap: () {
              cv.showFloatingSheet(
                context: context,
                builder: (context) => _datePicker(context, dmodel, ecemodel),
              );
            },
            child: Container(
              constraints: const BoxConstraints(minHeight: 50),
              decoration: BoxDecoration(
                color: CustomColors.cellColor(context),
                borderRadius: BorderRadius.circular(10),
              ),
              width: double.infinity,
              child: Row(
                children: [
                  const SizedBox(width: 8),
                  Icon(Icons.calendar_month_rounded, color: dmodel.color),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      dateToString(ecemodel.eventDate).getDate(),
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: CustomColors.textColor(context),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: cv.BasicButton(
            onTap: () {
              cv.showFloatingSheet(
                context: context,
                builder: (context) => _timePicker(context, dmodel, ecemodel),
              );
            },
            child: Container(
              constraints: const BoxConstraints(minHeight: 50),
              decoration: BoxDecoration(
                color: CustomColors.cellColor(context),
                borderRadius: BorderRadius.circular(10),
              ),
              width: double.infinity,
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.schedule_rounded, color: dmodel.color),
                    const SizedBox(width: 8),
                    Text(
                      dateToString(ecemodel.eventDate).getTime()[0] == "0"
                          ? dateToString(ecemodel.eventDate)
                              .getTime()
                              .substring(1)
                          : dateToString(ecemodel.eventDate).getTime(),
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: CustomColors.textColor(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _title(BuildContext context, DataModel dmodel, ECEModel ecemodel) {
    return Container(
      decoration: BoxDecoration(
        color: CustomColors.cellColor(context),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: (ecemodel.event.eventType == 1 && !ecemodel.event.overrideTitle)
            ? cv.TextField2(
                labelText: "Opponent",
                controller: ecemodel.titleController,
                showBackground: false,
                fieldPadding: EdgeInsets.zero,
                isLabeled: true,
                onChanged: (value) {},
              )
            : cv.TextField2(
                labelText: "Title",
                controller: ecemodel.titleController,
                showBackground: false,
                fieldPadding: EdgeInsets.zero,
                isLabeled: true,
                value: ecemodel.event.eTitle,
                onChanged: (value) {},
              ),
      ),
    );
  }

  Widget _config(BuildContext context, DataModel dmodel, ECEModel ecemodel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: cv.Section(
        "Config",
        color: dmodel.color,
        helperView: (context) {
          return Column(
            children: const [
              cv.Section(
                "Send Auto Check-in Reminders",
                child: Text(
                    "If this is true, then emails will be sent to all the users on the event 2 days and 1 day before the event to check in. But don't worry, you can send check in reminders manually by status later."),
              ),
              cv.Section(
                "Track Attendance",
                child: Text(
                    "If this is false, no users will be on this event, and it will serve more as a reminder."),
              ),
              cv.Section(
                "Show Attendance",
                child: Text(
                    "If track attendance is true, this will let you control whether your users can see the roster of this event and their statuses or not."),
              ),
              cv.Section(
                "Home Team (game only)",
                child: Text(
                    "Gives you extra control on the ordering of your game title."),
              ),
            ],
          );
        },
        child: cv.ListView<Widget>(
          horizontalPadding: 0,
          childPadding: EdgeInsets.zero,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: cv.TextField2(
                labelText: "Description",
                enabled: !ecemodel.event.autoUpdateFromSync,
                onChanged: (value) {
                  setState(() {
                    ecemodel.event.eDescription = value;
                  });
                },
                showBackground: false,
                value: ecemodel.event.eDescription,
                isLabeled: true,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: cv.LabeledWidget(
                "Send Auto Check-in Reminders",
                child: Row(
                  children: [
                    FlutterSwitch(
                      value: ecemodel.event.allowAutoNotifications,
                      height: 25,
                      width: 50,
                      toggleSize: 18,
                      activeColor: dmodel.color,
                      onToggle: (value) {
                        setState(() {
                          ecemodel.event.allowAutoNotifications = value;
                        });
                      },
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ),
            if (ecemodel.isCreate)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: cv.LabeledWidget(
                  "Track Attendance",
                  child: Row(
                    children: [
                      FlutterSwitch(
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
                      const Spacer(),
                    ],
                  ),
                ),
              ),
            if (ecemodel.isCreate)
              AnimatedContainer(
                duration: const Duration(milliseconds: 700),
                height: ecemodel.event.hasAttendance ? 50 : 0,
                curve: Sprung.overDamped,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: cv.LabeledWidget(
                    "Show Attendance",
                    child: Row(
                      children: [
                        FlutterSwitch(
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
                        const Spacer(),
                      ],
                    ),
                  ),
                ),
              ),
            if (ecemodel.event.eventType == 1 &&
                !ecemodel.event.autoUpdateFromSync)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: cv.LabeledWidget(
                  "Home Team",
                  child: Row(
                    children: [
                      FlutterSwitch(
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
                      const Spacer(),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _delete(BuildContext context, DataModel dmodel, ECEModel ecemodel) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: comp.DestructionButton(
        title: "Delete",
        isLoading: _isLoading,
        onTap: () {
          cv.showAlert(
            context: context,
            title: "Delete Event",
            body: const Text("Are you sure you want to delete?"),
            cancelText: "Cancel",
            cancelBolded: true,
            onCancel: () {},
            submitText: "Delete",
            submitColor: Colors.red,
            onSubmit: () => _deleteAction(context, dmodel, ecemodel),
          );
        },
      ),
    );
  }

  Widget _datePicker(
      BuildContext context, DataModel dmodel, ECEModel ecemodel) {
    return cv.Sheet(
      title: "Event Date",
      color: dmodel.color,
      child: SfDateRangePicker(
        todayHighlightColor: dmodel.color,
        selectionColor: dmodel.color,
        selectionMode: DateRangePickerSelectionMode.single,
        initialDisplayDate: ecemodel.eventDate,
        initialSelectedDate: ecemodel.eventDate,
        selectionTextStyle: const TextStyle(color: Colors.white),
        onSelectionChanged: (args) {
          // set the date
          if (args.value is DateTime) {
            setState(() {
              DateTime d = args.value;
              ecemodel.eventDate = DateTime(d.year, d.month, d.day,
                  ecemodel.eventDate.hour, ecemodel.eventDate.minute, 0);
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
      BuildContext context, DataModel dmodel, ECEModel ecemodel) {
    return cv.Sheet(
      title: "Event Time",
      color: dmodel.color,
      child: cv.TimePicker(
        initialDate: ecemodel.eventDate,
        timePickerMode: cv.TimePickerMode.text,
        padding: const EdgeInsets.only(top: 16),
        accentColor: dmodel.color,
        onSelection: (date) {
          print(date);
          setState(() {
            ecemodel.eventDate = date;
          });
          Navigator.of(context).pop();
        },
        onCancel: () {
          Navigator.of(context).pop();
        },
      ),
    );
  }

  Future<void> _deleteAction(
      BuildContext context, DataModel dmodel, ECEModel ecemodel) async {
    setState(() {
      _isLoading = true;
    });
    await dmodel.deleteEvent(
        ecemodel.team!.teamId, ecemodel.season.seasonId, ecemodel.event.eventId,
        () {
      _reloadAfterDelete(context, dmodel, ecemodel);
    });
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _reloadAfterDelete(
      BuildContext context, DataModel dmodel, ECEModel ecemodel) async {
    // reload the homescreen
    Navigator.of(context, rootNavigator: true).pop();
    Navigator.of(context, rootNavigator: true).pop();
    setState(() {
      dmodel.isScaled = false;
    });
    await dmodel.reloadHomePage(ecemodel.team!.teamId, ecemodel.season.seasonId,
        dmodel.user!.email, false);
  }
}

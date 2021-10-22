import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

import '../../root.dart';
import 'root.dart';
import '../../../data/root.dart';
import '../../../client/root.dart';
import '../../../custom_views/root.dart' as cv;
import '../../../extras/root.dart';

class EventCreateEdit extends StatefulWidget {
  const EventCreateEdit({
    Key? key,
    required this.isCreate,
    this.initialEvent,
    required this.teamId,
  }) : super(key: key);
  final bool isCreate;
  final Event? initialEvent;
  final String teamId;

  @override
  _EventCreateEditState createState() => _EventCreateEditState();
}

class _EventCreateEditState extends State<EventCreateEdit> {
  late Event _event;

  String _opponent = "";
  late DateTime _eDate;

  @override
  void initState() {
    super.initState();
    if (widget.initialEvent != null) {
      _event = Event.of(widget.initialEvent!);
      _opponent = widget.initialEvent!.getOpponentTitle(widget.teamId);
      _eDate = widget.initialEvent!.eventDate();
    } else {
      _event = Event.empty();
      _eDate = DateTime.now();
    }
  }

  @override
  Widget build(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    return cv.AppBar(
      title: widget.isCreate ? "Create Event" : "Edit Event",
      isLarge: false,
      leading: cv.BackButton(color: dmodel.color),
      children: [
        // event type
        cv.SegmentedPicker<int>(
          initialSelection: _event.eType,
          titles: const ["Game", "Practice", "Other"],
          selections: [1, 2, 0],
          onSelection: (value) {
            setState(() {
              _event.eType = value;
            });
          },
        ),
        const SizedBox(height: 16),
        // event date
        _eventDate(context, dmodel),
        const SizedBox(height: 16),
        // event title or opponent
        _title(context),
      ],
    );
  }

  Widget _eventDate(BuildContext context, DataModel dmodel) {
    return cv.NativeList(
      itemPadding: const EdgeInsets.fromLTRB(16, 7, 16, 7),
      children: [
        Row(
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
                      _eDate = date;
                    });
                  },
                  currentTime: _eDate,
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
                    dateToString(_eDate).getDate(),
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
                      _eDate = date;
                    });
                  },
                  currentTime: _eDate,
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
                    dateToString(_eDate).getTime()[0] == "0"
                        ? dateToString(_eDate).getTime().substring(1)
                        : dateToString(_eDate).getTime(),
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ),
            const Spacer(),
            const cv.BasicLabel(label: "Event Date"),
          ],
        )
      ],
    );
  }

  Widget _title(BuildContext context) {
    return cv.NativeList(
      itemPadding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        (_event.eType == 1)
            ? cv.TextField(
                labelText: "Opponent",
                showBackground: false,
                isLabeled: true,
                onChanged: (value) {
                  setState(() {
                    _opponent = value;
                  });
                },
                validator: (value) {},
              )
            : cv.TextField(
                labelText: "Title",
                showBackground: false,
                isLabeled: true,
                onChanged: (value) {
                  setState(() {
                    _event.eTitle = value;
                  });
                },
                validator: (value) {},
              )
      ],
    );
  }
}

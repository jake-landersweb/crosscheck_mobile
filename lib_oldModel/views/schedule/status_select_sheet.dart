import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../custom_views/root.dart' as cv;
import '../../extras/root.dart';
import '../../client/root.dart';

class StatusSelectSheet extends StatefulWidget {
  const StatusSelectSheet({
    Key? key,
    required this.email,
    required this.teamId,
    required this.seasonId,
    required this.eventId,
    this.status,
    this.message,
    this.completion,
  }) : super(key: key);

  final String email;
  final String teamId;
  final String seasonId;
  final String eventId;
  final int? status;
  final String? message;
  final VoidCallback? completion;

  @override
  _StatusSelectSheetState createState() => _StatusSelectSheetState();
}

class _StatusSelectSheetState extends State<StatusSelectSheet> {
  late int _status = 0;
  late String _message = "";

  bool _isLoaded = false;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _getStatus(context.read<DataModel>());
  }

  @override
  Widget build(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    return cv.Sheet(
      title: "Select Status",
      color: dmodel.color,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            cv.Section(
              "Select Status",
              child: _isLoaded
                  ? cv.SegmentedPicker(
                      key: const ValueKey("is loaded picker status sheet"),
                      titles: const ["Out", "Undecided", "In"],
                      selections: const [-1, 2, 1],
                      initialSelection: _status,
                      onSelection: (value) {
                        _status = value;
                      },
                    )
                  : cv.SegmentedPicker(
                      key: const ValueKey("not loaded picker status sheet"),
                      titles: const [""],
                      onSelection: (value) {},
                    ),
            ),
            const SizedBox(height: 16),
            cv.Section(
              "Leave a Note",
              child: cv.NativeList(
                color: CustomColors.textColor(context).withOpacity(0.1),
                children: [
                  if (_isLoaded)
                    cv.TextField(
                      key: const ValueKey("is loaded text field status sheet"),
                      showBackground: false,
                      labelText: "Note",
                      initialvalue: _message,
                      validator: (value) {},
                      onChanged: (value) {
                        _message = value;
                      },
                    )
                  else
                    cv.TextField(
                      key: const ValueKey("not loaded text field status sheet"),
                      showBackground: false,
                      labelText: "Note 2",
                      validator: (value) {},
                      onChanged: (value) {},
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            cv.BasicButton(
              onTap: () {
                if (!_isLoading) {
                  setState(() {
                    _isLoading = true;
                  });
                  _setStatus(context, dmodel);
                }
              },
              child: cv.NativeList(
                color: CustomColors.textColor(context).withOpacity(0.1),
                itemPadding: const EdgeInsets.all(16),
                children: [
                  if (!_isLoading)
                    Text(
                      "Confirm Status",
                      style: TextStyle(
                        color: dmodel.color,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  else
                    cv.LoadingIndicator(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _setStatus(BuildContext context, DataModel dmodel) async {
    dmodel.updateUserStatus(widget.teamId, widget.seasonId, widget.eventId,
        widget.email, _status, _message, () {
      // close the view
      Navigator.of(context).pop();
      // update the schedule
      dmodel.scheduleGet(widget.teamId, widget.seasonId, widget.email,
          (schedule) {
        dmodel.setSchedule(schedule);
      });
      if (widget.completion != null) {
        widget.completion!();
      }
      setState(() {
        _isLoading = false;
      });
    });
  }

  void _getStatus(DataModel dmodel) async {
    dmodel.getUserStatus(
        widget.teamId, widget.seasonId, widget.eventId, widget.email,
        (status, message) {
      setState(() {
        _status = status;
        _message = message;
        _isLoaded = true;
      });
    });
  }
}

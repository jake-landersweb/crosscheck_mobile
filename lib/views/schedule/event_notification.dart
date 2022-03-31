import 'package:flutter/material.dart';
import 'package:pnflutter/client/root.dart';
import 'package:pnflutter/data/root.dart';
import 'package:pnflutter/extras/root.dart';
import 'package:provider/provider.dart';
import '../../custom_views/root.dart' as cv;

class EventNotification extends StatefulWidget {
  const EventNotification({
    Key? key,
    required this.teamId,
    required this.seasonId,
    required this.event,
  }) : super(key: key);
  final String teamId;
  final String seasonId;
  final Event event;

  @override
  State<EventNotification> createState() => _EventNotificationState();
}

class _EventNotificationState extends State<EventNotification> {
  String _title = "";
  String _message = "";
  List<int> _statuses = [];

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    return cv.Sheet(
      title: "Send Message",
      color: dmodel.color,
      child: Column(
        children: [
          cv.Section(
            "Select Statuses",
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: CustomColors.textColor(context).withOpacity(0.1),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _statusItem(context, dmodel, -1),
                    _statusItem(context, dmodel, 0),
                    _statusItem(context, dmodel, 2),
                    _statusItem(context, dmodel, 1),
                  ],
                ),
              ),
            ),
          ),
          cv.Section(
            "Title",
            child: cv.TextField2(
              labelText: "Title here ... (optional)",
              highlightColor: dmodel.color,
              validator: (val) => null,
              onChanged: (val) {
                setState(() {
                  _title = val;
                });
              },
            ),
          ),
          cv.Section(
            "Message",
            child: cv.TextField2(
              labelText: "Message here ... (optional)",
              highlightColor: dmodel.color,
              validator: (val) => null,
              onChanged: (val) {
                setState(() {
                  _message = val;
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: _button(context, dmodel),
          ),
        ],
      ),
    );
  }

  Widget _statusItem(BuildContext context, DataModel dmodel, int status) {
    return cv.BasicButton(
      onTap: () {
        if (_statuses.contains(status)) {
          setState(() {
            _statuses.removeWhere((element) => element == status);
          });
        } else {
          setState(() {
            _statuses.add(status);
          });
        }
      },
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _statuses.contains(status)
              ? widget.event.getStatusColor(
                  status,
                  defaultColor:
                      CustomColors.textColor(context).withOpacity(0.1),
                )
              : CustomColors.cellColor(context).withOpacity(0.5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Icon(
            widget.event.getStatusIcon(status),
            color: _statuses.contains(status)
                ? Colors.white
                : CustomColors.textColor(context),
          ),
        ),
      ),
    );
  }

  Widget _button(BuildContext context, DataModel dmodel) {
    return cv.RoundedLabel(
      _buttonText(),
      textColor: Colors.white,
      color: _buttonText() == "Send Message"
          ? dmodel.color
          : Colors.red.withOpacity(0.5),
      isLoading: _isLoading,
      onTap: () {
        _action(context, dmodel);
      },
    );
  }

  String _buttonText() {
    if (_statuses.isEmpty) {
      return "Select a status(es)";
    } else {
      return "Send Message";
    }
  }

  Future<void> _action(BuildContext context, DataModel dmodel) async {
    WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
    if (!_isLoading && _buttonText() == "Send Message") {
      setState(() {
        _isLoading = true;
      });
      Map<String, dynamic> body = {
        "statuses": _statuses,
      };
      if (_title.isNotEmpty) {
        body['title'] = _title;
      }
      if (_message.isNotEmpty) {
        body['message'] = _message;
      }

      await dmodel.sendEventMessage(
          widget.teamId, widget.seasonId, widget.event.eventId, body, () {
        Navigator.of(context).pop();
      });

      setState(() {
        _isLoading = false;
      });
    }
  }
}

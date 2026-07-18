import 'package:flutter/material.dart';
import 'package:crosscheck_sports/client/root.dart';
import 'package:crosscheck_sports/data/root.dart';
import 'package:crosscheck_sports/extras/root.dart';
import 'package:provider/provider.dart';
import 'package:crosscheck_sports/components/layer/header_bar.dart';
import 'package:crosscheck_sports/components/layer/action_button.dart';
import 'package:crosscheck_sports/components/layer/wide_button.dart';
import 'package:crosscheck_sports/components/core/clickable.dart';
import 'package:crosscheck_sports/components/layer/section.dart';

class EventNotification extends StatefulWidget {
  const EventNotification({
    super.key,
    required this.teamId,
    required this.seasonId,
    required this.event,
  });
  final String teamId;
  final String seasonId;
  final Event event;

  @override
  State<EventNotification> createState() => _EventNotificationState();
}

class _EventNotificationState extends State<EventNotification> {
  final List<int> _statuses = [0, 2];

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    return HeaderBar.sheet(
      title: "Send Reminder",
      trailing: XCActionButton.cancel(
        onTap: () => Navigator.of(context).pop(),
      ),
      child: Column(
        children: [
          const XCSection(
            "About",
            child: Text(
              "This will send a check in reminder to all of the users on this event corresponding to the statuses below. Based on their notification preferences, it will send an email, phone notification, or both.",
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 16,
              ),
            ),
          ),
          XCSection(
            "Select Statuses",
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: CustomColors.sheetCell(context),
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
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: _button(context, dmodel),
          ),
        ],
      ),
    );
  }

  Widget _statusItem(BuildContext context, DataModel dmodel, int status) {
    return Clickable(
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
    return XCWideButton.primary(
      title: _buttonText(),
      color: _buttonText() == "Send Message"
          ? dmodel.color
          : Colors.red.withOpacity(0.5),
      isLoading: _isLoading,
      onTap: () => _action(context, dmodel),
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

      await dmodel.sendEventMessage(
          widget.teamId, widget.seasonId, widget.event.eventId, _statuses, () {
        Navigator.of(context).pop();
      });

      setState(() {
        _isLoading = false;
      });
    }
  }
}

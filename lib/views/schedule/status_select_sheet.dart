import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_switch/flutter_switch.dart';

import '../../custom_views/root.dart' as cv;
import '../../extras/root.dart';
import '../../client/root.dart';
import '../../data/root.dart';

class StatusSelectSheet extends StatefulWidget {
  const StatusSelectSheet({
    Key? key,
    required this.email,
    required this.teamId,
    required this.seasonId,
    required this.event,
    this.status,
    this.message,
    this.completion,
    required this.isUpcoming,
  }) : super(key: key);

  final String email;
  final String teamId;
  final String seasonId;
  final Event event;
  final int? status;
  final String? message;
  final VoidCallback? completion;
  final bool isUpcoming;

  @override
  _StatusSelectSheetState createState() => _StatusSelectSheetState();
}

class _StatusSelectSheetState extends State<StatusSelectSheet> {
  int _status = 0;
  late String _message = "";

  bool _isLoaded = false;

  bool _isLoading = false;

  int _oldStatus = 0;

  bool _isNoShow = false;

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
        padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            cv.Section(
              "Select Status",
              child: _isLoaded
                  ? cv.SegmentedPicker(
                      key: const ValueKey("is loaded picker status sheet"),
                      titles: const ["NOT GOING", "UNSURE", "GOING"],
                      selections: const [-1, 2, 1],
                      initialSelection: _status,
                      onSelection: (value) {
                        _status = value;
                      },
                    )
                  : cv.SegmentedPicker(
                      initialSelection: "",
                      key: const ValueKey("not loaded picker status sheet"),
                      titles: const [""],
                      onSelection: (value) {},
                    ),
            ),
            // for managers if there wsa a no show
            if (!widget.isUpcoming &&
                ((dmodel.tus?.user.isTeamAdmin() ?? false) ||
                    (dmodel.currentSeasonUser?.isSeasonAdmin() ?? false)))
              Column(
                children: [
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      SizedBox(
                        height: 25,
                        child: FlutterSwitch(
                          value: _isNoShow,
                          height: 25,
                          width: 50,
                          toggleSize: 18,
                          activeColor: dmodel.color,
                          onToggle: (value) {
                            setState(() {
                              _isNoShow = value;
                            });
                          },
                        ),
                      ),
                      const cv.BasicLabel(label: "   Was No Show"),
                    ],
                  ),
                ],
              ),
            cv.Section("Custom Fields",
                child: cv.NativeList(
                  children: [
                    for (var i in widget.event.customUserFields) Text(i.title),
                  ],
                )),
            cv.Section(
              "Leave a Note",
              child: cv.NativeList(
                color: CustomColors.textColor(context).withOpacity(0.1),
                itemPadding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                children: [
                  if (_isLoaded)
                    cv.TextField(
                      key: const ValueKey("is loaded text field status sheet"),
                      showBackground: false,
                      fieldPadding: EdgeInsets.zero,
                      labelText: "Note",
                      value: _message,
                      validator: (value) {},
                      onChanged: (value) {
                        _message = value;
                      },
                    )
                  else
                    cv.TextField(
                      key: const ValueKey("not loaded text field status sheet"),
                      showBackground: false,
                      fieldPadding: EdgeInsets.zero,
                      labelText: "Note 2",
                      validator: (value) {},
                      onChanged: (value) {},
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            cv.RoundedLabel(
              "",
              onTap: () {
                if (!_isLoading) {
                  setState(() {
                    _isLoading = true;
                  });
                  _setStatus(context, dmodel);
                }
              },
              color: dmodel.color,
              child: Center(
                child: (!_isLoading)
                    ? const Text(
                        "Set Status",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    : const cv.LoadingIndicator(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _setStatus(BuildContext context, DataModel dmodel) async {
    setState(() {
      _isLoading = true;
    });
    if (_isNoShow) {
      _status = -2;
    }
    await dmodel.updateUserStatus(widget.teamId, widget.seasonId,
        widget.event.eventId, widget.email, _status, _message, () {
      // close the view
      Navigator.of(context).pop();
      // the specific event userStatus
      if (widget.isUpcoming) {
        for (var i in dmodel.upcomingEvents!) {
          if (i.eventId == widget.event.eventId) {
            // update any eventfields needed
            setState(() {
              if (widget.email == dmodel.user!.email) {
                i.userStatus = _status;
              }
              switch (_oldStatus) {
                case 0:
                  i.noResponse -= 1;
                  break;
                case -1:
                  i.outCount -= 1;
                  break;
                case 1:
                  i.inCount -= 1;
                  break;
                case 2:
                  i.undecidedCount -= 1;
                  break;
              }
              switch (_status) {
                case 0:
                  i.noResponse += 1;
                  break;
                case -1:
                  i.outCount += 1;
                  break;
                case 1:
                  i.inCount += 1;
                  break;
                case 2:
                  i.undecidedCount += 1;
                  break;
              }
            });
            break;
          }
        }
      } else {
        for (var i in dmodel.previousEvents!) {
          if (i.eventId == widget.event.eventId) {
            // update any event feilds needed
            setState(() {
              if (widget.email == dmodel.user!.email) {
                i.userStatus = _status;
              }
              switch (_oldStatus) {
                case 0:
                  i.noResponse -= 1;
                  break;
                case -1:
                  i.outCount -= 1;
                  break;
                case 1:
                  i.inCount -= 1;
                  break;
                case 2:
                  i.undecidedCount -= 1;
                  break;
              }
              switch (_status) {
                case 0:
                  i.noResponse += 1;
                  break;
                case -1:
                  i.outCount += 1;
                  break;
                case 1:
                  i.inCount += 1;
                  break;
                case 2:
                  i.undecidedCount += 1;
                  break;
              }
            });
            break;
          }
        }
      }
      if (widget.completion != null) {
        widget.completion!();
      }
    });
    setState(() {
      _isLoading = false;
    });
  }

  void _getStatus(DataModel dmodel) async {
    dmodel.getUserStatus(
        widget.teamId, widget.seasonId, widget.event.eventId, widget.email,
        (status, message) {
      setState(() {
        _status = status;
        _oldStatus = status;
        _message = message;
        _isLoaded = true;
        if (_status == -2) {
          _isNoShow = true;
        }
      });
    });
  }
}

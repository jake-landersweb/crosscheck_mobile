import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
    required this.eventId,
    this.status,
    this.message,
    this.completion,
    required this.isUpcoming,
  }) : super(key: key);

  final String email;
  final String teamId;
  final String seasonId;
  final String eventId;
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
                      initialSelection: "",
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
                  SizedBox(
                    height: 20,
                    child: Center(
                      child: (!_isLoading)
                          ? Text(
                              "Set Status",
                              style: TextStyle(
                                color: dmodel.color,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            )
                          : cv.LoadingIndicator(),
                    ),
                  )
                ],
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
    await dmodel.updateUserStatus(widget.teamId, widget.seasonId,
        widget.eventId, widget.email, _status, _message, () {
      // close the view
      Navigator.of(context).pop();
      // the specific event userStatus
      if (widget.isUpcoming) {
        for (var i in dmodel.upcomingEvents!) {
          if (i.eventId == widget.eventId) {
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
          if (i.eventId == widget.eventId) {
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
        widget.teamId, widget.seasonId, widget.eventId, widget.email,
        (status, message) {
      setState(() {
        _status = status;
        _oldStatus = status;
        _message = message;
        _isLoaded = true;
      });
    });
  }
}

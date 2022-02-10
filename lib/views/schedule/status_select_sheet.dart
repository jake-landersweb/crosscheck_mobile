import 'package:flutter/material.dart';
import 'package:pnflutter/views/root.dart';
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

  bool _isLoaded = false;

  bool _isLoading = false;

  int _oldStatus = 0;

  bool _isNoShow = false;

  List<CustomField> _customFields = [];

  late TextEditingController controller;

  @override
  void initState() {
    super.initState();
    _getStatus(context.read<DataModel>());
    controller = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    return cv.Sheet(
      title: "Select Status",
      color: dmodel.color,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),
          _isLoaded
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
          if (_customFields.isNotEmpty)
            cv.Section(
              "Custom Fields",
              child: CustomFieldCreate(
                enabled: false,
                cellColor: CustomColors.textColor(context).withOpacity(0.1),
                customFields: _customFields,
                isCreate: false,
                color: dmodel.color,
                onAdd: () {
                  return CustomField(title: "", type: "S", value: "");
                },
              ),
            ),
          cv.Section("Leave a Note",
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: cv.TextField(
                  fieldPadding: EdgeInsets.zero,
                  controller: controller,
                  showBackground: false,
                  labelText: "Type here ...",
                  validator: (value) {},
                  onChanged: (value) {},
                ),
              )),
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
    );
  }

  void _setStatus(BuildContext context, DataModel dmodel) async {
    setState(() {
      _isLoading = true;
    });
    if (_isNoShow) {
      _status = -2;
    }
    Map<String, dynamic> body = {
      "eStatus": _status,
      "message": controller.text,
      "customFields": _customFields.map((e) => e.toJson()).toList(),
    };

    await dmodel.updateUserStatus(widget.teamId, widget.seasonId,
        widget.event.eventId, widget.email, body, () {
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
        (user) {
      setState(() {
        _status = user.eStatus;
        _oldStatus = user.eStatus;
        controller.text = user.message ?? "";
        _isLoaded = true;
        if (_status == -2) {
          _isNoShow = true;
        }
        _customFields = [for (var i in user.customFields) i.clone()];
      });
    });
  }
}

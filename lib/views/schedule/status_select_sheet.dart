import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:crosscheck_sports/views/root.dart';
import 'package:provider/provider.dart';
import 'package:flutter_switch/flutter_switch.dart';

import '../../custom_views/root.dart' as cv;
import '../../extras/root.dart';
import '../../client/root.dart';
import '../../data/root.dart';
import '../components/root.dart' as comp;

class StatusSelectSheet extends StatefulWidget {
  const StatusSelectSheet({
    Key? key,
    required this.email,
    required this.teamId,
    required this.event,
    this.status,
    this.message,
    this.completion,
    required this.isUpcoming,
    required this.season,
  }) : super(key: key);

  final String email;
  final String teamId;
  final Event event;
  final int? status;
  final String? message;
  final VoidCallback? completion;
  final bool isUpcoming;
  final Season season;

  @override
  _StatusSelectSheetState createState() => _StatusSelectSheetState();
}

class _StatusSelectSheetState extends State<StatusSelectSheet> {
  int _status = 2;

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
      child: ConstrainedBox(
        constraints:
            BoxConstraints(maxHeight: MediaQuery.of(context).size.height / 2),
        child: ListView(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          children: [
            _isLoaded
                ? cv.SegmentedPicker(
                    key: const ValueKey("is loaded picker status sheet"),
                    titles: const ["NOT GOING", "UNSURE", "GOING"],
                    selections: const [-1, 2, 1],
                    selection: _status,
                    style: comp.segmentedPickerStyle(
                      context,
                      dmodel,
                      sliderColor:
                          (widget.event.getStatusColor(_status) ?? dmodel.color)
                              .withOpacity(0.3),
                      selectedTextColor:
                          widget.event.getStatusColor(_status) ?? dmodel.color,
                      backgroundColor: CustomColors.sheetCell(context),
                    ),
                    onSelection: (value) {
                      setState(() {
                        _status = value;
                      });
                    },
                  )
                : cv.SegmentedPicker(
                    selection: "",
                    key: const ValueKey("not loaded picker status sheet"),
                    titles: const [""],
                    style: comp.segmentedPickerStyle(
                      context,
                      dmodel,
                      backgroundColor: CustomColors.sheetCell(context),
                    ),
                    onSelection: (value) {},
                  ),
            // // for managers if there wsa a no show
            // if (!widget.isUpcoming &&
            //     ((dmodel.tus?.user.isTeamAdmin() ?? false) ||
            //         (dmodel.currentSeasonUser?.isSeasonAdmin() ?? false)))
            //   Column(
            //     children: [
            //       const SizedBox(height: 8),
            //       Row(
            //         children: [
            //           SizedBox(
            //             height: 25,
            //             child: FlutterSwitch(
            //               value: _isNoShow,
            //               height: 25,
            //               width: 50,
            //               toggleSize: 18,
            //               activeColor: dmodel.color,
            //               onToggle: (value) {
            //                 setState(() {
            //                   _isNoShow = value;
            //                 });
            //               },
            //             ),
            //           ),
            //           const cv.BasicLabel(label: "   Was No Show"),
            //         ],
            //       ),
            //     ],
            //   ),
            if (_customFields.isNotEmpty)
              cv.Section(
                "Custom Fields",
                child: CustomFieldCreate(
                  enabled: false,
                  cellColor: CustomColors.sheetCell(context),
                  customFields: _customFields,
                  isCreate: false,
                  childPadding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                  horizontalPadding: 0,
                  color: dmodel.color,
                  onAdd: () {
                    return CustomField(title: "", type: "S", value: "");
                  },
                ),
              ),
            const SizedBox(height: 16),
            cv.ListView<Widget>(
              horizontalPadding: 0,
              childPadding: const EdgeInsets.symmetric(horizontal: 16),
              backgroundColor: CustomColors.sheetCell(context),
              children: [
                cv.TextField2(
                  fieldPadding: EdgeInsets.zero,
                  controller: controller,
                  showBackground: false,
                  maxLines: 5,
                  icon: _status == 1
                      ? null
                      : const Icon(Icons.warning_rounded, color: Colors.red),
                  isLabeled: true,
                  labelText: "Note",
                  onChanged: (value) {},
                ),
              ],
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: comp.ActionButton(
                title: "Set Status",
                isLoading: _isLoading,
                color: dmodel.color,
                onTap: () {
                  if (!_isLoading) {
                    if (_status != 1 && controller.text.isEmpty) {
                    } else {
                      setState(() {
                        _isLoading = true;
                      });
                      _setStatus(context, dmodel);
                    }
                  }
                },
              ),
            ),
            // cv.RoundedLabel(
            //   "",
            //   onTap: () {
            //     if (!_isLoading) {
            //       setState(() {
            //         _isLoading = true;
            //       });
            //       _setStatus(context, dmodel);
            //     }
            //   },
            //   color: dmodel.color,
            //   child: Center(
            //     child: (!_isLoading)
            //         ? const Text(
            //             "Set Status",
            //             style: TextStyle(
            //               color: Colors.white,
            //               fontSize: 18,
            //               fontWeight: FontWeight.w600,
            //             ),
            //           )
            //         : const cv.LoadingIndicator(color: Colors.white),
            //   ),
            // ),
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
    Map<String, dynamic> body = {
      "eStatus": _status,
      "message": controller.text,
      "customFields": _customFields.map((e) => e.toJson()).toList(),
    };

    await dmodel.updateUserStatus(widget.teamId, widget.season.seasonId,
        widget.event.eventId, widget.email, body, () {
      // close the view
      FirebaseAnalytics.instance.logEvent(
        name: "event_checkin",
        parameters: {"status": "$_status"},
      );
      Navigator.of(context).pop();
      // get the season user
      SeasonUser? su = dmodel.seasonUsers
          ?.firstWhere((element) => element.email == widget.email);
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
            if (widget.season.positions.mvp.isNotEmpty &&
                su != null &&
                su.seasonFields!.pos == widget.season.positions.mvp) {
              if (_oldStatus != 1 && _status == 1) {
                setState(() {
                  i.mvps += 1;
                });
              } else if (_oldStatus == 1 && _status != 1) {
                if (i.mvps > 0) {
                  setState(() {
                    i.mvps -= 1;
                  });
                }
              }
            }
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
            if (widget.season.positions.mvp.isNotEmpty &&
                su != null &&
                su.seasonFields!.pos == widget.season.positions.mvp) {
              if (_oldStatus != 1 && _status == 1) {
                setState(() {
                  i.mvps += 1;
                });
              } else if (_oldStatus == 1 && _status != 1) {
                if (i.mvps > 0) {
                  setState(() {
                    i.mvps -= 1;
                  });
                }
              }
            }
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
    dmodel.getUserStatus(widget.teamId, widget.season.seasonId,
        widget.event.eventId, widget.email, (user) {
      setState(() {
        if (user.eStatus == 0) {
          _status = 2;
        }
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

import 'dart:developer';

import 'package:crosscheck_sports/views/root.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:crosscheck_sports/views/stats/team/root.dart';
import 'package:provider/provider.dart';

import '../../../custom_views/root.dart' as cv;
import '../../../data/root.dart';
import '../../../client/root.dart';
import '../../../extras/root.dart';
import '../root.dart';
import 'package:flutter/services.dart';
import 'package:crosscheck_sports/views/components/root.dart' as comp;

class LineupItemView extends StatefulWidget {
  const LineupItemView({
    super.key,
    required this.item,
  });
  final LineupItem item;

  @override
  State<LineupItemView> createState() => _LineupItemViewState();
}

class _LineupItemViewState extends State<LineupItemView> {
  late int _lineLength;

  @override
  void initState() {
    _lineLength = widget.item.ids.length;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    LModel lmodel = Provider.of<LModel>(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        cv.TextField2(
          value: widget.item.title,
          labelText: "Title",
          backgroundColor: CustomColors.sheetCell(context),
          highlightColor: dmodel.color,
          showBackground: true,
          onChanged: (p0) {
            setState(() {
              widget.item.title = p0;
            });
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              const Spacer(),
              cv.NumberPicker(
                minValue: 0,
                maxValue: 50,
                initialValue: _lineLength,
                plusBackgroundColor: dmodel.color,
                minusBackgroundColor: CustomColors.sheetCell(context),
                plusIconColor: Colors.white,
                minusIconColor: CustomColors.textColor(context),
                onMinusClick: (p0) {
                  setState(() {
                    _lineLength = p0;
                    lmodel.usedIds.removeWhere(
                      (element) => element == widget.item.ids.last,
                    );
                    widget.item.ids.removeLast();
                  });
                  lmodel.updateState();
                },
                onPlusClick: (p0) {
                  setState(() {
                    _lineLength = p0;
                    widget.item.ids.add("");
                  });
                  lmodel.updateState();
                },
              ),
            ],
          ),
        ),
        cv.ListView<int>(
          children: [for (var i = 0; i < _lineLength; i++) i],
          isAnimated: true,
          horizontalPadding: 0,
          backgroundColor: CustomColors.sheetCell(context),
          childPadding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          onChildTap: ((context, i) {
            cv.cupertinoSheet(
              context: context,
              builder: (context) => cv.AppBar.sheet(
                title: "Select User",
                leading: [
                  cv.BackButton(
                    color: dmodel.color,
                    showIcon: false,
                    showText: true,
                    title: "Cancel",
                  ),
                ],
                children: [
                  cv.ListView<SeasonUser>(
                    children: lmodel.eventUsers
                        .where((element) =>
                            !lmodel.usedIds.contains(element.email))
                        .toList(),
                    horizontalPadding: 0,
                    childPadding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    childBuilder: ((context, item) {
                      return RosterCell(
                        name: item.name(lmodel.team.showNicknames),
                        type: RosterListType.none,
                        seed: item.email,
                        subtext: item.seasonFields?.pos ?? "",
                        padding: EdgeInsets.zero,
                        trailingWidget: EventUserStatus(
                          email: item.email,
                          status: item.eventFields!.eStatus,
                          event: lmodel.event,
                          onTap: () {},
                          clickable: false,
                        ),
                      );
                    }),
                    onChildTap: (context, item) {
                      lmodel.usedIds.removeWhere(
                          (element) => element == widget.item.ids[i]);
                      lmodel.usedIds.add(item.email);
                      widget.item.ids.removeAt(i);
                      widget.item.ids.insert(i, item.email);
                      setState(() {});
                      Navigator.of(context).pop();
                      lmodel.updateState();
                    },
                  ),
                ],
              ),
            );
          }),
          childBuilder: (context, i) {
            var placeholder = Row(
              children: [
                cv.Circle(50, CustomColors.textColor(context).withOpacity(0.1)),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: CustomColors.textColor(context).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  height: 20,
                  width: MediaQuery.of(context).size.width / 2,
                ),
              ],
            );
            if (i > widget.item.ids.length) {
              return placeholder;
            } else {
              var su = lmodel.eventUsers.firstWhere(
                (element) => element.email == widget.item.ids[i],
                orElse: () => SeasonUser.empty(),
              );
              if (su.email != "") {
                return RosterCell(
                  name: su.name(lmodel.team.showNicknames),
                  type: RosterListType.none,
                  backgroundColor: Colors.transparent,
                  seed: su.email,
                  padding: EdgeInsets.zero,
                  trailingWidget: EventUserStatus(
                    email: su.email,
                    status: su.eventFields!.eStatus,
                    event: lmodel.event,
                    onTap: () {},
                    clickable: false,
                  ),
                );
              } else {
                return placeholder;
              }
            }
          },
        ),
      ],
    );
  }
}

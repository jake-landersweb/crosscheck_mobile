import 'package:pnflutter/data/root.dart';
import 'package:flutter/material.dart';
import 'package:pnflutter/client/root.dart';
import 'package:pnflutter/extras/root.dart';
import 'package:pnflutter/views/root.dart';
import 'package:provider/provider.dart';

import '../../custom_views/root.dart' as cv;

class StatsUsersList extends StatefulWidget {
  const StatsUsersList({
    Key? key,
    required this.statList,
  }) : super(key: key);
  final List<UserStat> statList;

  @override
  _StatsUsersListState createState() => _StatsUsersListState();
}

class _StatsUsersListState extends State<StatsUsersList> {
  String filterValue = "";

  @override
  void initState() {
    if (widget.statList.isNotEmpty) {
      if (widget.statList[0].stats.isNotEmpty) {
        filterValue = widget.statList[0].stats[0].title;
      }
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // header for all stats
        _statHeader(context),
        const SizedBox(height: 8),
        // actual stat list
        for (UserStat i in sortedUsers())
          Column(
            children: [
              StatsUserCell(
                key: ValueKey(i.email),
                userStat: i,
                currentStat: filterValue,
              ),
              const SizedBox(height: 8),
            ],
          )
      ],
    );
  }

  Widget _statHeader(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    if (widget.statList.isEmpty) {
      return Container();
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          children: [
            for (var i = 1;
                i < (widget.statList.first.stats.length / 3) + 1;
                i++)
              Column(
                children: [
                  Row(
                    children: [
                      for (var index = 1; index < 4; index++)
                        if (index * i < widget.statList.first.stats.length + 1)
                          Row(
                            children: [
                              cv.BasicButton(
                                onTap: () {
                                  setState(() {
                                    if (widget.statList.first
                                            .stats[(index * i) - 1].title ==
                                        filterValue) {
                                      filterValue = "";
                                    } else {
                                      filterValue = widget.statList.first
                                          .stats[(index * i) - 1].title;
                                    }
                                  });
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(100),
                                    color: filterValue ==
                                            widget.statList.first
                                                .stats[(index * i) - 1].title
                                        ? dmodel.color
                                        : CustomColors.cellColor(context),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Text(
                                      "${widget.statList.first.stats[(index * i) - 1].title[0].toUpperCase()}${widget.statList.first.stats[(index * i) - 1].title.substring(1)}",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                        color: filterValue ==
                                                widget
                                                    .statList
                                                    .first
                                                    .stats[(index * i) - 1]
                                                    .title
                                            ? Colors.white
                                            : CustomColors.textColor(context),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                          ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              )
          ],
        ),
      );
    }
  }

  List<UserStat> sortedUsers() {
    widget.statList.sort((a, b) {
      if (a.stats
              .firstWhere((element) => element.title == filterValue,
                  orElse: () => StatObject(title: "", value: -1))
              .value >
          b.stats
              .firstWhere((element) => element.title == filterValue,
                  orElse: () => StatObject(title: "", value: -1))
              .value) {
        return -1;
      } else {
        return 1;
      }
    });
    return widget.statList;
  }
}
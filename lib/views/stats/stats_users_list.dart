import 'package:crosscheck_sports/data/root.dart';
import 'package:flutter/material.dart';
import 'package:crosscheck_sports/client/root.dart';
import 'package:crosscheck_sports/extras/root.dart';
import 'package:crosscheck_sports/views/root.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';

import '../../custom_views/root.dart' as cv;

class StatsUsersList extends StatefulWidget {
  const StatsUsersList({
    Key? key,
    required this.team,
    required this.statList,
    required this.available,
  }) : super(key: key);
  final Team team;
  final List<UserStat> statList;
  final List<String> available;

  @override
  _StatsUsersListState createState() => _StatsUsersListState();
}

class _StatsUsersListState extends State<StatsUsersList> {
  String _filterValue = "";

  @override
  void initState() {
    if (widget.statList.isNotEmpty) {
      if (widget.statList[0].stats.isNotEmpty) {
        _filterValue = widget.statList[0].stats[0].title;
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
                team: widget.team,
                key: ValueKey(i.email),
                userStat: i,
                currentStat: _filterValue,
              ),
              const SizedBox(height: 8),
            ],
          )
      ],
    );
  }

  Widget _statHeader(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    if (widget.available.isEmpty) {
      return Container();
    } else {
      return cv.DynamicGridView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        itemCount: widget.available.length,
        builder: (context, i) {
          return cv.BasicButton(
            onTap: () {
              if (_filterValue == widget.available[i]) {
                setState(() {
                  _filterValue = "";
                });
              } else {
                setState(() {
                  _filterValue = widget.available[i];
                });
              }
            },
            child: Container(
              decoration: BoxDecoration(
                color: dmodel.color.withOpacity(0.3),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: _filterValue == widget.available[i]
                      ? dmodel.color
                      : Colors.transparent,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Center(
                  child: Text(
                    "${widget.available[i][0].toUpperCase()}${widget.available[i].substring(1)}",
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: dmodel.color,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );
    }
  }

  List<UserStat> sortedUsers() {
    widget.statList.sort((a, b) {
      if (a.stats
              .firstWhere((element) => element.title == _filterValue,
                  orElse: () => StatObject(title: "", value: -1))
              .value >
          b.stats
              .firstWhere((element) => element.title == _filterValue,
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

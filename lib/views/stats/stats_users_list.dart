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
    required this.available,
  }) : super(key: key);
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
    print(widget.available);
    if (widget.available.isEmpty) {
      return Container();
    } else {
      return GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 3,
        crossAxisCount: 2,
        children: [
          for (var i in widget.available)
            cv.BasicButton(
              onTap: () {
                if (_filterValue == i) {
                  setState(() {
                    _filterValue = "";
                  });
                } else {
                  setState(() {
                    _filterValue = i;
                  });
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: _filterValue == i
                      ? dmodel.color
                      : CustomColors.cellColor(context),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Center(
                  child: Text(
                    "${i[0].toUpperCase()}${i.substring(1)}",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _filterValue == i
                          ? Colors.white
                          : CustomColors.textColor(context),
                    ),
                  ),
                ),
              ),
            ),
        ],
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

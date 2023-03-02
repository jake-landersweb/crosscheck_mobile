import 'package:crosscheck_sports/client/root.dart';
import 'package:crosscheck_sports/data/root.dart';
import 'package:crosscheck_sports/extras/root.dart';
import 'package:crosscheck_sports/views/root.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../custom_views/root.dart' as cv;
import '../../components/root.dart' as comp;
import 'root.dart';

class FSUserList extends StatefulWidget {
  const FSUserList({
    super.key,
    required this.season,
  });
  final Season season;

  @override
  State<FSUserList> createState() => _FSUserListState();
}

class _FSUserListState extends State<FSUserList> {
  bool _isLoading = true;
  List<SeasonUser>? _users = [];

  @override
  void initState() {
    init(context.read<FSModel>(), context.read<DataModel>());
    super.initState();
  }

  void init(FSModel fsmodel, DataModel dmodel) async {
    await fsmodel.fetchSeasonRoster(
        fsmodel.team.teamId, widget.season.seasonId, dmodel, (p0) {
      // only add users that are not already part of the season roster
      _users = [];
      for (var i in p0) {
        if (!fsmodel.seasonRoster.any((element) => element.email == i.email)) {
          _users!.add(i);
        }
      }
      setState(() {});
    });
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    FSModel fsmodel = Provider.of<FSModel>(context);
    return cv.AppBar.sheet(
      title: widget.season.title,
      backgroundColor: CustomColors.backgroundColor(context),
      itemBarPadding: const EdgeInsets.fromLTRB(8, 0, 16, 0),
      leading: [
        cv.BackButton(color: dmodel.color),
      ],
      children: [_body(context, dmodel, fsmodel)],
    );
  }

  Widget _body(BuildContext context, DataModel dmodel, FSModel fsmodel) {
    if (_isLoading) {
      return cv.LoadingWrapper(
        child: cv.ListView<int>(
          horizontalPadding: 0,
          children: [for (var i = 0; i < 10; i++) i],
          childBuilder: (context, item) {
            return Container(
              height: 50,
            );
          },
        ),
      );
    } else if (_users == null) {
      return cv.NoneFound(
        "There was an issue getting the season roster",
        asset: "assets/svg/not_found.svg",
        color: dmodel.color,
      );
    } else {
      return Column(
        children: [
          cv.ListView<String>(
            children: const ["Select All", "Deselect All"],
            horizontalPadding: 0,
            childBuilder: ((context, item) {
              return Text(
                item,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 18,
                  color: CustomColors.textColor(context),
                ),
              );
            }),
            onChildTap: (context, item) {
              if (item == "Select All") {
                for (var i in _users!) {
                  if (!fsmodel.selectedUsers
                      .any((element) => element.email == i.email)) {
                    fsmodel.addUser(i);
                  }
                }
              } else {
                for (var i in _users!) {
                  fsmodel.removeUser(i);
                }
              }
            },
          ),
          cv.Section(
            "Users",
            child: cv.ListView<SeasonUser>(
              children: _users!,
              horizontalPadding: 0,
              allowsSelect: true,
              childPadding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              onSelect: ((item) {
                fsmodel.selectUser(item);
              }),
              selected: fsmodel.selectedUsers,
              selectedLogic: ((item) {
                return fsmodel.selectedUsers
                    .any((element) => element.email == item.email);
              }),
              color: dmodel.color,
              childBuilder: ((context, item) {
                return RosterCell(
                  name: item.name(fsmodel.team.showNicknames),
                  type: RosterListType.none,
                  seed: item.email,
                  padding: EdgeInsets.zero,
                );
              }),
            ),
          ),
        ],
      );
    }
  }
}

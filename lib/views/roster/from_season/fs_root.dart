import 'package:crosscheck_sports/client/root.dart';
import 'package:crosscheck_sports/data/root.dart';
import 'package:crosscheck_sports/extras/root.dart';
import 'package:crosscheck_sports/views/root.dart';
import 'package:crosscheck_sports/views/roster/from_season/fs_user_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../custom_views/root.dart' as cv;
import '../../components/root.dart' as comp;
import 'root.dart';

class FSRoot extends StatefulWidget {
  const FSRoot({
    super.key,
    required this.team,
    required this.season,
    required this.seasonRoster,
  });
  final Team team;
  final Season season;
  final List<SeasonUser> seasonRoster;

  @override
  State<FSRoot> createState() => _FSRootState();
}

class _FSRootState extends State<FSRoot> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    return ChangeNotifierProvider<FSModel>(
      create: (_) => FSModel(
        team: widget.team,
        season: widget.season,
        seasonRoster: widget.seasonRoster,
        dmodel: dmodel,
      ),
      // we use `builder` to obtain a new `BuildContext` that has access to the provider
      builder: (context, child) {
        // No longer throws
        return _content(context, dmodel);
      },
    );
  }

  Widget _content(BuildContext context, DataModel dmodel) {
    FSModel fsmodel = Provider.of<FSModel>(context);
    return cv.AppBar.sheet(
      title: "",
      leading: [
        cv.BackButton(
          color: dmodel.color,
          title: "Cancel",
          showIcon: false,
          showText: true,
          useRoot: true,
        ),
      ],
      trailing: [
        cv.BasicButton(
          onTap: () async {
            if (fsmodel.selectedUsers.isNotEmpty) {
              setState(() {
                _isLoading = true;
              });
              await dmodel.seasonUserAddFromList(
                widget.team.teamId,
                widget.season.seasonId,
                fsmodel.createBody(),
                () async {
                  Navigator.of(context, rootNavigator: true).pop();
                  // refresh the data
                  await dmodel.getBatchSeasonRoster(
                    widget.team.teamId,
                    widget.season.seasonId,
                    (p0) => dmodel.setSeasonUsers(p0),
                  );
                },
              );
              setState(() {
                _isLoading = false;
              });
            }
          },
          child: _isLoading
              ? SizedBox(
                  height: 25,
                  width: 25,
                  child: cv.LoadingIndicator(color: dmodel.color),
                )
              : Text(
                  "Add",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: fsmodel.selectedUsers.isEmpty
                        ? FontWeight.w400
                        : FontWeight.w600,
                    color: fsmodel.selectedUsers.isEmpty
                        ? CustomColors.textColor(context).withOpacity(0.5)
                        : dmodel.color,
                  ),
                ),
        ),
      ],
      children: [_body(context, dmodel, fsmodel)],
    );
  }

  Widget _body(BuildContext context, DataModel dmodel, FSModel fsmodel) {
    if (fsmodel.isLoadingSeasons) {
      return cv.LoadingWrapper(
        child: cv.Section(
          "Seasons",
          child: cv.ListView<int>(
            horizontalPadding: 0,
            children: [for (var i = 0; i < 10; i++) i],
            childBuilder: (context, item) {
              return const Text("");
            },
          ),
        ),
      );
    } else if (fsmodel.seasons == null) {
      return cv.NoneFound(
        "There was an issue getting the seasons",
        asset: "assets/svg/not_found.svg",
        color: dmodel.color,
      );
    } else {
      return Column(
        children: [
          cv.Section(
            "Seasons",
            allowsCollapse: true,
            initOpen: true,
            child: cv.ListView<Season>(
              horizontalPadding: 0,
              children: fsmodel.seasons!,
              onChildTap: ((context, item) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ListenableProvider.value(
                      value: fsmodel,
                      child: FSUserList(season: item),
                    ),
                  ),
                );
              }),
              childPadding: const EdgeInsets.fromLTRB(16, 16, 8, 16),
              childBuilder: ((context, item) {
                return Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: CustomColors.textColor(context),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: CustomColors.textColor(context).withOpacity(0.5),
                    ),
                  ],
                );
              }),
            ),
          ),
          cv.Section(
            "Selected Users",
            allowsCollapse: true,
            initOpen: true,
            child: fsmodel.selectedUsers.isEmpty
                ? cv.ListAppearance(
                    childPadding: EdgeInsets.zero,
                    child: Text(
                      "There are no users selected",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: CustomColors.textColor(context),
                      ),
                    ),
                  )
                : cv.ListView<SeasonUser>(
                    children: fsmodel.selectedUsers,
                    allowsDelete: true,
                    horizontalPadding: 0,
                    childPadding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    onDelete: (item) async {
                      fsmodel.removeUser(item);
                    },
                    onChildTap: ((context, item) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RUCERoot(
                            team: fsmodel.team,
                            season: fsmodel.season,
                            isSheet: true,
                            user: item,
                            isCreate: true,
                            teamToSeason: true,
                            onUserSave: (user) => fsmodel.handleUpdate(user),
                          ),
                        ),
                      );
                    }),
                    childBuilder: ((context, item) {
                      return RosterCell(
                        name: item.name(fsmodel.team.showNicknames),
                        type: RosterListType.navigator,
                        seed: item.email,
                        padding: EdgeInsets.zero,
                      );
                    }),
                  ),
          )
        ],
      );
    }
  }
}

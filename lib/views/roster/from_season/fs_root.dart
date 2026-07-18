import 'package:crosscheck_sports/client/root.dart';
import 'package:crosscheck_sports/data/root.dart';
import 'package:crosscheck_sports/extras/root.dart';
import 'package:crosscheck_sports/views/root.dart';
import 'package:crosscheck_sports/views/roster/from_season/fs_user_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../custom_views/root.dart' as cv;
import 'package:crosscheck_sports/components/layer/header_bar.dart';
import 'package:crosscheck_sports/components/layer/snapping_sheet.dart';
import 'package:crosscheck_sports/components/core/clickable.dart';
import 'package:crosscheck_sports/components/layer/action_button.dart';
import 'package:crosscheck_sports/components/core/cell_list.dart';
import 'package:crosscheck_sports/components/layer/section.dart';
import 'package:crosscheck_sports/components/core/loading_indicator.dart';

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
    return HeaderBar.sheet(
      title: "",
      leading: XCActionButton.cancel(
      onTap: () => Navigator.of(context, rootNavigator: true).pop(),
    ),
      trailing: Clickable(
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
                child: XCLoadingIndicator(color: dmodel.color),
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
      child: _body(context, dmodel, fsmodel),
    );
  }

  Widget _body(BuildContext context, DataModel dmodel, FSModel fsmodel) {
    if (fsmodel.isLoadingSeasons) {
      return cv.LoadingWrapper(
        child: XCSection(
          "Seasons",
          child: XCCellList<int>(
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
          XCSection(
            "Seasons",
            allowsCollapse: true,
            initOpen: true,
            child: XCCellList<Season>(
              horizontalPadding: 0,
              children: fsmodel.seasons!,
              onChildTap: ((context, item) {
                showSnappingSheet(
      context: context,
      child: ListenableProvider.value(
                    value: fsmodel,
                    child: FSUserList(season: item),
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
          XCSection(
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
                : XCCellList<SeasonUser>(
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

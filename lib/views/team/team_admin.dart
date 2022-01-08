import 'package:flutter/material.dart';
import 'package:pnflutter/views/root.dart';
import 'package:provider/provider.dart';
import '../../client/root.dart';
import '../../data/root.dart';
import '../../extras/root.dart';
import '../menu/root.dart';
import '../../custom_views/root.dart' as cv;
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class TeamAdmin extends StatefulWidget {
  const TeamAdmin({
    Key? key,
    required this.team,
    required this.seasons,
  }) : super(key: key);
  final Team team;
  final List<Season> seasons;

  @override
  _TeamAdminState createState() => _TeamAdminState();
}

class _TeamAdminState extends State<TeamAdmin> {
  @override
  Widget build(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    return cv.AppBar(
      title: "Team Admin",
      isLarge: true,
      backgroundColor: CustomColors.backgroundColor(context),
      // refreshable: true,
      color: dmodel.color,
      leading: const [MenuButton()],
      trailing: [_edit(context, dmodel)],
      // onRefresh: () => _refreshAction(dmodel),
      children: [_body(context, dmodel)],
    );
  }

  Widget _body(BuildContext context, DataModel dmodel) {
    return Column(
      children: [
        cv.Section(
          "Basic Info",
          allowsCollapse: true,
          initOpen: true,
          child: cv.NativeList(
            itemPadding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
            children: [
              cv.LabeledCell(
                height: cellHeight,
                label: "Title",
                value: widget.team.title,
              ),
              cv.LabeledCell(
                height: cellHeight,
                label: "Team Code",
                value: widget.team.teamCode,
              ),
              cv.LabeledCell(
                label: "Team Id",
                value: widget.team.teamId,
              ),
              if (widget.team.color != "")
                cv.LabeledCell(
                  height: cellHeight,
                  label: "Color",
                  value: "#" + widget.team.color,
                ),
              if (widget.team.image != "")
                cv.LabeledCell(
                  label: "Image",
                  value: widget.team.image,
                ),
              if (!widget.team.teamNote.isEmpty())
                cv.LabeledCell(
                  height: cellHeight,
                  label: "Team Note",
                  value: widget.team.teamNote!,
                ),
              cv.LabeledCell(
                height: cellHeight,
                label: "Is Light",
                value: widget.team.isLight ? "True" : "False",
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _teamRoster(context, dmodel),
        const SizedBox(height: 16),
        _seasons(context, dmodel),
        if (widget.team.positions.isActive)
          Column(
            children: [
              const SizedBox(height: 16),
              _teamPositions(context, dmodel),
            ],
          ),
        if (widget.team.customFields.isNotEmpty)
          Column(
            children: [
              const SizedBox(height: 16),
              _customFields(context),
            ],
          ),
        if (widget.team.customUserFields.isNotEmpty)
          Column(
            children: [
              const SizedBox(height: 16),
              _customUserFields(context),
            ],
          ),
      ],
    );
  }

  Widget _seasons(BuildContext context, DataModel dmodel) {
    return cv.Section(
      "Seasons",
      allowsCollapse: true,
      initOpen: true,
      child: Column(
        children: [
          if (widget.seasons.isEmpty)
            cv.RoundedLabel("No Seasons Here",
                color: CustomColors.cellColor(context))
          else
            cv.NativeList(
              itemPadding: const EdgeInsets.fromLTRB(16, 4, 8, 4),
              children: [
                for (var i in widget.seasons)
                  cv.BasicButton(
                    onTap: () {
                      showMaterialModalBottomSheet(
                        enableDrag: false,
                        context: context,
                        builder: (context) {
                          return SCERoot(
                              team: widget.team, isCreate: false, season: i);
                        },
                      );
                    },
                    child: SizedBox(
                      height: 45,
                      child: Row(
                        children: [
                          Text(
                            i.title,
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: CustomColors.textColor(context)),
                          ),
                          const Spacer(),
                          Text(
                            i.status(),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: CustomColors.textColor(context)
                                  .withOpacity(0.5),
                            ),
                          ),
                          Icon(
                            Icons.more_vert,
                            color: CustomColors.textColor(context)
                                .withOpacity(0.5),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          const SizedBox(height: 16),
          cv.RoundedLabel(
            "Create New Season",
            color: dmodel.color,
            textColor: Colors.white,
            onTap: () {
              showMaterialModalBottomSheet(
                enableDrag: false,
                context: context,
                builder: (context) {
                  return SCERoot(isCreate: true, team: widget.team);
                },
              );
            },
          )
        ],
      ),
    );
  }

  Widget _teamRoster(BuildContext context, DataModel dmodel) {
    return cv.RoundedLabel(
      "Full Team Roster",
      color: CustomColors.cellColor(context),
      textColor: CustomColors.textColor(context).withOpacity(0.7),
      isNavigator: true,
      onTap: () {
        cv.Navigate(
          context,
          FullTeamRoster(
            team: widget.team,
            teamUser: dmodel.tus!.user,
            childBuilder: (user) {
              return UserCell(
                user: user,
                isClickable: true,
                season: Season.empty(),
              );
            },
          ),
        );
      },
    );
  }

  Widget _teamPositions(BuildContext context, DataModel dmodel) {
    return cv.Section(
      "Positions",
      allowsCollapse: true,
      initOpen: false,
      child: cv.NativeList(
        children: [
          for (var position in widget.team.positions.available)
            SizedBox(
              height: cellHeight,
              child: cv.LabeledCell(
                label: position == widget.team.positions.defaultPosition
                    ? "Default"
                    : "",
                value: position,
              ),
            ),
        ],
      ),
    );
  }

  Widget _customFields(BuildContext context) {
    return cv.Section(
      "Custom Fields",
      allowsCollapse: true,
      initOpen: false,
      child: cv.NativeList(
        itemPadding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
        children: [
          for (var i in widget.team.customFields)
            cv.LabeledCell(
              height: cellHeight,
              label: i.title,
              value: i.getValue(),
            )
        ],
      ),
    );
  }

  Widget _customUserFields(BuildContext context) {
    return cv.Section(
      "Custom User Fields",
      allowsCollapse: true,
      initOpen: false,
      child: cv.NativeList(
        itemPadding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
        children: [
          for (var i in widget.team.customUserFields)
            cv.LabeledCell(
              height: cellHeight,
              label: i.title,
              value: "Default: ${i.value}",
            )
        ],
      ),
    );
  }

  Widget _edit(BuildContext context, DataModel dmodel) {
    return cv.BasicButton(
      onTap: () {
        cv.Navigate(context, EditTeam(team: widget.team));
      },
      child: Text(
        "Edit",
        style: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 18,
          color: dmodel.color,
        ),
      ),
    );
  }
}

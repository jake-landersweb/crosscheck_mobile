import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:pnflutter/client/root.dart';
import 'package:provider/provider.dart';
import 'root.dart';
import '../../data/root.dart';
import 'package:pnflutter/extras/root.dart';
import '../../custom_views/root.dart' as cv;

class RosterUserDetail extends StatefulWidget {
  const RosterUserDetail({
    Key? key,
    required this.team,
    this.season,
    required this.seasonUser,
    required this.teamUser,
    this.appSeasonUser,
    required this.onUserEdit,
  }) : super(key: key);
  final Team team;
  final Season? season;
  final SeasonUser seasonUser;
  final SeasonUserTeamFields teamUser;
  final SeasonUser? appSeasonUser;
  final Future<void> Function(Map<String, dynamic>) onUserEdit;

  @override
  _RosterUserDetailState createState() => _RosterUserDetailState();
}

class _RosterUserDetailState extends State<RosterUserDetail> {
  @override
  Widget build(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    return cv.AppBar(
      title: "",
      isLarge: false,
      itemBarPadding: const EdgeInsets.fromLTRB(8, 0, 15, 8),
      refreshable: false,
      backgroundColor: CustomColors.backgroundColor(context),
      color: dmodel.color,
      leading: [cv.BackButton(color: dmodel.color)],
      trailing: [_edit(context, dmodel)],
      children: [
        _body(context, dmodel),
        const SizedBox(height: 16),
        cv.NativeList(
          children: [
            cv.LabeledCell(value: widget.seasonUser.email, label: "Email"),
          ],
        ),
        if (widget.seasonUser.userFields != null) _userFields(context),
        if (widget.seasonUser.teamFields != null) _teamFields(context),
        if (widget.seasonUser.seasonFields != null) _seasonFields(context),
      ],
    );
  }

  Widget _body(BuildContext context, DataModel dmodel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // avatar
        RosterAvatar(
          name: widget.seasonUser.name(widget.team.showNicknames),
          seed: widget.seasonUser.email,
          size: 100,
          fontSize: 50,
        ),
        const SizedBox(height: 8),
        // name
        Text(
          widget.seasonUser.name(widget.team.showNicknames),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _userFields(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),
        cv.Section(
          "User Fields",
          child: Column(
            children: [
              cv.NativeList(
                children: [
                  if (!widget.seasonUser.userFields!.firstName.isEmpty())
                    cv.LabeledCell(
                      label: "First Name",
                      value: widget.seasonUser.userFields!.firstName!,
                    ),
                  if (!widget.seasonUser.userFields!.lastName.isEmpty())
                    cv.LabeledCell(
                      label: "Last Name",
                      value: widget.seasonUser.userFields!.lastName!,
                    ),
                  if (!widget.seasonUser.userFields!.phone.isEmpty())
                    cv.LabeledCell(
                      label: "Phone",
                      value: widget.seasonUser.userFields!.phone!,
                    )
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _teamFields(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),
        cv.Section(
          "Team Fields",
          child: Column(
            children: [
              cv.NativeList(
                children: [
                  cv.LabeledCell(
                      label: "Position",
                      value: widget.seasonUser.teamFields!.pos.isEmpty
                          ? "None"
                          : widget.seasonUser.teamFields!.pos),
                  if (!widget.seasonUser.teamFields!.teamUserNote.isEmpty())
                    cv.LabeledCell(
                        label: "Note",
                        value: widget.seasonUser.teamFields!.teamUserNote!),
                  cv.LabeledCell(
                      label: "Status",
                      value:
                          widget.seasonUser.teamFields!.getValidationStatus()),
                  cv.LabeledCell(
                      label: "Jersey Size",
                      value: widget.seasonUser.teamFields!.jerseySize),
                  cv.LabeledCell(
                      label: "Jersey Number",
                      value: widget.seasonUser.teamFields!.jerseyNumber),
                  if (widget.seasonUser.teamFields!.nickname.isNotEmpty)
                    cv.LabeledCell(
                        label: "Nickname",
                        value: widget.seasonUser.teamFields!.nickname),
                ],
              ),
              // custom fields
              if (widget.seasonUser.teamFields!.customFields.isNotEmpty)
                const SizedBox(height: 8),
              if (widget.seasonUser.teamFields!.customFields.isNotEmpty)
                cv.NativeList(
                  children: [
                    for (var i in widget.seasonUser.teamFields!.customFields)
                      cv.LabeledCell(
                        label: i.getTitle(),
                        value: i.getValue(),
                      )
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _seasonFields(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),
        cv.Section(
          "Season Fields",
          child: Column(
            children: [
              cv.NativeList(
                children: [
                  cv.LabeledCell(
                    label: "Position",
                    value: widget.seasonUser.seasonFields!.pos.isEmpty
                        ? "None"
                        : widget.seasonUser.seasonFields!.pos,
                  ),
                  if (!widget.seasonUser.seasonFields!.seasonUserNote.isEmpty())
                    cv.LabeledCell(
                      label: "Note",
                      value: widget.seasonUser.seasonFields!.seasonUserNote!,
                    ),
                  cv.LabeledCell(
                    label: "Manager",
                    value: widget.seasonUser.seasonFields!.isManager
                        ? "True"
                        : "False",
                  ),
                  cv.LabeledCell(
                    label: "Is a Sub",
                    value: widget.seasonUser.seasonFields!.isSub
                        ? "True"
                        : "False",
                  ),
                  cv.LabeledCell(
                      label: "Jersey Size",
                      value: widget.seasonUser.seasonFields!.jerseySize),
                  cv.LabeledCell(
                      label: "Jersey Number",
                      value: widget.seasonUser.seasonFields!.jerseyNumber),
                ],
              ),
              const SizedBox(height: 8),
              // custom fields
              if (widget.seasonUser.seasonFields!.customFields.isNotEmpty)
                const SizedBox(height: 8),
              if (widget.seasonUser.seasonFields!.customFields.isNotEmpty)
                cv.NativeList(
                  children: [
                    for (var i in widget.seasonUser.seasonFields!.customFields)
                      cv.LabeledCell(
                        label: i.getTitle(),
                        value: i.getValue(),
                      )
                  ],
                ),
            ],
          ),
        )
      ],
    );
  }

  Widget _edit(BuildContext context, DataModel dmodel) {
    if (widget.appSeasonUser?.isSeasonAdmin() ??
        widget.teamUser.isTeamAdmin()) {
      return cv.BasicButton(
        onTap: () {
          showMaterialModalBottomSheet(
            context: context,
            builder: (context) {
              return RUCERoot(
                team: widget.team,
                season: widget.season,
                user: widget.seasonUser,
                isCreate: false,
                onFunction: (body) async {
                  await widget.onUserEdit(body);
                },
              );
            },
          );
        },
        child: Text(
          "Edit",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: dmodel.color,
          ),
        ),
      );
    } else {
      return Container();
    }
  }
}

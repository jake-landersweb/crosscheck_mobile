import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../root.dart';
import '../../client/root.dart';
import '../../data/root.dart';
import '../../custom_views/root.dart' as cv;
import '../../extras/root.dart';

class SeasonUserDetail extends StatefulWidget {
  const SeasonUserDetail({
    Key? key,
    this.season,
    required this.user,
    required this.team,
    required this.teamUser,
    this.currentSeasonUser,
  }) : super(key: key);

  final Season? season;
  final SeasonUser user;
  final Team team;
  final SeasonUser? currentSeasonUser;
  final SeasonUserTeamFields teamUser;

  @override
  State<SeasonUserDetail> createState() => _SeasonUserDetailState();
}

class _SeasonUserDetailState extends State<SeasonUserDetail> {
  @override
  Widget build(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    return cv.AppBar(
      title: "",
      itemBarPadding: const EdgeInsets.fromLTRB(8, 0, 15, 8),
      backgroundColor: CustomColors.backgroundColor(context),
      leading: [
        cv.BackButton(
          color: dmodel.color,
        ),
      ],
      trailing: [_edit(context, dmodel)],
      children: [
        UserAvatar(
          user: widget.user,
          diameter: 100,
          fontSize: 50,
          season: widget.season,
        ),
        const SizedBox(height: 16),
        Text(
          widget.user.name(widget.season?.showNicknames ?? false),
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),
        _email(context),
        if (widget.user.userFields != null) _userInfo(context),
        if (widget.user.teamFields != null) _teamInfo(context),
        if (widget.user.seasonFields != null) _seasonInfo(context),
        const SizedBox(height: 48),
      ],
    );
  }

  Widget _email(BuildContext context) {
    return cv.NativeList(
      children: [
        cv.LabeledCell(label: "Email", value: widget.user.email, height: 40),
      ],
    );
  }

  Widget _userInfo(BuildContext context) {
    return cv.Section(
      "User Info",
      child: cv.NativeList(
        children: [
          cv.LabeledCell(
              label: "First name",
              value: widget.user.userFields?.firstName ?? "",
              height: 40),
          cv.LabeledCell(
              label: "Last name",
              value: widget.user.userFields?.lastName ?? "",
              height: 40),
          cv.LabeledCell(
              label: "Phone",
              value: widget.user.userFields?.phone ?? "",
              height: 40),
        ],
      ),
    );
  }

  Widget _teamInfo(BuildContext context) {
    return cv.Section(
      "Team Info",
      child: Column(
        children: [
          cv.NativeList(
            children: [
              if (widget.team.positions.isActive)
                cv.LabeledCell(
                  label: "Team Position",
                  value: widget.user.teamFields?.pos ?? "",
                  height: 40,
                ),
              cv.LabeledCell(
                label: "User Type",
                value: widget.user.teamUserType(),
                height: 40,
              ),
              cv.LabeledCell(
                label: "Team Note",
                value: (widget.user.teamFields?.teamUserNote.isEmpty() ?? true)
                    ? "Empty"
                    : widget.user.teamFields!.teamUserNote!,
                height: 40,
              ),
              cv.LabeledCell(
                label: "Validation Status",
                value: widget.user.teamFields?.getValidationStatus() ?? "",
                height: 40,
              ),
              // custom fields
            ],
          ),
          const SizedBox(height: 8),
          if (widget.user.teamFields?.customFields.isNotEmpty ?? false)
            cv.NativeList(
              children: [
                for (var i in widget.user.teamFields!.customFields)
                  cv.LabeledCell(
                      label: i.title, value: i.getValue(), height: 40),
              ],
            ),
        ],
      ),
    );
  }

  Widget _seasonInfo(BuildContext context) {
    return cv.Section(
      "Season Info",
      child: Column(
        children: [
          cv.NativeList(
            children: [
              if (!(widget.user.seasonFields?.nickname).isEmpty() &&
                  (widget.season?.showNicknames ?? false))
                cv.LabeledCell(
                    height: 40,
                    label: "Nickname",
                    value: widget.user.seasonFields!.nickname),
              cv.LabeledCell(
                  height: 40,
                  label: "Season Position",
                  value: widget.user.seasonFields?.pos ?? ""),
              cv.LabeledCell(
                  height: 40,
                  label: "User Status",
                  value: widget.user.seasonUserStatus(
                      widget.user.seasonFields?.seasonUserStatus ?? 0)),
              cv.LabeledCell(
                  height: 40,
                  label: "Is Manager",
                  value: (widget.user.seasonFields?.isManager ?? false)
                      ? "True"
                      : "False"),
              cv.LabeledCell(
                  height: 40,
                  label: "Season Note",
                  value: widget.user.seasonFields?.seasonUserNote ?? ""),
              cv.LabeledCell(
                  height: 40,
                  label: "Is A Sub",
                  value: (widget.user.seasonFields?.isSub ?? false)
                      ? "True"
                      : "False"),
              // custom fields
            ],
          ),
          const SizedBox(height: 8),
          if (widget.user.seasonFields?.customFields.isNotEmpty ?? false)
            cv.NativeList(
              children: [
                for (var i in widget.user.seasonFields!.customFields)
                  cv.LabeledCell(
                      label: i.title, value: i.getValue(), height: 40),
              ],
            ),
        ],
      ),
    );
  }

  Widget _edit(BuildContext context, DataModel dmodel) {
    Widget button = cv.BasicButton(
      onTap: () {
        cv.Navigate(
          context,
          SeasonUserEdit(
            team: dmodel.tus!.team,
            user: widget.user,
            teamId: widget.team.teamId,
            currentSeasonUser: widget.currentSeasonUser,
            teamUser: widget.teamUser,
            season: widget.season,
            completion: () {
              // do not need to fetch roster, getting returned value and replacing in list
              // dmodel.getSeasonRoster(widget.teamId, widget.seasonId, (users) {
              //   dmodel.setSeasonUsers(users);
              // });
              Navigator.of(context).pop();
            },
          ),
        );
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
    if (widget.user.email == dmodel.user!.email ||
        (dmodel.currentSeasonUser?.isSeasonAdmin() ?? false) ||
        (dmodel.tus!.user.isTeamAdmin())) {
      return button;
    } else {
      return Container(height: 0);
    }
  }
}

class UserInfoCell extends StatelessWidget {
  const UserInfoCell({
    Key? key,
    required this.label,
    required this.value,
  }) : super(key: key);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: CustomColors.textColor(context).withOpacity(0.7),
          ),
        ),
      ],
    );
  }
}

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
    required this.user,
    required this.teamId,
    required this.seasonId,
  }) : super(key: key);

  final SeasonUser user;
  final String teamId;
  final String seasonId;

  @override
  State<SeasonUserDetail> createState() => _SeasonUserDetailState();
}

class _SeasonUserDetailState extends State<SeasonUserDetail> {
  @override
  Widget build(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    return cv.AppBar(
      title: "",
      titlePadding: const EdgeInsets.only(left: 8),
      leading: cv.BackButton(
        color: dmodel.color,
      ),
      actions: [_edit(context, dmodel)],
      children: [
        UserAvatar(
          user: widget.user,
          diameter: 100,
          fontSize: 50,
        ),
        const SizedBox(height: 16),
        Text(
          widget.user.seasonName(),
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),
        if (widget.user.userFields != null) _userInfo(context),
        if (widget.user.teamFields != null) _teamInfo(context),
        if (widget.user.seasonFields != null) _seasonInfo(context),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _userInfo(BuildContext context) {
    return cv.Section(
      "User Info",
      child: cv.NativeList(
        itemPadding: const EdgeInsets.all(16),
        children: [
          UserInfoCell(
              label: "First name",
              value: widget.user.userFields?.firstName ?? ""),
          UserInfoCell(
              label: "Last name",
              value: widget.user.userFields?.lastName ?? ""),
          UserInfoCell(
              label: "Phone", value: widget.user.userFields?.phone ?? ""),
        ],
      ),
    );
  }

  Widget _teamInfo(BuildContext context) {
    return cv.Section(
      "Team Info",
      child: cv.NativeList(
        itemPadding: const EdgeInsets.all(16),
        children: [
          UserInfoCell(
              label: "Org id", value: widget.user.teamFields?.orgId ?? ""),
          UserInfoCell(
              label: "Team User Type", value: widget.user.teamUserType()),
          UserInfoCell(
              label: "Is Goalie",
              value:
                  widget.user.teamFields?.isGoalie ?? false ? "True" : "False"),
          UserInfoCell(
              label: "Team Note",
              value: widget.user.teamFields?.teamUserNote ?? "")
        ],
      ),
    );
  }

  Widget _seasonInfo(BuildContext context) {
    return cv.Section(
      "Season Info",
      child: cv.NativeList(
        itemPadding: const EdgeInsets.all(16),
        children: [
          UserInfoCell(
              label: "Nickname",
              value: widget.user.seasonFields?.nickName ?? ""),
          UserInfoCell(
              label: "Jersey Number",
              value: widget.user.seasonFields?.jerseyNumber ?? ""),
          UserInfoCell(
              label: "Jersey Size",
              value: widget.user.seasonFields?.jerseySize ?? ""),
          UserInfoCell(
              label: "Season Position",
              value: widget.user.seasonFields?.userPosition ?? ""),
          UserInfoCell(label: "User Type", value: widget.user.seasonUserType()),
          UserInfoCell(
              label: "User Status", value: widget.user.seasonUserStatus()),
          UserInfoCell(
              label: "Season Note",
              value: widget.user.seasonFields?.seasonUserNote ?? ""),
        ],
      ),
    );
  }

  Widget _edit(BuildContext context, DataModel dmodel) {
    if (widget.user.email == dmodel.user!.email) {
      return cv.BasicButton(
        onTap: () {
          cv.Navigate(
            context,
            SeasonUserEdit(
              user: widget.user,
              teamId: widget.teamId,
              seasonId: widget.seasonId,
              editNickname: widget.user.seasonFields != null ? true : false,
              completion: () {
                if (widget.user.seasonFields == null) {
                  dmodel.getTeamRoster(widget.teamId, (users) {
                    dmodel.setTeamRoster(users);
                  });
                } else {
                  dmodel.getSeasonRoster(widget.teamId, widget.seasonId,
                      (users) {
                    dmodel.setSeasonRoster(users);
                  });
                }
                Navigator.of(context).pop();
              },
            ),
          );
        },
        child: Text(
          "Edit",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: dmodel.color,
          ),
        ),
      );
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
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
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

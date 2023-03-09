import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:crosscheck_sports/client/root.dart';
import 'package:provider/provider.dart';
import 'root.dart';
import '../../data/root.dart';
import 'package:crosscheck_sports/extras/root.dart';
import '../../custom_views/root.dart' as cv;
import '../components/root.dart' as comp;

class RosterUserDetail extends StatefulWidget {
  const RosterUserDetail({
    Key? key,
    required this.team,
    this.season,
    required this.seasonUser,
    required this.teamUser,
    this.appSeasonUser,
    required this.onUserEdit,
    required this.onDelete,
    required this.isTeam,
    this.isSheet = false,
  }) : super(key: key);
  final Team team;
  final Season? season;
  final SeasonUser seasonUser;
  final SeasonUserTeamFields teamUser;
  final SeasonUser? appSeasonUser;
  final Future<void> Function(Map<String, dynamic>) onUserEdit;
  final VoidCallback onDelete;
  final bool isTeam;
  final bool isSheet;

  @override
  _RosterUserDetailState createState() => _RosterUserDetailState();
}

class _RosterUserDetailState extends State<RosterUserDetail> {
  bool _isLoading = false;

  @override
  void initState() {
    logEvent();
    super.initState();
  }

  void logEvent() async {
    await FirebaseAnalytics.instance
        .setCurrentScreen(screenName: "user_detail");
  }

  @override
  Widget build(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    return cv.AppBar(
      hasSafeArea: widget.isSheet ? false : true,
      barHeight: widget.isSheet ? 60 : 40,
      leadingAlignment: widget.isSheet ? Alignment.centerLeft : null,
      titleAlignment: widget.isSheet ? Alignment.center : null,
      trailingAlignment: widget.isSheet ? Alignment.centerRight : null,
      title: "",
      isLarge: false,
      itemBarPadding: const EdgeInsets.fromLTRB(8, 0, 16, 8),
      refreshable: false,
      backgroundColor: CustomColors.backgroundColor(context),
      color: dmodel.color,
      leading: [cv.BackButton(color: dmodel.color)],
      trailing: [_edit(context, dmodel)],
      children: [
        _body(context, dmodel),
        const SizedBox(height: 16),
        cv.ListView<Widget>(
          horizontalPadding: 0,
          childPadding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            cv.LabeledCell(value: widget.seasonUser.email, label: "Email"),
          ],
        ),
        if (widget.seasonUser.teamFields?.validationStatus != 1 &&
            (widget.teamUser.isTeamAdmin() ||
                (widget.appSeasonUser?.isSeasonAdmin() ?? false)))
          _invite(context, dmodel),
        if (widget.seasonUser.userFields != null) _userFields(context),
        if (widget.seasonUser.seasonFields != null && !widget.isTeam)
          _seasonFields(context)
        else if (widget.seasonUser.teamFields != null && widget.isTeam)
          _teamFields(context),
        if (widget.teamUser.isTeamAdmin() || widget.seasonUser.isSeasonAdmin())
          _delete(context, dmodel),
      ],
    );
  }

  Widget _invite(BuildContext context, DataModel dmodel) {
    return Column(
      children: [
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: comp.ActionButton(
            title: widget.seasonUser.teamFields!.validationStatus == 0
                ? "Send Invite"
                : "Re-send Invite",
            color: dmodel.color,
            isLoading: _isLoading,
            onTap: () {
              if (!_isLoading) {
                _sendInvite(context, dmodel);
              }
            },
          ),
        ),
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
    return cv.Section(
      "Personal Information",
      child: Column(
        children: [
          cv.ListView<Widget>(
            horizontalPadding: 0,
            childPadding: const EdgeInsets.symmetric(horizontal: 16),
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
                ),
              if (!widget.seasonUser.userFields!.nickname.isEmpty())
                cv.LabeledCell(
                  label: "Nickname",
                  value: widget.seasonUser.userFields!.nickname!,
                )
            ],
          ),
        ],
      ),
    );
  }

  Widget _teamFields(BuildContext context) {
    return cv.Section(
      "Player Fields",
      child: Column(
        children: [
          cv.ListView<Widget>(
            horizontalPadding: 0,
            childPadding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              cv.LabeledCell(
                  label: "Position",
                  value: widget.seasonUser.teamFields!.pos.isEmpty
                      ? "None"
                      : widget.seasonUser.teamFields!.pos.capitalize()),
              if (!widget.seasonUser.teamFields!.teamUserNote.isEmpty())
                cv.LabeledCell(
                    label: "Note",
                    value: widget.seasonUser.teamFields!.teamUserNote!),
              cv.LabeledCell(
                  label: "Status",
                  value: widget.seasonUser.teamFields!.getValidationStatus()),
              cv.LabeledCell(
                  label: "Jersey Size",
                  value: widget.seasonUser.teamFields!.jerseySize),
              cv.LabeledCell(
                  label: "Jersey Number",
                  value: widget.seasonUser.teamFields!.jerseyNumber),
            ],
          ),
          // custom fields
          if (widget.seasonUser.teamFields!.customFields.isNotEmpty)
            const SizedBox(height: 8),
          if (widget.seasonUser.teamFields!.customFields.isNotEmpty)
            cv.ListView<Widget>(
              horizontalPadding: 0,
              childPadding: const EdgeInsets.symmetric(horizontal: 16),
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
    );
  }

  Widget _seasonFields(BuildContext context) {
    return cv.Section(
      "Player Fields",
      child: Column(
        children: [
          cv.ListView<Widget>(
            horizontalPadding: 0,
            childPadding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              cv.LabeledCell(
                label: "Position",
                value: widget.seasonUser.seasonFields!.pos.isEmpty
                    ? "None"
                    : widget.seasonUser.seasonFields!.pos.capitalize(),
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
                value: widget.seasonUser.seasonFields!.isSub ? "True" : "False",
              ),
              cv.LabeledCell(
                label: "Jersey Size",
                value: widget.seasonUser.seasonFields!.jerseySize,
              ),
              cv.LabeledCell(
                label: "Jersey Number",
                value: widget.seasonUser.seasonFields!.jerseyNumber,
              ),
              cv.LabeledCell(
                label: "Status",
                value: widget.seasonUser.seasonFields!.getStatus(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // custom fields
          if (widget.seasonUser.seasonFields!.customFields.isNotEmpty)
            cv.ListView<Widget>(
              horizontalPadding: 0,
              childPadding: const EdgeInsets.symmetric(horizontal: 16),
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
    );
  }

  Widget _edit(BuildContext context, DataModel dmodel) {
    if (widget.appSeasonUser?.isSeasonAdmin() ??
        widget.teamUser.isTeamAdmin()) {
      return cv.BasicButton(
        onTap: () {
          if (widget.isSheet) {
            cv.cupertinoSheet(
              context: context,
              builder: (context) {
                return RUCERoot(
                  team: widget.team,
                  season: widget.season,
                  user: widget.seasonUser,
                  isSheet: true,
                  useRoot: true,
                  isCreate: false,
                  onFunction: (body) async {
                    await widget.onUserEdit(body);
                  },
                );
              },
            );
          } else {
            cv.cupertinoSheet(
                context: context,
                builder: (context) {
                  return RUCERoot(
                    team: widget.team,
                    season: widget.season,
                    user: widget.seasonUser,
                    isSheet: true,
                    useRoot: true,
                    isCreate: false,
                    onFunction: (body) async {
                      await widget.onUserEdit(body);
                    },
                  );
                });
          }
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

  Widget _delete(BuildContext context, DataModel dmodel) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: comp.DestructionButton(
          title: "Delete User",
          isLoading: _isLoading,
          onTap: () {
            cv.showAlert(
              context: context,
              title: "Are you Sure?",
              body: const Text("This action cannot be undone."),
              cancelText: "Cancel",
              cancelBolded: true,
              onCancel: () {},
              submitText: "Delete",
              submitColor: Colors.red,
              onSubmit: () => _deleteFunc(context, dmodel),
            );
          }),
    );
  }

  Future<void> _deleteFunc(BuildContext context, DataModel dmodel) async {
    setState(() {
      _isLoading = true;
    });
    if (widget.season == null) {
      // remove team user
      await dmodel.deleteTeamUser(widget.team.teamId, widget.seasonUser.email,
          () {
        Navigator.of(context).pop();
        widget.onDelete();
      });
    } else {
      // remove season user
      await dmodel.deleteSeasonUser(
          widget.team.teamId, widget.season!.seasonId, widget.seasonUser.email,
          () {
        Navigator.of(context).pop();
        widget.onDelete();
      });
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _sendInvite(BuildContext context, DataModel dmodel) async {
    setState(() {
      _isLoading = true;
    });
    await dmodel
        .sendValidationEmail(widget.team.teamId, widget.seasonUser.email, () {
      widget.seasonUser.teamFields!.validationStatus = 2;
    }, onError: () {});
    setState(() {
      _isLoading = false;
    });
  }
}

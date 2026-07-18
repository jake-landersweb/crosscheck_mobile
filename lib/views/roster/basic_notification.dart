import 'package:crosscheck_sports/client/root.dart';
import 'package:flutter/material.dart';
import 'package:crosscheck_sports/data/root.dart';
import 'package:crosscheck_sports/extras/root.dart';
import 'package:provider/provider.dart';
import 'package:crosscheck_sports/components/layer/header_bar.dart';
import 'root.dart';
import 'package:crosscheck_sports/components/layer/wide_button.dart';
import 'package:crosscheck_sports/components/layer/action_button.dart';
import 'package:crosscheck_sports/components/layer/field.dart';
import 'package:crosscheck_sports/components/core/cell_list.dart';
import 'package:crosscheck_sports/components/layer/section.dart';

class BasicNotification extends StatefulWidget {
  const BasicNotification({
    super.key,
    required this.team,
    required this.users,
  });
  final Team team;
  final List<SeasonUser> users;

  @override
  State<BasicNotification> createState() => _BasicNotificationState();
}

class _BasicNotificationState extends State<BasicNotification> {
  String _subject = "";
  String _body = "";
  List<SeasonUser> _users = [];
  bool _isLoading = false;

  @override
  void initState() {
    logCurrentScreen("season_notification");
    _users = [
      for (var i in widget.users)
        if (!i.seasonFields!.isSub && i.seasonFields!.seasonUserStatus != -1)
          SeasonUser.of(i)
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    return HeaderBar.sheet(
      title: "Season-wide Blast",
      refreshable: false,
      backgroundColor: CustomColors.backgroundColor(context),
      leading: XCActionButton.cancel(
      onTap: () => Navigator.of(context, rootNavigator: true).pop(),
    ),
      child: Column(
        children: [
        XCCellList<Widget>(
          horizontalPadding: 0,
          childPadding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            XCField(
              labelText: "Subject",
              charLimit: 75,
              showCharacters: true,
              onChanged: (p0) {
                setState(() {
                  _subject = p0;
                });
              },
            ),
            XCField(
              labelText: "Body",
              hintText: "Body (Only shows in emails)",
              maxLines: 5,
              onChanged: (p0) {
                setState(() {
                  _body = p0;
                });
              },
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: _buttonText() == "Send"
              ? XCWideButton.primary(
                  title: _buttonText(),
                  color: dmodel.color,
                  isLoading: _isLoading,
                  onTap: () => _sendNotification(context, dmodel),
                )
              : XCWideButton.destructive(
                  title: _buttonText(),
                  onTap: () {},
                ),
        ),
        XCSection(
          "Users",
          child: XCCellList<SeasonUser>(
            children: sortSeasonUsers(
              widget.users,
              showNicknames: dmodel.tus!.team.showNicknames,
            ),
            // ..sort((a, b) {
            //   if (b.seasonFields?.isSub ?? false) {
            //     return -1;
            //   } else {
            //     return 1;
            //   }
            // }),
            allowsSelect: true,
            horizontalPadding: 0,
            color: dmodel.color,
            selected: _users,
            childPadding: const EdgeInsets.all(8),
            onSelect: (user) {
              if (_users.any((element) => element.email == user.email)) {
                // remove the user from the add list
                setState(() {
                  _users.removeWhere((element) => element.email == user.email);
                });
              } else {
                // add to add list
                setState(() {
                  _users.add(user);
                });
              }
            },
            childBuilder: (context, user) {
              return Row(
                children: [
                  RosterAvatar(
                      name: user.name(widget.team.showNicknames),
                      size: 50,
                      seed: user.email),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      user.name(widget.team.showNicknames),
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                        color: CustomColors.textColor(context),
                      ),
                    ),
                  ),
                  if (user.seasonFields?.isSub ?? false)
                    const Text(
                      "sub",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  if (user.seasonFields?.seasonUserStatus == -1)
                    const Text(
                      "inactive",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              );
            },
          ),
        ),
        ],
      ),
    );
  }

  String _buttonText() {
    if (_subject.isEmpty) {
      return "Subject is empty";
    } else if (_users.isEmpty) {
      return "List is empty";
    } else {
      return "Send";
    }
  }

  Future<void> _sendNotification(BuildContext context, DataModel dmodel) async {
    setState(() {
      _isLoading = true;
    });
    Map<String, dynamic> body = {
      "body": _body,
      "subject": _subject,
      "emails": _users.map((e) => e.email).toList(),
    };

    await dmodel.sendBasicEmail(widget.team.teamId, body, () {
      Navigator.of(context, rootNavigator: true).pop();
    });
    setState(() {
      _isLoading = false;
    });
  }
}

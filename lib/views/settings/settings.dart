import 'package:crosscheck_sports/crosscheck_engine.dart';
import 'package:crosscheck_sports/views/tsce/root.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:crosscheck_sports/data/root.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../extras/root.dart';
import '../../custom_views/root.dart' as cv;
import '../../client/root.dart';
import '../root.dart';
import 'package:crosscheck_sports/components/layer/header_bar.dart';
import 'package:crosscheck_sports/components/layer/snapping_sheet.dart';

import 'package:crosscheck_sports/components/layer/wide_button.dart';
import 'package:crosscheck_sports/components/core/clickable.dart';
import 'package:crosscheck_sports/components/core/cell_list.dart';
import 'package:crosscheck_sports/components/layer/section.dart';
import 'package:crosscheck_sports/components/adaptive/confirm_dialog/adaptive_confirm_dialog.dart';
import 'package:crosscheck_sports/components/core/labeled_row.dart';
import 'package:crosscheck_sports/components/layer/action_button.dart';

class Settings extends StatefulWidget {
  const Settings({
    super.key,
    required this.user,
  });
  final User user;

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  bool _isLoading = false;
  String? _token;

  @override
  void initState() {
    logEvent();
    _getToken();
    super.initState();
  }

  Future<void> _getToken() async {
    _token = await context.read<DataModel>().getNotificationToken();
    setState(() {});
  }

  void logEvent() async {
    await FirebaseAnalytics.instance.setCurrentScreen(screenName: "settings");
  }

  @override
  Widget build(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    return HeaderBar(
      title: "",
      backgroundColor: CustomColors.backgroundColor(context),
      trailing: _edit(context, dmodel),
      horizontalPadding: 0,
      bottomPadding: 48,
      child: Column(
        children: [
          _userInfo(context, dmodel),
          const SizedBox(height: 8),
          if (dmodel.teamArgs == null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: _teams(context, dmodel),
            ),
          _notifications(context, dmodel),
          const SizedBox(height: 32),
          _feedback(context, dmodel),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: XCWideButton.neutral(
              title: "Logout",
              isLoading: _isLoading,
              onTap: () => _showAlert(context, dmodel),
            ),
          ),
          const SizedBox(height: 32),
          _deleteAccount(context, dmodel),
          const SizedBox(height: 100),
          Text(
            "Version $appVersionMajor.$appVersionMinor",
            style: TextStyle(
              color: CustomColors.textColor(context).withOpacity(0.3),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 16),
          Clickable(
            onTap: () async {
              var uri = Uri.parse("https://crosschecksports.com/privacy-policy");
              if (!await launchUrl(
                uri,
                webViewConfiguration: const WebViewConfiguration(
                  headers: {"Access-Control-Allow-Origin": "*"},
                ),
              )) {
                dmodel.addIndicator(
                  IndicatorItem.error(
                    "There was an issue viewing the privacy policy",
                  ),
                );
              }
            },
            child: Text(
              "Privacy Policy",
              style: TextStyle(
                color: CustomColors.textColor(context).withOpacity(0.5),
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _userInfo(BuildContext context, DataModel dmodel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RosterAvatar(
            name: widget.user.getName(),
            seed: widget.user.email,
            size: 125,
            fontSize: 60,
          ),
          const SizedBox(height: 16),
          Text(
            widget.user.getName(),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          // add a summary view
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _summaryCell(widget.user.teams.length.toString(), "Teams"),
              const SizedBox(width: 8),
              _summaryCell(
                  widget.user.mobileNotifications.length.toString(), "Devices"),
              const SizedBox(width: 8),
              _summaryCell(
                  widget.user.getNumMonthsOfAccount().toString(), "Days"),
            ],
          ),
          const SizedBox(height: 16),
          // basic info fields
          XCSection(
            "Basic Info",
            // headerPadding: const EdgeInsets.fromLTRB(32, 8, 0, 4),
            child: XCCellList<Tuple3<String, String, bool>>(
              horizontalPadding: 0,
              childPadding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                if (widget.user.firstName?.isNotEmpty ?? false)
                  Tuple3("First Name", widget.user.firstName!, false),
                if (widget.user.lastName?.isNotEmpty ?? false)
                  Tuple3("Last Name", widget.user.lastName!, false),
                Tuple3("Email", widget.user.email, true),
                if (widget.user.phone.isNotEmpty)
                  Tuple3("Phone", widget.user.phone, true),
                if (widget.user.nickname.isNotEmpty)
                  Tuple3("Nickname", widget.user.nickname, false),
              ],
              childBuilder: (context, item) {
                return XCLabeledCell(
                  label: item.v1,
                  value: item.v2,
                  clickable: item.v3,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryCell(String val, String label) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: CustomColors.cellColor(context),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                val,
                style: TextStyle(
                  color: CustomColors.textColor(context),
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  color: CustomColors.textColor(context).withOpacity(0.5),
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _notifications(BuildContext context, DataModel dmodel) {
    return XCSection(
      "Emails",
      headerPadding: const EdgeInsets.fromLTRB(32, 8, 0, 4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            XCCellList<Widget>(
              childPadding: const EdgeInsets.symmetric(horizontal: 16),
              horizontalPadding: 0,
              children: [
                XCLabeledCell(
                  label: (widget.user.emailNotifications ?? false)
                      ? "True"
                      : "False",
                  value: "Allow Notifications",
                ),
              ],
            ),
            if (widget.user.mobileNotifications.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: XCSection(
                  "Phone Notifications",
                  // headerPadding: const EdgeInsets.fromLTRB(32, 8, 0, 4),
                  child: XCCellList<MobileNotification>(
                    childPadding: const EdgeInsets.symmetric(horizontal: 16),
                    children: widget.user
                        .getMobileNotifications(dmodel.teamArgs?.teamId),
                    horizontalPadding: 0,
                    childBuilder: ((context, notif) {
                      return Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: Image.asset(
                              notif.deviceType == "ios"
                                  ? "assets/images/iphone.png"
                                  : "assets/images/android.png",
                              height: 28,
                              width: 28,
                            ),
                          ),
                          if (notif.token == _token)
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: dmodel.color,
                                ),
                                height: 7,
                                width: 7,
                              ),
                            ),
                          Expanded(
                            child: XCLabeledCell(
                              label: notif.allow ? "True" : "False",
                              value:
                                  "${notif.deviceName ?? "Unknown Device"}${notif.deviceVersion != null ? " ${notif.deviceVersion}" : ""}",
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _teams(BuildContext context, DataModel dmodel) {
    return XCSection(
      "Teams",
      headerPadding: const EdgeInsets.fromLTRB(32, 8, 0, 4),
      child: Column(
        children: [
          // different style selector
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
          //   child: cv.DynamicSelector<UserTeam>(
          //     selections: widget.user.teams,
          //     selectedLogic: (context, item) {
          //       if (dmodel.tus != null) {
          //         return item.title == dmodel.tus!.team.title;
          //       } else {
          //         return false;
          //       }
          //     },
          //     titleBuilder: ((context, item) {
          //       return item.title;
          //     }),
          //     onSelect: (context, item) {
          //       _changeTeam(
          //         context,
          //         widget.user.teams
          //             .firstWhere((element) => element.title == item.title)
          //             .teamId,
          //       );
          //     },
          //     color: dmodel.color,
          //     selectorStyle: cv.DynamicSelectorStyle.list,
          //   ),
          // ),
          XCCellList(
            color: dmodel.color,
            children: widget.user.teams.map((e) => e.title).toList(),
            childBuilder: (context, String item) {
              return Text(
                item,
                style: TextStyle(
                  fontWeight: item == dmodel.tus?.team.title
                      ? FontWeight.w500
                      : FontWeight.w400,
                  fontSize: 18,
                  color: item == dmodel.tus?.team.title
                      ? dmodel.color
                      : CustomColors.textColor(context),
                ),
              );
            },
            allowsSelect: true,
            selected: [dmodel.tus?.team.title ?? ""],
            onSelect: (String item) {
              // change the team to the selected team in prefs
              _changeTeam(
                context,
                widget.user.teams
                    .firstWhere((element) => element.title == item)
                    .teamId,
              );
            },
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: cv.ActionList(
              items: [
                cv.ActionListItem(
                  title: "Join New Team",
                  icon: Icons.search_rounded,
                  view: JoinTeam(email: widget.user.email),
                  color: Colors.deepOrange[300]!,
                  type: cv.ALType.floating,
                ),
                cv.ActionListItem(
                  title: "Create My Team",
                  icon: Icons.add_rounded,
                  view: TSCERoot(user: dmodel.user!),
                  color: Colors.blue,
                  type: cv.ALType.snapping,
                ),
              ],
            ),
          ),
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
          //   child: cv.RoundedLabel(
          //     "Join New Team",
          //     color: CustomColors.cellColor(context),
          //     onTap: () {
          // cv.showFloatingSheet(
          //   context: context,
          //   builder: (context) {
          //     return JoinTeam(email: widget.user.email);
          //   },
          // );
          //     },
          //   ),
          // ),
          // const SizedBox(height: 16),
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
          //   child: cv.RoundedLabel(
          //     "Create Team",
          //     color: dmodel.color,
          //     textColor: Colors.white,
          //     onTap: () {
          // cv.showFloatingSheet(
          //   context: context,
          //   builder: (context) {
          //     return TCETemplates(
          //       user: widget.user,
          //       color: dmodel.color,
          //     );
          //   },
          // );
          //     },
          //   ),
          // ),
        ],
      ),
    );
  }

  Future<void> _changeTeam(BuildContext context, String teamId) async {
    await FirebaseAnalytics.instance.logEvent(
      name: "team_change",
      parameters: {"platform": "mobile"},
    );
    var prefs = await SharedPreferences.getInstance();
    prefs.setString("teamId", teamId);
    RestartWidget.restartApp(context);
  }

  void _showAlert(BuildContext context, DataModel dmodel) {
    AdaptiveConfirmDialog.show(
      context,
      title: "Are You Sure?",
      message: "You will have to re-login to access your data.",
      cancelLabel: "Cancel",
      confirmLabel: "Log Out",
      isDestructive: true,
    ).then((confirmed) {
      if (confirmed) {
        _logoutAction(context, dmodel);
      }
    });
  }

  Widget _edit(BuildContext context, DataModel dmodel) {
    if (dmodel.user == null) {
      return Container();
    } else {
      return XCActionButton.edit(
        onTap: () {
          showSnappingSheet(
            context: context,
            child: UserEdit(user: widget.user.clone()),
          );
        },
      );
    }
  }

  Widget _feedback(BuildContext context, DataModel dmodel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: XCWideButton.primary(
        color: dmodel.color,
        onTap: () {
          showSnappingSheet(
            context: context,
            child: Suggestions(email: widget.user.email),
          );
        },
        title: "Have suggestions?",
      ),
    );
  }

  Widget _deleteAccount(BuildContext context, DataModel dmodel) {
    return Clickable(
      onTap: () => AdaptiveConfirmDialog.show(
        context,
        title: "Are you sure?",
        message:
            "You are requesting to delete your account. Your account will remain active for 15 days after this request. If there has been no more activity within those 15 days, your account and data will be permenetly deleted from our databases.",
        cancelLabel: "Cancel",
        confirmLabel: "I am sure",
        isDestructive: true,
      ).then((confirmed) async {
        if (confirmed) {
          await dmodel.deleteAccount(widget.user.email, () {
            _logoutAction(context, dmodel);
          }, () {});
        }
      }),
      child: Text(
        "Delete Account",
        style: TextStyle(
          color: CustomColors.textColor(context).withOpacity(0.3),
          fontSize: 12,
        ),
      ),
    );
  }

  Future<void> _logoutAction(BuildContext context, DataModel dmodel) async {
    setState(() {
      _isLoading = true;
    });
    await dmodel.logout();
    Navigator.of(context).pop();
    setState(() {
      _isLoading = false;
    });
    RestartWidget.restartApp(context);
  }
}

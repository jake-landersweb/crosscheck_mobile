import 'dart:io';

import 'package:crosscheck_sports/crosscheck_engine.dart';
import 'package:crosscheck_sports/data/root.dart';
import 'package:crosscheck_sports/extras/root.dart';
import 'package:flutter/material.dart';
import 'package:crosscheck_sports/client/root.dart';
import 'package:crosscheck_sports/main.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:provider/provider.dart';
import '../../custom_views/root.dart' as cv;
import '../components/root.dart' as comp;

class UserEdit extends StatefulWidget {
  const UserEdit({
    Key? key,
    required this.user,
  }) : super(key: key);
  final User user;

  @override
  State<UserEdit> createState() => _UserEditState();
}

class _UserEditState extends State<UserEdit> {
  late String _firstName;
  late String _lastName;
  late String _phone;
  late String _nickname;
  late bool _emailNotifications;
  late List<MobileNotification> _mobileNotifications;
  String? _token;

  bool _isLoading = false;

  @override
  void initState() {
    _firstName = widget.user.firstName ?? "";
    _lastName = widget.user.lastName ?? "";
    _phone = widget.user.phone;
    _nickname = widget.user.nickname;
    _emailNotifications = widget.user.emailNotifications ?? false;
    _mobileNotifications = [
      for (var i in widget.user.getMobileNotifications(
        context.read<DataModel>().teamArgs?.teamId,
      ))
        i.clone()
    ];
    getToken(context.read<DataModel>());
    super.initState();
  }

  Future<void> getToken(DataModel dmodel) async {
    var t = await dmodel.getNotificationToken();
    setState(() {
      _token = t;
    });
  }

  @override
  Widget build(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    return cv.AppBar.sheet(
      title: "Edit User",
      childPadding: const EdgeInsets.fromLTRB(0, 16, 0, 48),
      leading: [
        cv.BackButton(
          title: "Cancel",
          color: dmodel.color,
          showIcon: false,
          useRoot: true,
          showText: true,
        ),
      ],
      children: [
        cv.ListView(
          childPadding: const EdgeInsets.symmetric(horizontal: 16),
          horizontalPadding: 16,
          children: [
            _firstNameField(context, dmodel),
            _lastNameField(context, dmodel),
            _phoneField(context, dmodel),
            _nicknameField(context, dmodel),
          ],
        ),
        cv.Section(
          "Notifications",
          headerPadding: const EdgeInsets.fromLTRB(32, 8, 0, 4),
          child: Column(
            children: [
              cv.ListView(
                childPadding: const EdgeInsets.symmetric(horizontal: 16),
                horizontalPadding: 16,
                children: [
                  _emailField(context, dmodel),
                ],
              ),
              const SizedBox(height: 8),
              cv.ListView<MobileNotification>(
                childPadding: const EdgeInsets.symmetric(horizontal: 16),
                horizontalPadding: 16,
                children: _mobileNotifications,
                allowsDelete: true,
                isAnimated: true,
                animateOpen: false,
                onDelete: (item) async {
                  setState(() {
                    _mobileNotifications
                        .removeWhere((element) => element.token == item.token);
                  });
                },
                childBuilder: (context, notif) {
                  return Row(
                    children: [
                      Expanded(
                        child: cv.LabeledWidget(
                          "${notif.deviceName ?? "Unknown Device"}${notif.deviceVersion != null ? " ${notif.deviceVersion}" : ""}",
                          child: Row(
                            children: [
                              FlutterSwitch(
                                value: notif.allow,
                                height: 25,
                                width: 50,
                                toggleSize: 18,
                                activeColor: dmodel.color,
                                onToggle: (value) async {
                                  setState(() {
                                    notif.allow = value;
                                  });
                                },
                              ),
                              const Spacer(),
                              if ((notif.token ?? "") == _token)
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
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
        if (!_mobileNotifications.any((element) => element.token == _token) &&
            (_token?.isNotEmpty ?? false))
          Column(
            children: [
              const SizedBox(height: 8),
              cv.ListView<Widget>(
                onChildTap: (context, item) async {
                  if (_token?.isNotEmpty ?? false) {
                    // get the device information
                    Map<String, dynamic> notif = await dmodel.getDeviceInfo();
                    notif['token'] = _token;
                    notif['allow'] = true;
                    setState(() {
                      _mobileNotifications
                          .add(MobileNotification.fromJson(notif));
                    });
                  } else {
                    dmodel.addIndicator(IndicatorItem.error(
                        "Please enable notifications in the settings app"));
                  }
                },
                children: const [Text("Add This Phone")],
              ),
            ],
          ),
        const SizedBox(height: 32),
        _button(context, dmodel)
      ],
    );
  }

  Widget _firstNameField(BuildContext context, DataModel dmodel) {
    return cv.TextField2(
      labelText: "First Name",
      isLabeled: true,
      showBackground: false,
      value: _firstName,
      onChanged: (value) {
        setState(() {
          _firstName = value;
        });
      },
    );
  }

  Widget _lastNameField(BuildContext context, DataModel dmodel) {
    return cv.TextField2(
      labelText: "Last Name",
      isLabeled: true,
      showBackground: false,
      value: _lastName,
      onChanged: (value) {
        _lastName = value;
      },
    );
  }

  Widget _phoneField(BuildContext context, DataModel dmodel) {
    return cv.TextField2(
      labelText: "Phone",
      isLabeled: true,
      showBackground: false,
      value: _phone,
      onChanged: (value) {
        _phone = value;
      },
    );
  }

  Widget _nicknameField(BuildContext context, DataModel dmodel) {
    return cv.TextField2(
      labelText: "Nickname",
      isLabeled: true,
      showBackground: false,
      value: _nickname,
      onChanged: (value) {
        _nickname = value;
      },
    );
  }

  Widget _emailField(BuildContext context, DataModel dmodel) {
    return cv.LabeledWidget(
      "Emails",
      child: Row(
        children: [
          FlutterSwitch(
            value: _emailNotifications,
            height: 25,
            width: 50,
            toggleSize: 18,
            activeColor: dmodel.color,
            onToggle: (value) {
              setState(() {
                _emailNotifications = value;
              });
            },
          ),
          const Spacer(),
        ],
      ),
    );
  }

  // Widget _phoneNotifField(BuildContext context, DataModel dmodel) {
  //   return cv.LabeledWidget(
  //     "Phone Notifications",
  //     child: Row(
  //       children: [
  //         FlutterSwitch(
  //           value: _phoneNotifications,
  //           height: 25,
  //           width: 50,
  //           toggleSize: 18,
  //           activeColor: dmodel.color,
  //           onToggle: (value) async {
  //             if (_token == null) {
  //               var token = await dmodel.getNotificationToken();
  //               if (token.isNotEmpty) {
  //                 setState(() {
  //                   _phoneNotifications = value;
  //                   _token = token;
  //                 });
  //               } else {
  //                 dmodel.addIndicator(IndicatorItem.error(
  //                     "Enable notifications in settings to allow"));
  //               }
  //             } else {
  //               setState(() {
  //                 _phoneNotifications = value;
  //               });
  //             }
  //           },
  //         ),
  //         const Spacer(),
  //       ],
  //     ),
  //   );
  // }

  Widget _button(BuildContext context, DataModel dmodel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: comp.ActionButton(
        title: "Confirm",
        color: dmodel.color,
        onTap: () => _action(context, dmodel),
        isLoading: _isLoading,
      ),
    );
  }

  String _buttonText() {
    if (_firstName.isEmpty) {
      return "First name is Blank";
    } else {
      return "Confirm";
    }
  }

  Future<void> _action(BuildContext context, DataModel dmodel) async {
    if (!_isLoading) {
      if (_buttonText() == "Confirm") {
        setState(() {
          _isLoading = true;
        });
        // make sure other notification tokens are added back when in xcheck or team app
        if (dmodel.teamArgs == null) {
          _mobileNotifications.addAll(dmodel.user!.mobileNotifications
              .where((element) => element.teamId != null));
        } else {
          _mobileNotifications.addAll(dmodel.user!.mobileNotifications
              .where((element) => element.teamId == null));
        }
        print(_mobileNotifications.map((e) => e.toJson()));
        // update the user
        Map<String, dynamic> body = {
          "firstName": _firstName,
          "lastName": _lastName,
          "phone": _phone,
          "nickname": _nickname,
          "emailNotifications": _emailNotifications,
          "mobileNotifications":
              _mobileNotifications.map((e) => e.toJson()).toList()
        };
        await dmodel.updateUser(widget.user.email, body, () async {
          // just reset app to keep data integrity
          RestartWidget.restartApp(context);
        });
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}

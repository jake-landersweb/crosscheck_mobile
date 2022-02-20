import 'package:flutter/material.dart';
import 'package:pnflutter/data/root.dart';
import 'package:provider/provider.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import '../../extras/root.dart';

import '../../custom_views/root.dart' as cv;
import '../../client/root.dart';
import '../root.dart';
import '../../main.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  String? _deviceId;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    _deviceId = await _getId();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    return cv.AppBar(
      title: "Settings",
      backgroundColor: CustomColors.backgroundColor(context),
      leading: const [MenuButton()],
      childPadding: const EdgeInsets.fromLTRB(
        0,
        16,
        0,
        48,
      ),
      children: [
        if (dmodel.user != null) _userInfo(context, dmodel),
        if (dmodel.user != null) _teams(context, dmodel),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: cv.Section(
            "Notifications",
            child: cv.NativeList(
              itemPadding: const EdgeInsets.all(16),
              children: [
                if (dmodel.user != null) _emailNotifications(context, dmodel),
                if (dmodel.user != null) _phoneNotifications(context, dmodel),
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: cv.RoundedLabel(
            "Log Out",
            color: Colors.red.withOpacity(0.3),
            textColor: Colors.red[900],
            onTap: () {
              _showAlert(context, dmodel);
            },
          ),
        ),
      ],
    );
  }

  Widget _userInfo(BuildContext context, DataModel dmodel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RosterAvatar(
            name: dmodel.user!.getName(),
            seed: dmodel.user!.email,
            size: 100,
            fontSize: 50,
          ),
          const SizedBox(height: 16),
          Text(
            dmodel.user!.getName(),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _teams(BuildContext context, DataModel dmodel) {
    return cv.Section(
      "Teams",
      headerPadding: const EdgeInsets.fromLTRB(32, 8, 0, 4),
      child: Column(
        children: [
          cv.CList(
            color: dmodel.color,
            children: dmodel.user!.teams.map((e) => e.title).toList(),
            childBuilder: (String item) {
              return Text(item,
                  style: TextStyle(color: CustomColors.textColor(context)));
            },
            allowsSelect: true,
            selected: [dmodel.tus?.team.title ?? ""],
            onSelect: (String item) {
              // change the team to the selected team in prefs
              _changeTeam(
                context,
                dmodel.user!.teams
                    .firstWhere((element) => element.title == item)
                    .teamId,
              );
            },
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: cv.RoundedLabel(
              "Join New Team",
              color: CustomColors.cellColor(context),
              onTap: () {
                cv.showFloatingSheet(
                  context: context,
                  builder: (context) {
                    return JoinTeam(email: dmodel.user!.email);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _changeTeam(BuildContext context, String teamId) async {
    var prefs = await SharedPreferences.getInstance();
    prefs.setString("teamId", teamId);
    RestartWidget.restartApp(context);
  }

  Widget _emailNotifications(BuildContext context, DataModel dmodel) {
    return Row(
      children: [
        const Text("Emails",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        const Spacer(),
        if (dmodel.user != null)
          SizedBox(
            height: 25,
            child: _isLoading
                ? const cv.LoadingIndicator()
                : FlutterSwitch(
                    value: dmodel.user!.emailNotifications!,
                    height: 25,
                    width: 50,
                    toggleSize: 18,
                    activeColor: Theme.of(context).colorScheme.primary,
                    onToggle: (value) async {
                      setState(() {
                        _isLoading = true;
                      });
                      await dmodel.updateUser(
                          dmodel.user!.email, {"emailNotifications": value},
                          () {
                        setState(() {
                          dmodel.user!.emailNotifications = value;
                        });
                      });
                      setState(() {
                        _isLoading = false;
                      });
                    },
                  ),
          ),
      ],
    );
  }

  Widget _phoneNotifications(BuildContext context, DataModel dmodel) {
    return Row(
      children: [
        const Text("Phone Notifications",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        const Spacer(),
        SizedBox(
          height: 25,
          child: _isLoading
              ? const cv.LoadingIndicator()
              : FlutterSwitch(
                  value: dmodel.user!.mobileNotifications.any((element) =>
                      element.deviceId == _deviceId && element.allow == true),
                  height: 25,
                  width: 50,
                  toggleSize: 18,
                  activeColor: Theme.of(context).colorScheme.primary,
                  onToggle: (value) async {
                    if (value) {
                      _registerNotification(dmodel);
                    } else {
                      setState(() {
                        _isLoading = true;
                      });
                      // user has turned off notifications, no need to do any permissions set up
                      Map<String, dynamic> body = {
                        "allow": false,
                        "deviceId": _deviceId ?? "",
                        "token": null,
                      };
                      await dmodel.updateUserNotifications(
                          dmodel.user!.email, body, (user) {
                        setState(() {
                          dmodel.user!.mobileNotifications =
                              user.mobileNotifications;
                        });
                      });
                      setState(() {
                        _isLoading = false;
                      });
                    }
                  },
                ),
        ),
      ],
    );
  }

  void _showAlert(BuildContext context, DataModel dmodel) {
    cv.showAlert(
      context: context,
      title: "Are You Sure?",
      body: const Center(
        child: Text(
          "You will have to re-login to access your data.",
          textAlign: TextAlign.center,
        ),
      ),
      cancelText: "Cancel",
      onCancel: () {},
      submitText: "Log Out",
      onSubmit: () {
        setState(() {
          dmodel.logout();
        });
        Navigator.of(context).pushAndRemoveUntil(
          // the new route
          MaterialPageRoute(
            builder: (BuildContext context) => const Home(),
          ),
          (Route route) => false,
        );
      },
      submitColor: Colors.red,
    );
  }

  Future<void> _registerNotification(DataModel dmodel) async {
    late final FirebaseMessaging _messaging;
    // 1. Initialize the Firebase app
    await Firebase.initializeApp();

    // 2. Instantiate Firebase Messaging
    _messaging = FirebaseMessaging.instance;

    // 3. On iOS, this helps to take the user permissions
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      setState(() {
        _isLoading = true;
      });
      print('User granted permission');
      _messaging.getToken().then((token) async {
        Map<String, dynamic> body = {
          "allow": true,
          "deviceId": _deviceId ?? "",
          "token": token,
        };
        await dmodel.updateUserNotifications(dmodel.user!.email, body, (user) {
          setState(() {
            _isLoading = false;
          });
          setState(() {
            dmodel.user!.mobileNotifications = user.mobileNotifications;
          });
        });
      });
    } else {
      print('User declined or has not accepted permission');
      dmodel.addIndicator(
          IndicatorItem.success("Blocked notifications successfully"));
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<String?> _getId() async {
    var deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) {
      // import 'dart:io'
      var iosDeviceInfo = await deviceInfo.iosInfo;
      return iosDeviceInfo.identifierForVendor; // unique ID on iOS
    } else {
      var androidDeviceInfo = await deviceInfo.androidInfo;
      return androidDeviceInfo.androidId; // unique ID on Android
    }
  }
}

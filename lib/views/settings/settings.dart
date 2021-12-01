import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:device_info_plus/device_info_plus.dart';
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
      children: [
        cv.Section(
          "Notifications",
          child: cv.NativeList(
            itemPadding: const EdgeInsets.all(16),
            children: [
              if (dmodel.user != null) _emailNotifications(context, dmodel),
              if (dmodel.user != null) _phoneNotifications(context, dmodel),
            ],
          ),
        ),
        cv.Section(
          "",
          child: cv.BasicButton(
            onTap: () {
              _showAlert(context, dmodel);
            },
            child: const cv.NativeList(
              itemPadding: EdgeInsets.all(16),
              children: [
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    "Log Out",
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
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
            child: FlutterSwitch(
              value: dmodel.user!.emailNotifications!,
              height: 25,
              width: 50,
              toggleSize: 18,
              activeColor: Theme.of(context).colorScheme.primary,
              onToggle: (value) {
                dmodel.updateUser(
                    dmodel.user!.email, {"emailNotifications": value}, () {
                  setState(() {
                    dmodel.user!.emailNotifications = value;
                  });
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
          child: FlutterSwitch(
            value: dmodel.user!.mobileNotifications.any((element) =>
                element.deviceId == _deviceId && element.allow == true),
            height: 25,
            width: 50,
            toggleSize: 18,
            activeColor: Theme.of(context).colorScheme.primary,
            onToggle: (value) {
              if (value) {
                _registerNotification(dmodel);
              } else {
                // user has turned off notifications, no need to do any permissions set up
                dmodel.updateUser(
                    dmodel.user!.email, {"mobileAppNotifications": value}, () {
                  Map<String, dynamic> body = {
                    "allow": false,
                    "deviceId": _deviceId ?? "",
                    "token": null,
                  };
                  dmodel.updateUserNotifications(dmodel.user!.email, body,
                      (user) {
                    setState(() {
                      dmodel.user!.mobileNotifications =
                          user.mobileNotifications;
                    });
                  });
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
      title: "Confirm Logout",
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

  void _registerNotification(DataModel dmodel) async {
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
      print('User granted permission');
      _messaging.getToken().then((token) {
        Map<String, dynamic> body = {
          "allow": true,
          "deviceId": _deviceId ?? "",
          "token": token,
        };
        dmodel.updateUserNotifications(dmodel.user!.email, body, (user) {
          setState(() {
            dmodel.user!.mobileNotifications = user.mobileNotifications;
          });
        });
      });
    } else {
      print('User declined or has not accepted permission');
      dmodel.setSuccess("Blocked notifications successfully", true);
    }
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

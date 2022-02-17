import 'package:flutter/material.dart';
import 'package:pnflutter/data/root.dart';
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
      children: [
        _userInfo(context, dmodel),
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
        const SizedBox(height: 32),
        cv.RoundedLabel(
          "Log Out",
          color: Colors.red.withOpacity(0.3),
          textColor: Colors.red[900],
          onTap: () {
            _showAlert(context, dmodel);
          },
        ),
      ],
    );
  }

  Widget _userInfo(BuildContext context, DataModel dmodel) {
    return cv.Section(
      "User Info",
      child: cv.RoundedLabel(
        "My Profile",
        color: CustomColors.cellColor(context),
        textColor: CustomColors.textColor(context),
        onTap: () {
          cv.Navigate(
            context,
            // SeasonUserDetail(
            //   team: dmodel.tus!.team,
            //   user: SeasonUser(
            //     email: dmodel.user!.email,
            //     userFields: SeasonUserUserFields(
            //       firstName: dmodel.user!.firstName,
            //       lastName: dmodel.user!.lastName,
            //     ),
            //   ),
            //   teamUser: dmodel.tus!.user,
            // ),
            Container(),
          );
        },
      ),
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
      dmodel.setSuccess("Blocked notifications successfully", true);
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

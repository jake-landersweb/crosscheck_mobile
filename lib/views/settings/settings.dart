import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

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
  @override
  Widget build(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    return Column(
      children: [
        cv.Section(
          "Notifications",
          child: cv.NativeList(
            itemPadding: const EdgeInsets.all(16),
            children: [
              _emailNotifications(context, dmodel),
              _phoneNotifications(context, dmodel),
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
          // child: FlutterSwitch(
          //   value: dmodel.user!.mobileAppNotifications!,
          //   height: 25,
          //   width: 50,
          //   toggleSize: 18,
          //   activeColor: Theme.of(context).colorScheme.primary,
          //   onToggle: (value) {
          //     if (value) {
          //       _phoneNotificationFunction(dmodel, value);
          //     } else {
          //       // user has turned off notifications, no need to do any permissions set up
          //       dmodel.updateUser(
          //           dmodel.user!.email, {"mobileAppNotifications": value}, () {
          //         setState(() {
          //           dmodel.user!.mobileAppNotifications = value;
          //         });
          //       });
          //     }
          //   },
          // ),
        ),
      ],
    );
  }

  void _phoneNotificationFunction(DataModel dmodel, bool value) async {
    if (value) {
      // ask for permission for notification
      _registerNotification(dmodel);
    } else {
      // update to false
      // dmodel.updateUser(dmodel.user!.email, {"mobileAppNotifications": value},
      //     () {
      //   setState(() {
      //     dmodel.user!.mobileAppNotifications = value;
      //   });
      // });
    }
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
      // _messaging.getToken().then((token) {
      //   dmodel.updateUser(dmodel.user!.email,
      //       {"mobileAppNotifications": true, "mobileDeviceToken": token}, () {
      //     setState(() {
      //       dmodel.user!.mobileAppNotifications = true;
      //     });
      //   });
      // });
    } else {
      print('User declined or has not accepted permission');
      dmodel.setError("Configure notifications in settings", true);
    }
  }
}

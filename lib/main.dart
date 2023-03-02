import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:crosscheck_sports/crosscheck_engine.dart' as engine;
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:timezone/data/latest.dart' as tz;

void main() async {
  // setup firebase
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // set up analytics
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  // ensure notifications show up in app
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true, // Required to display a heads up notification
    badge: true,
    sound: true,
  );

  // initialize timezones
  tz.initializeTimeZones();

  runApp(const CrosscheckMobile());
}

class CrosscheckMobile extends StatefulWidget {
  const CrosscheckMobile({Key? key}) : super(key: key);

  @override
  State<CrosscheckMobile> createState() => _CrosscheckMobileState();
}

class _CrosscheckMobileState extends State<CrosscheckMobile> {
  @override
  Widget build(BuildContext context) {
    return const engine.CrosscheckEngine();
  }
}

// https://links.crosschecksports.com/?link=https://teams.crosschecksports.com?params%3DT_9eca3bcb453045b8af5ae623776aba45,S_c6cb1efcf1ed4d3fa8f7a228d0c719fa,E_a620f59b615a4e96b6b0d1ab81bbcadf&apn=com.landersweb.pnflutter&afl=https://teams.crosschecksports.com/dashboard&ofl=https://teams.crosschecksports.com/dashboard&ibi=com.landersweb.pnflutter&ifl=https://teams.crosschecksports.com/dashboard&cid=5673108930831555040&_icp=1

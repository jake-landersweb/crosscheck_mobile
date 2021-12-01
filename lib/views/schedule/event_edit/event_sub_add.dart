import 'package:flutter/material.dart';
import 'package:pnflutter/theme/root.dart';
import 'package:provider/provider.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_switch/flutter_switch.dart';

import '../../../data/root.dart';
import '../../../client/root.dart';
import '../../../custom_views/root.dart' as cv;
import '../../../extras/root.dart';
import '../../shared/root.dart';

class EventSubAdd extends StatefulWidget {
  const EventSubAdd({
    Key? key,
    required this.teamId,
    required this.seasonId,
    required this.eventId,
  }) : super(key: key);
  final String teamId;
  final String seasonId;
  final String eventId;

  @override
  _EventSubAddState createState() => _EventSubAddState();
}

class _EventSubAddState extends State<EventSubAdd> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

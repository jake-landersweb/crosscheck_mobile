import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:pnflutter/theme/root.dart';
import 'package:pnflutter/views/stats/team/root.dart';
import 'package:provider/provider.dart';

import '../../custom_views/root.dart' as cv;
import '../../data/root.dart';
import '../../client/root.dart';
import '../../extras/root.dart';
import 'root.dart';
import '../root.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter/services.dart';

class EventScore extends StatefulWidget {
  const EventScore({
    Key? key,
    required this.team,
    required this.season,
    required this.event,
  }) : super(key: key);
  final Team team;
  final Season season;
  final Event event;

  @override
  _EventScoreState createState() => _EventScoreState();
}

class _EventScoreState extends State<EventScore> {
  @override
  Widget build(BuildContext context) {
    return cv.Sheet(
      title: "Edit Score",
      child: Container(),
    );
  }
}

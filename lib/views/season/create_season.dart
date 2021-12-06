import 'package:flutter/material.dart';
import 'package:pnflutter/client/api_helpers.dart';
import 'package:provider/provider.dart';
import '../../client/root.dart';
import '../../data/root.dart';
import '../../extras/root.dart';
import '../menu/root.dart';
import '../../custom_views/root.dart' as cv;

class CreateSeason extends StatefulWidget {
  const CreateSeason({
    Key? key,
    required this.team,
  }) : super(key: key);
  final Team team;

  @override
  _CreateSeasonState createState() => _CreateSeasonState();
}

class _CreateSeasonState extends State<CreateSeason> {
  String _title = "";

  String _website = "";
  bool _showNicknames = false;

  @override
  Widget build(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    return cv.AppBar(
      title: "Create Season",
      isLarge: true,
      backgroundColor: CustomColors.backgroundColor(context),
      // refreshable: true,
      color: dmodel.color,
      leading: const [MenuButton()],
      // trailing: [

      // ],
      // onRefresh: () => _refreshAction(dmodel),
      children: [_body(context, dmodel)],
    );
  }

  Widget _body(BuildContext context, DataModel dmodel) {
    return Column(
      children: [],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'root.dart';
import '../client/root.dart';
import '../extras/root.dart';

class Dashboard extends StatefulWidget {
  static const String route = "/dashboard";

  const Dashboard({Key? key}) : super(key: key);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  Widget build(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    return MultiProvider(
        providers: [ChangeNotifierProvider(create: (context) => MenuModel())],
        child: Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: (dmodel.tus?.team.color != null &&
                          dmodel.tus?.team.color != "")
                      ? CustomColors.fromHex(dmodel.tus!.team.color!)
                      : Colors.blue,
                ),
          ),
          child: MenuHost(),
        ));
  }
}
